import ApplyKeysCore
import SwiftUI
import UIKit

final class KeyboardViewController: UIInputViewController, TextInserting {
    private var controller: KeyboardController!

    override func viewDidLoad() {
        super.viewDidLoad()

        controller = KeyboardController(
            storage: AppGroup.storage ?? InMemoryStorage(),
            inserter: self,
            hasFullAccess: { [weak self] in self?.hasFullAccess ?? false }
        )

        let panel = KeyboardView(
            controller: controller,
            showsNextKeyboardKey: needsInputModeSwitchKey,
            nextKeyboard: { [weak self] in self?.advanceToNextInputMode() }
        )
        let host = UIHostingController(rootView: panel)
        host.view.backgroundColor = .clear
        host.view.translatesAutoresizingMaskIntoConstraints = false
        addChild(host)
        view.addSubview(host.view)
        NSLayoutConstraint.activate([
            host.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            host.view.topAnchor.constraint(equalTo: view.topAnchor),
            host.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            view.heightAnchor.constraint(equalToConstant: 270),
        ])
        host.didMove(toParent: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        controller.reload()
    }

    func insertText(_ text: String) {
        textDocumentProxy.insertText(text)
    }

    func deleteBackward() {
        textDocumentProxy.deleteBackward()
    }
}
