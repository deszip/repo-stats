//
//  RepoBuilder.swift
//  Stats
//
//  Created by Deszip on 14.02.2021.
//

import Foundation

struct Repo: Identifiable, Codable, Hashable, Equatable {
    var id: UUID = UUID()
    let name: String
    let path: URL?
    let imageName: String
    
    static func ==(lhs: Repo, rhs: Repo) -> Bool {
        return lhs.id == rhs.id
    }
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

    init(with repo: STRepo) {
        self.id = repo.repoID ?? UUID()
        self.name = repo.name ?? ""
        self.path = URL(string: repo.path ?? "")
        self.imageName = repo.imageURL ?? ""
    }
}
