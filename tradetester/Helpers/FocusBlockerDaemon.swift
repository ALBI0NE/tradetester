import Foundation

class FocusBlockerDaemon {
    static let shared = FocusBlockerDaemon()
    private let launchdPlist = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
            <key>Label</key>
            <string>com.tradetester.focusblocker</string>
            <key>ProgramArguments</key>
            <array>
                <string>/usr/sbin/pfctl</string>
                <string>-e</string>
                <string>-f</string>
                <string>/etc/pf.anchors/com.tradetester</string>
            </array>
            <key>RunAtLoad</key>
            <true/>
            <key>KeepAlive</key>
            <true/>
        </dict>
        </plist>
        """

    func installDaemon() throws {
        let plistPath = "/Library/LaunchDaemons/com.tradetester.focusblocker.plist"
        try launchdPlist.write(
            to: URL(fileURLWithPath: plistPath), atomically: true, encoding: .utf8)

        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/bin/launchctl")
        task.arguments = ["load", plistPath]
        try task.run()
        task.waitUntilExit()
    }
}
