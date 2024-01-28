//
//  Message_format.swift
//  connection_app
//
//  Created by Adam Barta on 23.01.2024.
//

import Foundation
import SwiftUI


struct ChatMessageRow: View {
    @EnvironmentObject private var model: ChatManager
    let message: Message
    let geo:GeometryProxy
    
    var isCurrentUser:Bool {
        message.from.id == model.myPerson.id
    }
    
    var body: some View {
        
        HStack(){
            if isCurrentUser {
                Spacer(minLength: geo.size.width * 0.2)
            }
            
            Text(message.text.trimmingCharacters(in: .whitespacesAndNewlines))
                .font(.system(size: 40))
                .multilineTextAlignment(isCurrentUser ? .trailing : .leading)
                .padding()
            
            if !isCurrentUser {
                Spacer(minLength: geo.size.width * 0.2)
            }
        }
    }
}

struct TFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .background(Color.blue.opacity(0.2))
            .padding(5)
            .cornerRadius(4)
            .foregroundColor(.primary)
    }
}
