//
//  RepoBuilder.swift
//  Stats
//
//  Created by Deszip on 14.02.2021.
//

import Foundation

struct Repo: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    let name: String
    let path: URL
    let imageName: String
}

extension Repo {
    func encode() -> Data? {
        let encoder = JSONEncoder()
        return try? encoder.encode(self)
    }
    
    init?(_ data: Data) {
        let decoder = JSONDecoder()
        if let repo = try? decoder.decode(Repo.self, from: data) {
            self.id = repo.id
            self.name = repo.name
            self.path = repo.path
            self.imageName = repo.imageName
        } else {
            return nil
        }
    }
}
