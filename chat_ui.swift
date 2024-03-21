//
//  chat_ui.swift
//  connection_app
//
//  Created by Adam Barta on 03.03.2024.
//

import Foundation
import SwiftUI
import MultipeerConnectivity

@available(iOS 16.0, *)
struct chat_ui: View {
    @EnvironmentObject private var chat: ChatManager
    let person: Person
    
    @State private var newMessage: String = ""
    
    //@available(iOS 16.0, *)
    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { scrollView in
                VStack {
                    ScrollView {
                        VStack(spacing: 4) {
                            ForEach(chat.chats[person]!.messages,id:\.id){ message in
                                ChatMessageRow(message: message,geo:geometry)
                                    .padding(.horizontal)
                            }
                        }
                    }
                    .onChange(of: chat.chats[person]!.messages){new in
                        DispatchQueue.main.async {
                            if let last = chat.chats[person]!.messages.last{
                                withAnimation(.spring()){
                                    scrollView.scrollTo(last.id)
                                }
                            }else{
                                print(":error:")
                            }
                        }
                    }
                    
                    HStack {
                        
                        TextField("Enter a message", text: $newMessage, axis: .vertical)
                            .textFieldStyle(TxtField())
                            .padding(.horizontal)
                            .onAppear {
                                withAnimation(.spring()) {
                                }
                            }

                        if !newMessage.isEmpty {
                            Button {
                                if(!newMessage.isEmpty){
                                    DispatchQueue.main.async {
                                        chat.send(newMessage, chat: chat.chats[person]!)
                                        newMessage = ""
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                                       if let last = chat.chats[person]!.messages.last{
                                           print("scroll")
                                           withAnimation(.spring()){
                                               scrollView.scrollTo(last.id)
                                           }
                                       }else{
                                           print(":error:")
                                       }
                                    }
                                    
                               }
                            } label: {
                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.blue)
                            }
                            .onAppear(){
                                withAnimation(.spring()) {
                                }
                            }

                        }
                    }
                    .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
    
}

struct TxtField: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(10)
            .background(Color.gray.opacity(0.5))
            .cornerRadius(0)
            .foregroundColor(.primary)
    }
}
