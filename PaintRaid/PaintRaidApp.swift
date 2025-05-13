import SwiftUI
import WebKit

@main
struct PaintRaidApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
} 


struct RootView: View {
    @State private var isLoading = true
    @State private var showWebView = false
    @State private var showContentView = false
    @State private var serverLink: String = ""
    @State private var showNavigationButtons = false
    @State private var webView: WKWebView? = nil

    private let serverURL = "https://paintraidapplicati.homes/paintraid"
    private let checkKeyword = "ballraidpaints"

    var body: some View {
        Group {
            if isLoading {
                Color.black.ignoresSafeArea()
            }
            else if showWebView, let link = URL(string: serverLink) {
                VStack(spacing: 0) {
                    WebView(url: link, webView: $webView)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    if showNavigationButtons {
                        HStack(spacing: 16) {
                            Button(action: {
                                if webView?.canGoBack == true {
                                    webView?.goBack()
                                }
                            }) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 18))
                                    .foregroundColor(.white)
                                    .frame(width: 44, height: 44)
                                    .background(Color.gray)
                                    .clipShape(Circle())
                            }

                            Button(action: {
                                if let url = URL(string: serverLink) {
                                    webView?.load(URLRequest(url: url))
                                }
                            }) {
                                Image(systemName: "house")
                                    .font(.system(size: 18))
                                    .foregroundColor(.white)
                                    .frame(width: 44, height: 44)
                                    .background(Color.gray)
                                    .clipShape(Circle())
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.black)
                    }
                }
                .ignoresSafeArea(.keyboard)
                .background(Color.black)
            }
            else if showContentView {
                ContentView()
            }
            else {
                Color.black.ignoresSafeArea()
            }
        }
        .onAppear { checkServer() }
    }

    func checkServer() {
        guard let url = URL(string: serverURL) else {
            isLoading = false
            showContentView = true
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            DispatchQueue.main.async {
                isLoading = false
                guard
                    let data = data,
                    let text = String(data: data, encoding: .utf8)
                else {
                    showContentView = true
                    return
                }

                if text.contains(checkKeyword) {
                    let parts = text
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                        .components(separatedBy: "|")
                    serverLink = parts[0]
                    showNavigationButtons = parts.count > 1 && !parts[1].isEmpty
                    showWebView = true
                } else {
                    showContentView = true
                }
            }
        }.resume()
    }
}

struct WebView: UIViewRepresentable {
    let url: URL
    @Binding var webView: WKWebView?

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        let wkWebView = WKWebView(frame: .zero, configuration: configuration)
        wkWebView.overrideUserInterfaceStyle = .dark
        wkWebView.allowsBackForwardNavigationGestures = true
        wkWebView.navigationDelegate = context.coordinator
        wkWebView.uiDelegate = context.coordinator
        wkWebView.load(URLRequest(url: url))
        DispatchQueue.main.async { self.webView = wkWebView }
        return wkWebView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.overrideUserInterfaceStyle = .dark
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        func webView(_ webView: WKWebView,
                     decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.url,
               let scheme = url.scheme?.lowercased(),
               !["http", "https"].contains(scheme) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        }
        // target="_blank"
        func webView(_ webView: WKWebView,
                     createWebViewWith configuration: WKWebViewConfiguration,
                     for navigationAction: WKNavigationAction,
                     windowFeatures: WKWindowFeatures) -> WKWebView? {
            if navigationAction.targetFrame == nil {
                webView.load(navigationAction.request)
            }
            return nil
        }
    }
}
