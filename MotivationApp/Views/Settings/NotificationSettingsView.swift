//
//  NotificationSettingsView.swift
//  MotivationApp
//
//  Created on 2025-12-09.
//

import SwiftUI

struct NotificationSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var notificationManager: NotificationManager
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Toggle("启用每日提醒", isOn: $dataManager.settings.notificationsEnabled)
                        .onChange(of: dataManager.settings.notificationsEnabled) { enabled in
                            handleNotificationToggle(enabled)
                        }
                } footer: {
                    Text("每天定时推送一条激励语录")
                }
                
                if dataManager.settings.notificationsEnabled {
                    Section("提醒时间") {
                        DatePicker(
                            "时间",
                            selection: $dataManager.settings.notificationTime,
                            displayedComponents: .hourAndMinute
                        )
                        .onChange(of: dataManager.settings.notificationTime) { time in
                            scheduleNotification(at: time)
                        }
                    }
                }
            }
            .navigationTitle("通知设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func handleNotificationToggle(_ enabled: Bool) {
        if enabled {
            Task {
                let granted = await notificationManager.requestAuthorization()
                if granted {
                    scheduleNotification(at: dataManager.settings.notificationTime)
                } else {
                    // 权限被拒绝，关闭开关
                    await MainActor.run {
                        dataManager.settings.notificationsEnabled = false
                    }
                }
                dataManager.saveSettings()
            }
        } else {
            notificationManager.cancelAllNotifications()
            dataManager.saveSettings()
        }
    }
    
    private func scheduleNotification(at time: Date) {
        if let randomQuote = dataManager.getRandomQuote() {
            notificationManager.scheduleDailyNotification(
                at: time,
                quote: randomQuote.content
            )
        }
        dataManager.saveSettings()
    }
}

#Preview {
    NotificationSettingsView()
        .environmentObject(DataManager.shared)
        .environmentObject(NotificationManager.shared)
}
