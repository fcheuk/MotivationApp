//
//  CheckInRecord.swift
//  MotivationApp
//
//  Created on 2025-12-09.
//

import Foundation

struct CheckInRecord: Identifiable, Codable, Hashable {
    var id: UUID
    var date: Date
    var quotesRead: Int
    var notes: String?
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        quotesRead: Int = 0,
        notes: String? = nil
    ) {
        self.id = id
        self.date = date
        self.quotesRead = quotesRead
        self.notes = notes
    }
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

// MARK: - Helper Methods
extension CheckInRecord {
    static func isCheckedIn(on date: Date, records: [CheckInRecord]) -> Bool {
        let calendar = Calendar.current
        return records.contains { record in
            calendar.isDate(record.date, inSameDayAs: date)
        }
    }
    
    static func consecutiveDays(records: [CheckInRecord]) -> Int {
        guard !records.isEmpty else { return 0 }
        
        let sortedRecords = records.sorted { $0.date > $1.date }
        let calendar = Calendar.current
        var count = 0
        var currentDate = Date()
        
        for record in sortedRecords {
            if calendar.isDate(record.date, inSameDayAs: currentDate) {
                count += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }
        
        return count
    }
}
