//
//  AddView.swift
//  Stats
//
//  Created by Deszip on 24.01.2021.
//

import SwiftUI

struct AddView: View {
    
    @Binding var showInput: Bool
    @State var repoPath: String = ""
    
    var action: (Repo?) -> Void
    
    var body: some View {
        VStack {
            Form {
                TextField("Repo URL", text: $repoPath)
                Button(action: {
                    defer { self.showInput.toggle() }
                    guard let repoURL = URL(string: repoPath) else { return }
                    let repo = Repo(name: repoURL.lastPathComponent, path: repoURL, imageName: "")
                    action(repo)
                }) {
                    Text("Save")
                }
            }
            .frame(width: 300)
            .navigationTitle("Landmark Settings")
            .padding(80)
        }
        .frame(minWidth: 200, minHeight: 100)
        .edgesIgnoringSafeArea(.all)
    }
}

struct AddView_Previews: PreviewProvider {
    static var previews: some View {
        AddView(showInput: .constant(true), action: {_ in })
    }
}
