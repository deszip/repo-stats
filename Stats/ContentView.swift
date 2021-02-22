//
//  ContentView.swift
//  Stats
//
//  Created by Deszip on 24.01.2021.
//

import SwiftUI

private struct SelectedRepokKey: FocusedValueKey {
    typealias Value = Binding<Repo>
}

extension FocusedValues {
    var selectedRepo: Binding<Repo>? {
        get { self[SelectedRepokKey.self] }
        set { self[SelectedRepokKey.self] = newValue }
    }
}

struct ContentView: View {
    
    @Binding var repos: [Repo]
    var saveAction: (Repo) -> Void
    var removeAction: (Repo) -> Void
    
    @State var selectedRepo: Repo?
    @State private var showingModal = false
    @State private var showingAlert = false
    
    var selectedRepoIndex: Int {
        repos.firstIndex(where: { $0.id == selectedRepo?.id }) ?? repos.startIndex
    }
    
    var body: some View {
        NavigationView {
            List(selection: $selectedRepo) {
                ForEach(repos) { repo in
                    NavigationLink(destination: RepoDetail(repo: repo)) {
                        RepoRow(repo: repo)
                    }.contextMenu {
                        Button(action: {
                            self.showingAlert = true
                        }) {
                            Text("Remove repo")
                        }
                    }
                }
            }
            .listStyle(SidebarListStyle())
            .navigationTitle("Repos")
            .navigationViewStyle(DoubleColumnNavigationViewStyle())
            .frame(minWidth: 180, idealWidth: 200, maxWidth: 300)
            .toolbar {
                Button(action: {
                    self.showingModal.toggle()
                }) {
                    Text("Add")
                }.sheet(isPresented: $showingModal) {
                    AddView(showInput: $showingModal, action: { $0.flatMap { saveAction($0) } })
                }
            }
            
            Text("Select a Repo")
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Are you sure?"),
                message: Text("Do you want to remove the \(selectedRepo?.name ?? "") repo?"),
                primaryButton: .default(Text("OK"), action: {
                    selectedRepo.flatMap { removeAction($0) }
                }),
                secondaryButton: .cancel()
            )
        }
        .focusedValue(\.selectedRepo, $repos[selectedRepoIndex])
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(repos: .constant([Repo(name: "Foo repo",
                                           path: URL(string:"http://github.com/foo/foo")!,
                                           imageName: "")]),
                    saveAction: {_ in }, removeAction: { _ in })
    }
}
