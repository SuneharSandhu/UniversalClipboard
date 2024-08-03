import Cocoa
import Combine
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {

    var statusItem: NSStatusItem!
    let popover = NSPopover()

    let websocketManager = WebsocketManager()

    private var menuBarImage = ""
    private var cancellables = Set<AnyCancellable>()

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupWebsocket()
        setupMenuBar()
        setupPopover()
        bindMenuBarImageToConnectionState()
    }

    func setupWebsocket() {
        websocketManager.connect()
        websocketManager.startMonitorNetworkConnectivity()
    }

    func bindMenuBarImageToConnectionState() {
        websocketManager.connectionStateSubject
            .receive(on: DispatchQueue.main)
            .map { $0 ? "ipad.and.iphone" : "ipad.and.iphone.slash" }
            .sink { [weak self] imageName in
                self?.updateMenuBarImage(imageName)
            }
            .store(in: &cancellables)
    }
}

// MARK: - Menu Bar
extension AppDelegate {
    func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: Constants.statusItemLength)
        guard let menuButton = statusItem.button else { return }

        menuButton.image = NSImage(
            systemSymbolName: menuBarImage,
            accessibilityDescription: nil
        )
        menuButton.action = #selector(menuButtonClicked)
    }

    @objc func menuButtonClicked() {
        if popover.isShown {
            popover.performClose(nil)
            return
        }

        guard let menuButton = statusItem.button else { return }

        // positioningView is for removing the arrow notch when showing popover
        let positioningView = NSView(frame: menuButton.bounds)
        positioningView.identifier = NSUserInterfaceItemIdentifier("positioningView")
        menuButton.addSubview(positioningView)

        popover.show(relativeTo: menuButton.bounds, of: menuButton, preferredEdge: .maxY)
        menuButton.bounds = menuButton.bounds.offsetBy(dx: 0, dy: menuButton.bounds.height)
        popover.contentViewController?.view.window?.makeKey()
    }

    private func updateMenuBarImage(_ imageName: String) {
        guard let menuButton = statusItem.button else { return }
        menuButton.image = NSImage(systemSymbolName: imageName, accessibilityDescription: nil)
    }

    private struct Constants {
        static var statusItemLength: CGFloat = 18
    }
}

// MARK: - Popover
extension AppDelegate: NSPopoverDelegate {
    func setupPopover() {
        popover.behavior = .transient
        popover.animates = true
        popover.contentSize = .init(width: 240, height: 280)
        popover.contentViewController = NSViewController()
        popover.contentViewController?.view = NSHostingView(
            rootView: PopoverView(websocketManager: websocketManager)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        )
        popover.delegate = self

        func popoverDidClose(_ notification: Notification) {
            let positioningView = statusItem.button?.subviews.first {
                $0.identifier == NSUserInterfaceItemIdentifier("positioningView")
            }
            positioningView?.removeFromSuperview()
        }
    }
}
