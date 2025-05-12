//
//  DateMessageGroup.swift
//  
//
//  Created by Илья Малахов on 22.11.2024.
//

import Foundation

struct DateMessageGroup: Identifiable, Equatable {
    let id: String
    let date: Date
    var userMessageGroups: [MessageGroup]
    
    var textedDate: String {
        let calendar = Calendar.current
        
        let currentDate = Date()
        let currentDay = calendar.component(.day, from: currentDate)
        let currentMonth = calendar.component(.month, from: currentDate)
        let currentYear = calendar.component(.year, from: currentDate)
        
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        
        if
            currentDay == day,
            currentMonth == month,
            currentYear == year {
            
            return "chat_today".localized
        } else {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ru_RU")
            formatter.dateFormat = "dd MMMM"
            return formatter.string(from: date)
        }
    }
    
    static func == (lhs: DateMessageGroup, rhs: DateMessageGroup) -> Bool {
        lhs.id == rhs.id &&
        lhs.date.startOfDay() == rhs.date.startOfDay() &&
        lhs.userMessageGroups == rhs.userMessageGroups
    }
}
