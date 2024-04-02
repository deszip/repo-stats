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
    var store: RepoStorage
    var saveAction: (Repo) -> Void
    var removeAction: (UUID) -> Void
    var loadAction: (UUID) -> Void
    
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \STRepo.name, ascending: true)],
        animation: .default)
    private var repos: FetchedResults<STRepo>

    @State var selectedRepos = Set<STRepo>()
    @State private var showingModal = false
    @State private var showingAlert = false
        
    var body: some View {
        NavigationView {
            List(repos, id: \.self, selection: $selectedRepos) { repo in
                NavigationLink(destination: RepoDetail(repo: Repo(with: repo))) {
                    RepoRow(repo: repo)
                }.contextMenu {
                    Button(action: {
                        self.showingAlert = true
                    }) {
                        Text("Remove repo")
                    }
                    Button(action: {
                        selectedRepos.first?.repoID.flatMap { loadAction($0) }
                    }) {
                        Text("Load samples")
                    }
                }
            }
            .listStyle(SidebarListStyle())
            .navigationTitle("Repos")
            .navigationViewStyle(DoubleColumnNavigationViewStyle())
            .frame(minWidth: 180, idealWidth: 200, maxWidth: 300)

            Text("Select a Repo")
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Are you sure?"),
                message: Text("Do you want to remove the \(selectedRepos.count) repo?"),
                primaryButton: .default(Text("OK"), action: {
                    selectedRepos.first?.repoID.flatMap { removeAction($0) }
                }),
                secondaryButton: .cancel()
            )
        }.toolbar {
            Button(action: {
                self.showingModal.toggle()
            }) {
                Text("Add")
            }.sheet(isPresented: $showingModal) {
                AddView(showInput: $showingModal, action: {
                    $0.flatMap { saveAction($0) }
                })
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(store: RepoStorage(), saveAction: {_ in }, removeAction: { _ in }, loadAction: { _ in })
    }
}
