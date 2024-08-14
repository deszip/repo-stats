//
//  RepoDetail.swift
//  Stats
//
//  Created by Deszip on 24.01.2021.
//

import SwiftUI

struct RepoDetail: View {
    
    @ObservedObject var repo: STRepo

    var body: some View {
        AreaChart(repo: repo)
    }
}

//struct RepoDetail_Previews: PreviewProvider {
//    static var previews: some View {
//        RepoDetail(repo: Repo(name: "Foo repo", path: URL(string:"http://github.com/foo/foo")!, imageName: "", samplesCount: 0))
//    }
//}
