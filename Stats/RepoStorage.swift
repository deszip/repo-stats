//
//  RepoStorage.swift
//  Stats
//
//  Created by Deszip on 24.01.2021.
//

import Foundation

class RepoStorage: ObservableObject {
    
    @Published var repos: [Repo] = []
    
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
