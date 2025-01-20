import Foundation
import Network

class NetworkManager: ObservableObject {
    static let shared = NetworkManager()
    @Published var isBlockingActive = false
    @Published var showError = false
    @Published var errorMessage = ""

    private let blockedDomains = [
        "facebook.com", "www.facebook.com",
        "youtube.com", "www.youtube.com",
        "twitter.com", "www.twitter.com",
        "instagram.com", "www.instagram.com",
        "reddit.com", "www.reddit.com",
    ]

    private let queue = DispatchQueue(label: "com.tradetester.networkmanager")

    func toggleBlocking() {
        queue.async { [weak self] in
            guard let self = self else { return }
            self.isBlockingActive.toggle()

            if self.isBlockingActive {
                self.activateBlocking()
            } else {
                self.deactivateBlocking()
            }
        }
    }

    private func activateBlocking() {
        do {
            print("🔒 Attempting to block websites...")
            let rules = """
                # Block distracting websites
                table <blocked> { \(blockedDomains.joined(separator: ", ")) }
                block return out proto {tcp udp} from any to <blocked>
                """
            print("📝 Rules created: \n\(rules)")
            try installRules(rules)
            print("✅ Blocking activated successfully")
            DispatchQueue.main.async {
                self.isBlockingActive = true
            }
        } catch {
            print("❌ Error activating blocking: \(error)")
            handleError("Failed to activate blocking: \(error.localizedDescription)")
        }
    }

    private func deactivateBlocking() {
        do {
            print("🔓 Attempting to unblock websites...")
            let task = Process()
            task.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
            let script = """
                do shell script "sudo pfctl -F rules && sudo pfctl -f /etc/pf.conf" with administrator privileges
                """
            task.arguments = ["-e", script]
            try task.run()
            task.waitUntilExit()

            print("✅ Unblocking successful")
            DispatchQueue.main.async {
                self.isBlockingActive = false
            }
        } catch {
            print("❌ Error deactivating blocking: \(error)")
            handleError("Failed to deactivate blocking: \(error.localizedDescription)")
        }
    }

    private func installRules(_ rules: String) throws {
        let rulesPath = "/etc/pf.anchors/com.tradetester"

        // Write rules using sudo with error capture
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")

        let pipe = Pipe()
        task.standardError = pipe

        let script = """
            do shell script "echo '\(rules)' | sudo tee \(rulesPath) && sudo pfctl -f \(rulesPath)" with administrator privileges
            """
        task.arguments = ["-e", script]

        try task.run()
        task.waitUntilExit()

        if task.terminationStatus != 0 {
            let errorData = try pipe.fileHandleForReading.readToEnd() ?? Data()
            let errorMessage = String(data: errorData, encoding: .utf8) ?? "Unknown error"
            print("🛑 PF Error: \(errorMessage)")

            throw NSError(
                domain: "NetworkManager",
                code: Int(task.terminationStatus),
                userInfo: [
                    NSLocalizedDescriptionKey: "Failed to install firewall rules: \(errorMessage)"
                ]
            )
        }
    }

    private func handleError(_ message: String) {
        DispatchQueue.main.async {
            self.showError = true
            self.errorMessage = message
            self.isBlockingActive = false
        }
    }
}
