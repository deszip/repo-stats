//
//  RepoStorage.swift
//  Stats
//
//  Created by Deszip on 24.01.2021.
//

import CoreData

class RepoStorage: ObservableObject {
    
    private let container: NSPersistentContainer

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
    }

    func load() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let reposData = UserDefaults.standard.value(forKey: "repos") as? [Data] else {
                return
            }

            let repos = reposData.map { Repo($0) }.compactMap { $0 }
            DispatchQueue.main.async { self?.repos = repos }
        }
    }
    
    func add(_ repo: Repo) {
        repos.append(repo)
        save()
    }
    
    func remove(_ repoID: UUID) {
        repos.removeAll { $0.id == repoID }
    }
    
    func save() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            UserDefaults.standard.setValue(self?.repos.map { $0.encode() }, forKey: "repos")
        }
    }

}
