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
    @State var repoLocalPath: String = ""
    @State var repoBranch: String = ""

    var action: (Repo?) -> Void
    
    var body: some View {
        VStack {
            Form {
                TextField("Repo URL:", text: $repoPath)
                HStack {
                    Button {
                        self.showSavePanel()
                    } label: {
                        Text("Select")
                    }
                    Text(repoLocalPath)
                }
                TextField("Repo branch:", text: $repoBranch)
                HStack {
                    Button(action: {
                        self.showInput.toggle()
                    }) {
                        Text("Cancel")
                    }
                    Button(action: {
                        defer { self.showInput.toggle() }
                        guard let repoURL = URL(string: repoPath) else { return }
                        guard let repoPath = URL(string: repoLocalPath) else { return }
                        let repo = Repo(
                            name: repoURL.lastPathComponent,
                            path: repoURL,
                            localPath: repoPath,
                            branch: repoBranch,
                            imageName: "",
                            samplesCount: 0
                        )
                        action(repo)
                    }) {
                        Text("Save")
                    }
                }
            }
            .frame(width: 300)
            .padding(80)
        }
        .frame(minWidth: 200, minHeight: 100)
        .edgesIgnoringSafeArea(.all)
    }

    func showSavePanel() {
        let savePanel = NSSavePanel()
        savePanel.canCreateDirectories = true
        savePanel.isExtensionHidden = false
        savePanel.title = "Select directory"
        savePanel.message = "Choose a folder with repo"
        savePanel.nameFieldLabel = "Repo:"

        let response = savePanel.runModal()

        if response == .OK, let url = savePanel.directoryURL {
            self.repoLocalPath = url.path(percentEncoded: false)
        }
    }

}

struct AddView_Previews: PreviewProvider {
    static var previews: some View {
        AddView(showInput: .constant(true), action: {_ in })
    }
}
