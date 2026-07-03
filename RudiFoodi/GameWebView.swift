import SwiftUI
import UIKit
import WebKit

struct GameWebView: UIViewRepresentable {
    private let bundledGameFileName = "Game"
    private let bundledGameFileExtension = "html"
    private let developmentGameURL = URL(fileURLWithPath: "/Users/kingmustard/Downloads/thisissoooooogoog.html")

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true

        let contentController = WKUserContentController()
        contentController.add(context.coordinator, name: Coordinator.hapticMessageName)
        contentController.addUserScript(Coordinator.hapticClickScript)
        configuration.userContentController = contentController

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.isOpaque = false
        webView.backgroundColor = .black
        webView.scrollView.backgroundColor = .black
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.allowsBackForwardNavigationGestures = false
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        guard webView.url == nil else {
            return
        }

        let gameURL = Bundle.main.url(
            forResource: bundledGameFileName,
            withExtension: bundledGameFileExtension
        ) ?? developmentGameURL

        webView.loadFileURL(gameURL, allowingReadAccessTo: gameURL.deletingLastPathComponent())
    }

    static func dismantleUIView(_ webView: WKWebView, coordinator: Coordinator) {
        webView.configuration.userContentController.removeScriptMessageHandler(forName: Coordinator.hapticMessageName)
    }

    final class Coordinator: NSObject, WKScriptMessageHandler {
        static let hapticMessageName = "rudiFoodiHaptic"

        static let hapticClickScript = WKUserScript(
            source: """
            (() => {
                if (window.__rudiFoodiHapticsInstalled) { return; }
                window.__rudiFoodiHapticsInstalled = true;

                let lastHapticTime = 0;
                const triggerHaptic = () => {
                    const now = Date.now();
                    if (now - lastHapticTime < 80) { return; }

                    lastHapticTime = now;
                    window.webkit.messageHandlers.rudiFoodiHaptic.postMessage('click');
                };

                document.addEventListener('pointerdown', triggerHaptic, true);
                document.addEventListener('click', triggerHaptic, true);
            })();
            """,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: false
        )

        private let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard message.name == Self.hapticMessageName else {
                return
            }

            feedbackGenerator.prepare()
            feedbackGenerator.impactOccurred()
        }
    }
}
