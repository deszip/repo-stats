//
//  StatsApp.swift
//  Stats
//
//  Created by Deszip on 24.01.2021.
//

import SwiftUI
import StatsCore

@main
struct StatsApp: App {
    @ObservedObject private var storage = RepoStorage()

    var body: some Scene {
        WindowGroup {
            ContentView(store: storage,
                        saveAction: { storage.add($0)},
                        removeAction: { storage.remove($0) }
            )
            .frame(minWidth: 700, minHeight: 300)
            .onAppear { storage.load() }
//            .environment(\.managedObjectContext, nil)
        }
        .commands { SidebarCommands() }
    }

    init() {
        STCoreLoader.loadCore()
    }
}
