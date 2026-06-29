import SwiftUI

@main
struct RudiFoodiApp: App {
    var body: some Scene {
        WindowGroup {
            GameWebView()
                .ignoresSafeArea()
                .statusBarHidden(true)
        }
    }
}
