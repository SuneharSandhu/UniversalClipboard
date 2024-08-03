import SwiftUI

struct PopoverView: View {

    @State private var messageText = ""
    var websocketManager: WebsocketManager

    init(websocketManager: WebsocketManager) {
        self.websocketManager = websocketManager
    }

    var body: some View {
        VStack(spacing: 8) {
            Text("Universal Clipboard")
                .font(.title).bold()

            Spacer()

            TextField("", text: $messageText, axis: .vertical)
                .font(.system(size: 14))
                .lineLimit(5)

            Button("Send", action: sendMessageToServer)

            Spacer()

            Divider()

            Button("Quit") {
                NSApp.terminate(self)
            }
            .buttonStyle(DestructiveButtonStyle())
        }
        .padding()
    }

    private func sendMessageToServer() {
        guard !messageText.isEmpty else { return }
        websocketManager.sendMessage(messageText)
        messageText = ""
    }
}

// Destructive role property for button isnt working
struct DestructiveButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 4)
            .padding(.vertical, 4)
            .foregroundStyle(.white)
            .background(Color.red)
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

#Preview {
    PopoverView(websocketManager: WebsocketManager())
}
