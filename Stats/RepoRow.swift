//
//  RepoRow.swift
//  Stats
//
//  Created by Deszip on 24.01.2021.
//

import SwiftUI

struct RepoRow: View {
    
    @ObservedObject var repo: STRepo
    
    var body: some View {
        HStack {
            Image(String(repo.imageURL ?? ""))
                .resizable()
                .frame(width: 50, height: 50)
                .cornerRadius(5)
            VStack(alignment: .leading) {
                Text(String(repo.name ?? ""))
                    .bold()
                Text("Branch: \(repo.branch ?? ""), commits: \(repo.samples?.count ?? 0)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

//struct RepoRow_Previews: PreviewProvider {
//    static var previews: some View {
//        RepoRow(repo: Repo(name: "Foo", path: URL(string:"http://github.com/foo/foo")!, imageName: "", samplesCount: 42))
//    }
//}
