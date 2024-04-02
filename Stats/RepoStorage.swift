//
//  RepoStorage.swift
//  Stats
//
//  Created by Deszip on 24.01.2021.
//

import CoreData

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
            request.predicate = NSPredicate(format: "path = \"\(repoPath)\"")
            do {
                let repos = try self.workingContext.fetch(request)
                if repos.isEmpty {
                    var newRepo = STRepo(context: self.workingContext)
                    newRepo = STRepo(context: self.workingContext)
                    newRepo.creationDate = Date()
                    newRepo.path = repo.path?.absoluteString
                    newRepo.name = repo.path?.lastPathComponent

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
            request.predicate = NSPredicate(format: "repoID = \"\(repoID)\"")
            do {
                let repos = try self.workingContext.fetch(request)
                if let repo = repos.first {
                    self.workingContext.delete(repo)
                    self.save()
                }
            } catch {
                fatalError("Failed to fetch repo: \(error)")
            }
        }
    }

    func addSamples(repoID: UUID) {
        //...
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
