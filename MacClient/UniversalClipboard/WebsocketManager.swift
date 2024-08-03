import Combine
import Network
import SwiftUI

class WebsocketManager: NSObject {

    private let WEBSOCKET_URL = "ws://0.tcp.ngrok.io:17895"

    private let session = URLSession(configuration: .default)
    private var wsTask: URLSessionWebSocketTask?
    private var stream: SocketStream?

    private let monitor = NWPathMonitor()

    private let pasteboard = NSPasteboard.general
    private var pingTryCount = 0

    let connectionStateSubject = CurrentValueSubject<Bool, Never>(false)
    var isConnected: Bool { connectionStateSubject.value }

    func connect() {
        let url = URL(string: WEBSOCKET_URL)!

        let request = URLRequest(url: url)

        wsTask = session.webSocketTask(with: request)
        wsTask?.delegate = self

        if let wsTask {
            stream = SocketStream(task: wsTask)
        }

        recieveMessage()
        schedulePing()
    }

    func startMonitorNetworkConnectivity() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }

            if path.status == .satisfied, wsTask == nil {
                self.connect()
            }

            if path.status != .satisfied {
                self.clearConnection()
            }
        }
        monitor.start(queue: .main)
    }

    func clearConnection() {
        wsTask?.cancel()
        wsTask = nil
        pingTryCount = 0
        connectionStateSubject.send(false)
    }

    func sendMessage(_ message: String) {
        Task {
            do {
                try await wsTask?.send(.string(message))
            } catch {
                print(error)
            }
        }
    }

    private func recieveMessage() {
        guard let stream else { return }

        Task {
            do {
                for try await message in stream {
                    decodeData(from: message)
                }
            } catch {
                print(error)
            }
        }
    }

    private func schedulePing() {
        let identifier = wsTask?.taskIdentifier ?? -1

        Task {
            try? await Task.sleep(for: .seconds(60*5))
            guard let task = wsTask, task.taskIdentifier == identifier else { return }

            if task.state == .running, pingTryCount < 2 {
                pingTryCount += 1
                print("Sent Ping \(pingTryCount)")
                task.sendPing { [weak self] error in
                    if let error {
                        print("Ping failed: \(error)")
                    } else if self?.wsTask?.taskIdentifier == identifier {
                        self?.pingTryCount = 0
                    }
                }
                schedulePing()
            } else {
                reconnect()
            }
        }
    }

    private func decodeData(from message: URLSessionWebSocketTask.Message) {
        switch message {
        case .data(let data):
            if let text = String(data: data, encoding: .utf8) {
                copyToClipboard(text)
            }
        case .string(let string):
            copyToClipboard(string)
        default:
            print("unkown message received")
            break
        }
    }

    private func copyToClipboard(_ string: String) {
        pasteboard.clearContents()
        pasteboard.setString(string, forType: .string)
    }

    private func reconnect() {
        clearConnection()
        connect()
    }

    // just some house-keeping - not really necessary for this app
    // indicates to all subscribers that this value won't emit again
    deinit {
        connectionStateSubject.send(completion: .finished)
    }
}

extension WebsocketManager: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        connectionStateSubject.send(true)
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        connectionStateSubject.send(false)
    }
}
