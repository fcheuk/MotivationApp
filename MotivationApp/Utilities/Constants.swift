//
//  Constants.swift
//  MotivationApp
//
//  Created on 2025-12-09.
//

import Foundation
import SwiftUI

enum Constants {
    // MARK: - UserDefaults Keys
    enum UserDefaultsKeys {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let appSettings = "appSettings"
        static let quotes = "quotes"
        static let categories = "categories"
        static let checkInRecords = "checkInRecords"
    }
    
    // MARK: - Notification
    enum Notification {
        static let identifier = "dailyQuoteNotification"
        static let title = "每日激励"
        static let categoryIdentifier = "QUOTE_CATEGORY"
    }
    
    // MARK: - UI Constants
    enum UI {
        static let cornerRadius: CGFloat = 16
        static let padding: CGFloat = 16
        static let cardPadding: CGFloat = 20
        static let iconSize: CGFloat = 24
        static let categoryCardSize: CGFloat = 100
    }
    
    // MARK: - Animation
    enum Animation {
        static let defaultDuration: Double = 0.3
        static let springResponse: Double = 0.5
        static let springDamping: Double = 0.7
    }
}
