import Foundation
import SwiftUI
import MultipeerConnectivity

struct TxtField: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(10)
            .background(Color.gray.opacity(0.5))
            .cornerRadius(0)
            .foregroundColor(.primary)
    }
}

@available(iOS 16.0, *)
struct chat_ui: View {
    @EnvironmentObject private var chat: ChatManager
    let person: Person  // This can represent the individual or the group chat person

    @State private var newMessage: String = ""
    @State private var isGroupChatSelected = false

    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { scrollView in
                VStack {
                    Toggle("Group Chat", isOn: $isGroupChatSelected)
                        .padding()

                    ScrollView {
                        VStack(spacing: 4) {
                            ForEach(chatToShow().messages, id: \.id) { message in
                                ChatMessageRow(message: message, geo: geometry)
                                    .padding(.horizontal)
                            }
                        }
                    }
                    .onChange(of: chat.chats.flatMap({ $0.value.messages }).count) { _ in
                        if isGroupChatSelected {
                            if let last = chat.groupChat.messages.last {
                                withAnimation {
                                    scrollView.scrollTo(last.id, anchor: .bottom)
                                }
                            }
                        }
                    }

                    messageInputSection(scrollView: scrollView)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    // Determine which chat to show
    func chatToShow() -> Chat {
        isGroupChatSelected ? chat.groupChat : chat.chats[person]!
    }

    // Message input section view
    @ViewBuilder
    func messageInputSection(scrollView: ScrollViewProxy) -> some View {
        HStack {
            TextField("Enter a message", text: $newMessage, axis: .vertical)
                .textFieldStyle(TxtField())
                .padding(.horizontal)

            if !newMessage.isEmpty {
                Button {
                    chat.send(newMessage, chat: chatToShow())
                    newMessage = ""
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
    }
}

