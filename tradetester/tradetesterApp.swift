//
//  tradetesterApp.swift
//  tradetester
//
//  Created by Jakub Kopacz on 20/01/2025.
//

import SwiftUI

@main
struct tradetesterApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: tradetesterDocument()) { file in
            ContentView(document: file.$document)
        }
    }
}
