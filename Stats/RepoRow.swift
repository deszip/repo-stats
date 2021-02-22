//
//  RepoRow.swift
//  Stats
//
//  Created by Deszip on 24.01.2021.
//

import SwiftUI

struct RepoRow: View {
    
    var repo: Repo
    
    var body: some View {
        HStack {
            Image(String(repo.imageName))
                .resizable()
                .frame(width: 50, height: 50)
                .cornerRadius(5)
            VStack(alignment: .leading) {
                Text(String(repo.name))
                    .bold()
                Text("details")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct RepoRow_Previews: PreviewProvider {
    static var previews: some View {
        RepoRow(repo: Repo(name: "Foo", path: URL(string:"http://github.com/foo/foo")!, imageName: ""))
    }
}
