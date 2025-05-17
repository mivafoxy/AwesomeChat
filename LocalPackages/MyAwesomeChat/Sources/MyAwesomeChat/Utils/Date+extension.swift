//
//  Date+extension.swift
//  
//
//  Created by Илья Малахов on 04.02.2025.
//

import Foundation

extension Date {
    func startOfDay() -> Date {
        var calendar = Calendar.current
        if let timeZone = TimeZone(identifier: "UTC") {
            calendar.timeZone = timeZone
        }
        return calendar.startOfDay(for: self)
    }
}
