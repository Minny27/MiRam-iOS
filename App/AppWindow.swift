import UIKit
import SwiftUI

final class AppWindow: UIWindow {
    override init(windowScene: UIWindowScene) {
        super.init(windowScene: windowScene)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with rootView: some View) {
        rootViewController = UIHostingController(rootView: rootView)
        makeKeyAndVisible()
    }
}
