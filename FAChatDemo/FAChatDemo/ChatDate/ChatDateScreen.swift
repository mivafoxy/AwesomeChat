//
//  ChatDateScreen.swift
//  FAChatDemo
//
//  Created by Илья Малахов on 01.11.2024.
//

import SwiftUI
import MRDSKit
import FAChat

struct ChatDateScreen: View {
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ChatDate(text: "21 июля")
                ChatDate(text: "Сегодня")
            }
        }
    }
}
