//
//  CalendarView.swift
//  MotivationApp
//
//  Created on 2025-12-09.
//

import SwiftUI

struct CalendarView: View {
    @StateObject private var viewModel = CalendarViewModel()
    
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    let weekDays = ["日", "一", "二", "三", "四", "五", "六"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 统计信息
                    HStack(spacing: 20) {
                        StatCard(
                            icon: "flame.fill",
                            title: "连续打卡",
                            value: "\(viewModel.consecutiveDays)",
                            unit: "天",
                            color: .orange
                        )
                        
                        StatCard(
                            icon: "checkmark.circle.fill",
                            title: "总打卡",
                            value: "\(viewModel.checkInRecords.count)",
                            unit: "天",
                            color: .green
                        )
                    }
                    .padding(.horizontal)
                    
                    // 日历
                    VStack(spacing: 16) {
                        // 月份切换
                        HStack {
                            Button(action: {
                                viewModel.previousMonth()
                            }) {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(.primary)
                            }
                            
                            Spacer()
                            
                            Text(viewModel.monthYearString())
                                .font(.headline)
                            
                            Spacer()
                            
                            Button(action: {
                                viewModel.nextMonth()
                            }) {
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.primary)
                            }
                        }
                        .padding(.horizontal)
                        
                        // 星期标题
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(weekDays, id: \.self) { day in
                                Text(day)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        
                        // 日期网格
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(viewModel.getDaysInMonth(), id: \.self) { date in
                                DayCell(
                                    date: date,
                                    isCheckedIn: viewModel.isCheckedIn(on: date),
                                    isToday: date.isToday()
                                )
                            }
                        }
                    }
                    .padding()
                    .cardStyle()
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.top)
            }
            .navigationTitle("打卡日历")
        }
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(unit)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .cardStyle()
    }
}

struct DayCell: View {
    let date: Date
    let isCheckedIn: Bool
    let isToday: Bool
    
    var body: some View {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        
        ZStack {
            if isCheckedIn {
                Circle()
                    .fill(Color.green.opacity(0.2))
                
                Circle()
                    .stroke(Color.green, lineWidth: 2)
            }
            
            if isToday {
                Circle()
                    .stroke(Color(hex: "#FF6B6B") ?? .red, lineWidth: 2)
            }
            
            Text("\(day)")
                .font(.subheadline)
                .foregroundColor(isCheckedIn ? .green : .primary)
                .fontWeight(isToday ? .bold : .regular)
        }
        .frame(width: 40, height: 40)
    }
}

#Preview {
    CalendarView()
        .environmentObject(DataManager.shared)
}
