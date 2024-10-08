import SwiftUI
import AlertToast

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool { return true }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        if connectingSceneSession.role == .windowApplication {
            configuration.delegateClass = SceneDelegate.self
        }
        return configuration
    }
}

final class SceneDelegate: NSObject, UIWindowSceneDelegate {

    var secondaryWindow: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let windowScene = scene as? UIWindowScene {
            setupSecondaryOverlayWindow(in: windowScene)
        }
    }

    func setupSecondaryOverlayWindow(in scene: UIWindowScene) {
        let secondaryViewController = UIHostingController(
            rootView:
                EmptyView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .modifier(InAppNotificationViewModifier())
                    .environmentObject(ToastProvider.shared)
        )
        secondaryViewController.view.backgroundColor = .clear
        let secondaryWindow = PassThroughWindow(windowScene: scene)
        secondaryWindow.rootViewController = secondaryViewController
        secondaryWindow.isHidden = false
        self.secondaryWindow = secondaryWindow
    }
}

class PassThroughWindow: UIWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let hitView = super.hitTest(point, with: event)
        else { return nil }

        return rootViewController?.view == hitView ? nil : hitView
    }
}

struct InAppNotificationViewModifier: ViewModifier {
    
    @EnvironmentObject private var toastProvider: ToastProvider
    
    func body(content: Content) -> some View {
        content
            .toast(isPresenting: $toastProvider.presenting, duration: 2, tapToDismiss: true) {
                toastProvider.toast ?? AlertToast(type: .regular)
            }
      }
}
