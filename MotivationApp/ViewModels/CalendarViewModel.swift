//
//  CalendarViewModel.swift
//  MotivationApp
//
//  Created on 2025-12-09.
//

import Foundation
import Combine

class CalendarViewModel: ObservableObject {
    @Published var checkInRecords: [CheckInRecord] = []
    @Published var selectedDate: Date = Date()
    @Published var consecutiveDays: Int = 0
    @Published var currentMonth: Date = Date()
    
    private let dataManager: DataManager
    private var cancellables = Set<AnyCancellable>()
    
    init(dataManager: DataManager = .shared) {
        self.dataManager = dataManager
        
        // 监听打卡记录变化
        dataManager.$checkInRecords
            .sink { [weak self] records in
                self?.checkInRecords = records
                self?.consecutiveDays = CheckInRecord.consecutiveDays(records: records)
            }
            .store(in: &cancellables)
    }
    
    func isCheckedIn(on date: Date) -> Bool {
        return CheckInRecord.isCheckedIn(on: date, records: checkInRecords)
    }
    
    func checkIn() {
        dataManager.checkIn()
    }
    
    func getDaysInMonth() -> [Date] {
        let calendar = Calendar.current
        let interval = calendar.dateInterval(of: .month, for: currentMonth)!
        let days = calendar.dateComponents([.day], from: interval.start, to: interval.end).day!
        
        return (0..<days).compactMap { day in
            calendar.date(byAdding: .day, value: day, to: interval.start)
        }
    }
    
    func previousMonth() {
        let calendar = Calendar.current
        if let newMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = newMonth
        }
    }
    
    func nextMonth() {
        let calendar = Calendar.current
        if let newMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = newMonth
        }
    }
    
    func monthYearString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年 M月"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: currentMonth)
    }
}
