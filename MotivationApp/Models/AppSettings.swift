//
//  AppSettings.swift
//  MotivationApp
//
//  Created on 2025-12-09.
//

import Foundation
import SwiftUI

struct AppSettings: Codable {
    var notificationsEnabled: Bool
    var notificationTime: Date
    var selectedTheme: AppTheme
    var fontSize: FontSize
    var isSubscribed: Bool
    var subscriptionExpiryDate: Date?
    
    init(
        notificationsEnabled: Bool = false,
        notificationTime: Date = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date(),
        selectedTheme: AppTheme = .system,
        fontSize: FontSize = .medium,
        isSubscribed: Bool = false,
        subscriptionExpiryDate: Date? = nil
    ) {
        self.notificationsEnabled = notificationsEnabled
        self.notificationTime = notificationTime
        self.selectedTheme = selectedTheme
        self.fontSize = fontSize
        self.isSubscribed = isSubscribed
        self.subscriptionExpiryDate = subscriptionExpiryDate
    }
    
    var hasActiveSubscription: Bool {
        guard isSubscribed else { return false }
        if let expiryDate = subscriptionExpiryDate {
            return expiryDate > Date()
        }
        return true
    }
}

enum AppTheme: String, Codable, CaseIterable {
    case light = "浅色"
    case dark = "深色"
    case system = "跟随系统"
    
    var colorScheme: ColorScheme? {
        switch self {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return nil
        }
    }
}

enum FontSize: String, Codable, CaseIterable {
    case small = "小"
    case medium = "中"
    case large = "大"
    
    var scale: CGFloat {
        switch self {
        case .small:
            return 0.9
        case .medium:
            return 1.0
        case .large:
            return 1.2
        }
    }
}
