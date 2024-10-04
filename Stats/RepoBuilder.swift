//
//  RepoBuilder.swift
//  Stats
//
//  Created by Deszip on 14.02.2021.
//

import Foundation

struct Repo: Identifiable, Hashable, Equatable {
    var id: UUID = UUID()
    let name: String
    let path: URL?
    let localPath: URL?
    let branch: String
    let imageName: String
    let samplesCount: Int
    
    static func ==(lhs: Repo, rhs: Repo) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Repo {
//    func encode() -> Data? {
//        let encoder = JSONEncoder()
//        return try? encoder.encode(self)
//    }
    
//    init?(_ data: Data) {
//        let decoder = JSONDecoder()
//        if let repo = try? decoder.decode(Repo.self, from: data) {
//            self.id = repo.id
//            self.name = repo.name
//            self.path = repo.path
//            self.imageName = repo.imageName
//        } else {
//            return nil
//        }
//    }

    init(with repo: STRepo) {
        self.id = repo.repoID ?? UUID()
        self.name = repo.name ?? ""
        self.path = URL(string: repo.path ?? "")
        self.branch = repo.branch ?? ""
        self.imageName = repo.imageURL ?? ""
        self.samplesCount = repo.samples?.count ?? 0
        self.localPath = URL(string: repo.localPath ?? "")
    }
}
