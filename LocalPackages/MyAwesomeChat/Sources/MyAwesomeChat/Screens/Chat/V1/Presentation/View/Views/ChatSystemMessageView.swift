//
//  ChatSystemMessageView.swift
//  
//
//  Created by Илья Малахов on 05.03.2025.
//

import SwiftUI

struct ChatSystemMessageView: View {
    
    var userMessageGroup: MessageGroup
    
    var body: some View {
        ForEach(getSystemMessages(userMessageGroup), id: \.id) { message in
            ChatDialogStatus(text: message.content)
        }
    }
    
    private func getSystemMessages(_ userMessageGroup: MessageGroup) -> [SystemMessage] {
        userMessageGroup.messages.compactMap { message in
            if .finishDialog == message.message.messageType {
                return SystemMessage(id: message.id, content: "chat_dialog_end".localized)
            } else {
                return SystemMessage(message: message)
            }
        }
    }
}
