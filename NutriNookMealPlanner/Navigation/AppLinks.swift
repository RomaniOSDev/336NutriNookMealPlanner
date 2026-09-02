import StoreKit
import UIKit

enum AppLinks {
    static let privacy = "https://nutrinookmealplanner336.site/privacy/440"
    static let terms = "https://nutrinookmealplanner336.site/terms/440"

    static func open(_ string: String) {
        if let url = URL(string: string) {
            UIApplication.shared.open(url)
        }
    }

    static func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}
