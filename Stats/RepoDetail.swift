//
//  RepoDetail.swift
//  Stats
//
//  Created by Deszip on 24.01.2021.
//

import SwiftUI

struct RepoDetail: View {
    
    var repo: Repo
    
    var body: some View {
//        Text(String(repo.name))
        AreaChart(dataProvider: DataProvider())
    }
}

struct RepoDetail_Previews: PreviewProvider {
    static var previews: some View {
        RepoDetail(repo: Repo(name: "Foo repo", path: URL(string:"http://github.com/foo/foo")!, imageName: ""))
    }
}
