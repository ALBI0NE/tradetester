//
//  ContentView.swift
//  tradetester
//
//  Created by Jakub Kopacz on 20/01/2025.
//

import Foundation
import Network
import SwiftUI
import UniformTypeIdentifiers

@testable import tradetester

struct ContentView: View {
    @Binding var document: tradetesterDocument
    @StateObject private var focusTimer = FocusTimer()
    @ObservedObject private var networkManager = NetworkManager.shared

    var body: some View {
        VStack(spacing: 20) {
            TextEditor(text: $document.text)
                .frame(height: 200)

            Text(timeString(from: focusTimer.timeRemaining))
                .font(.system(size: 50, weight: .bold, design: .monospaced))

            Button(action: {
                if focusTimer.isActive {
                    focusTimer.stop()
                } else {
                    focusTimer.start()
                }
            }) {
                Text(focusTimer.isActive ? "Stop Focus Mode" : "Start Focus Mode")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 200)
                    .background(focusTimer.isActive ? Color.red : Color.green)
                    .cornerRadius(10)
            }

            if focusTimer.isActive {
                Text("Focus mode is active\nDistraction websites are blocked")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .alert("Error", isPresented: $networkManager.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(networkManager.errorMessage)
        }
    }

    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    ContentView(document: Binding.constant(tradetesterDocument()))
}
