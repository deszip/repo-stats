//
//  RepoStorage.swift
//  Stats
//
//  Created by Deszip on 24.01.2021.
//

import CoreData
import StatsCore

class RepoStorage: ObservableObject {
    
    private let container: NSPersistentContainer
    private let workingContext: NSManagedObjectContext
    let viewContext: NSManagedObjectContext

    @Published var repos: [Repo] = []

    init() {
        guard let modelURL = Bundle(for: RepoStorage.self)
            .url(forResource: "StatsStore", withExtension: "momd") else {
            fatalError("Failed to find data model")
        }
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Failed to create model from file: \(modelURL)")
        }

        self.container = NSPersistentContainer(name: "StatsStore", managedObjectModel: mom)

        // Put store in App Support directory
        guard let appSupportURL = FileManager.default.urls(for: .applicationSupportDirectory,
                                                      in: .userDomainMask).first else
        {
            fatalError("Failed to get app support URL")
        }

        let storeParentURL = appSupportURL.appendingPathComponent("Stats")
        if FileManager.default.fileExists(atPath: storeParentURL.path) == false {
            do {
                try FileManager.default.createDirectory(at: storeParentURL, withIntermediateDirectories: true)
            }
            catch { fatalError("Failed to create directory for store: \(error)") }
        }

        // Add store
        let storeURL = storeParentURL.appendingPathComponent("StatsStore.sqlite")
        let description = NSPersistentStoreDescription(url: storeURL)
        description.type = NSSQLiteStoreType
        description.shouldInferMappingModelAutomatically = true
        description.shouldMigrateStoreAutomatically = true
        self.container.persistentStoreDescriptions = [description]

        self.container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })

        self.workingContext = self.container.newBackgroundContext()
        self.viewContext = self.container.viewContext
        self.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func add(_ repo: Repo) {
        workingContext.perform {
            guard let repoPath = repo.path?.absoluteString else {
                return
            }

            let request = STRepo.fetchRequest()
            request.predicate = NSPredicate(format: "path = %@", repoPath)
            do {
                let repos = try self.workingContext.fetch(request)
                if repos.isEmpty {
                    let newRepo = STRepo(context: self.workingContext)
                    newRepo.repoID = UUID()
                    newRepo.creationDate = Date()
                    newRepo.path = repo.path?.absoluteString
                    newRepo.name = repo.path?.lastPathComponent
                    newRepo.branch = repo.branch
                    newRepo.updateDate = Date()
                    self.save()
                }
            } catch {
                fatalError("Failed to fetch repo: \(error)")
            }
        }
    }
    
    func remove(_ repoID: UUID) {
        workingContext.perform {
            let request = STRepo.fetchRequest()
            request.predicate = NSPredicate(format: "repoID = %@", repoID.uuidString)
            do {
                let repos = try self.workingContext.fetch(request)
                if let repo = repos.first {
                    self.workingContext.delete(repo)
                    self.save()
                } else {
                    print("Storage failed to gt repo with ID: \(repoID)")
                }
            } catch {
                fatalError("Failed to fetch repo: \(error)")
            }
        }
    }

    func run(repoID: UUID) {
        workingContext.perform {
            let request = STRepo.fetchRequest()
            request.predicate = NSPredicate(format: "repoID = %@", repoID.uuidString)
            do {
                let repos = try self.workingContext.fetch(request)
                if let repo = repos.first, let repoPath = repo.path, let repoBranch = repo.branch {

                    let workingDirectoryURL = self.workingPath(repo)

                    // init toolkit with repo dir
                    let gitToolkit = STGitToolkit(workingDirectory: workingDirectoryURL)

                    return

                    // could be a already loaded dir, add option to force clone
                    gitToolkit.cloneRepo(repoPath, branch: repoBranch)

                    // get full commits list
                    let commitHashes = gitToolkit.listCommits()
                    print("Commits: \(commitHashes.count)")

                    // iterate all commits, get stats, save to repo
                    // - if repo has stats already try to find last one and start from it
                    var previousCommit: STCommit?
                    for (idx, commitHash) in commitHashes.enumerated().reversed() {
                        let commit = gitToolkit.getStats(commitHash)
                        print("Hash \(idx): \(commit.commitHash)")

                        let sample = STSample(context: self.workingContext)
                        sample.sampleID = UUID()
                        sample.lineCount = Int64(commit.totalLineCount)
                        if previousCommit == nil {
                            sample.commitLinesCount = Int64(commit.totalLineCount)
                        } else {
                            sample.commitLinesCount = Int64(commit.totalLineCount) - Int64((previousCommit?.totalLineCount ?? 0))
                        }
                        sample.additionalLineCount = Int64(commit.additionalLineCount)
                        sample.date = commit.commitDate
                        sample.commitHash = commit.commitHash
                        sample.repo = repo
                        repo.updateDate = Date()
                        self.save()
                        
                        previousCommit = commit
                    }
                }
            } catch {
                fatalError("Failed to fetch repo: \(error)")
            }
        }
    }
    
    func dropSamples(repoID: UUID) {
        workingContext.perform {
            let request = STRepo.fetchRequest()
            request.predicate = NSPredicate(format: "repoID = %@", repoID.uuidString)
            do {
                let repos = try self.workingContext.fetch(request)
                if let repo = repos.first {
                    repo.samples?.compactMap { $0 as? STSample }.forEach { self.workingContext.delete($0) }
                    self.save()
                }
            } catch {
                fatalError("Failed to fetch repo: \(error)")
            }
        }
    }

    private func workingPath(_ repo: STRepo) -> URL {
        if let localPath = repo.localPath {
            var isDir: ObjCBool = false
            let directoryExists = FileManager.default.fileExists(atPath: localPath, isDirectory: &isDir)
            if directoryExists && isDir.boolValue {
                let workingURL = URL(fileURLWithPath: localPath)
                return workingURL
            }
        }

        let tempDirectoryURL = FileManager.default.temporaryDirectory
        let newDirectoryName = UUID().uuidString // Unique directory name
        let newDirectoryURL = tempDirectoryURL.appendingPathComponent(newDirectoryName)

        do {
            try FileManager.default.createDirectory(at: newDirectoryURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Failed to create directory: \(error)")
        }

        print("Working dir: \(newDirectoryURL)")

        return newDirectoryURL
    }

    private func save() {
        do {
            try self.workingContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

}
