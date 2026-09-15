import AppKit
import HotKey

@main
struct SuperKeys {
    static func main() {
        let app = NSApplication.shared
        app.setActivationPolicy(.prohibited) // no Dock, no menu bar
        let hotKeys = createHotKeys()
        app.run()
    }
    
    static func createHotKeys() -> [HotKey] {
        [
            HotKey(key: .return, modifiers: [.command, .shift]) {
                launch(app: browserPath)
            },
            HotKey(key: .a, modifiers: [.command, .shift]) {
                open(website: "https://grok.com")
            },
            HotKey(key: .e, modifiers: [.command, .shift]) {
                launch(app: "")
            }
        ]
    }
    
    static func launch(app appPath: String) {
        NSWorkspace.shared.openApplication(
            at: URL(fileURLWithPath: appPath),
            configuration: NSWorkspace.OpenConfiguration()
        )
    }
    
    static func open(website: String) {
        guard let websiteURL = URL(string: website) else {
            print("Can't make URL from " + website)
            return
        }
        
        NSWorkspace.shared.open(
            [websiteURL],
            withApplicationAt: browserURL,
            configuration: NSWorkspace.OpenConfiguration()
        )
    }
    
    static let browserURL = URL(fileURLWithPath: browserPath)
    static let browserPath = "/Applications/Brave Browser.app"
}
