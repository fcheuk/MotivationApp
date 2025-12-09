//
//  DataManager.swift
//  MotivationApp
//
//  Created on 2025-12-09.
//

import Foundation
import Combine

class DataManager: ObservableObject {
    static let shared = DataManager()
    
    @Published var quotes: [Quote] = []
    @Published var categories: [Category] = []
    @Published var checkInRecords: [CheckInRecord] = []
    @Published var settings: AppSettings = AppSettings()
    
    private let userDefaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private init() {
        loadData()
    }
    
    // MARK: - Load Data
    func loadData() {
        loadCategories()
        loadQuotes()
        loadCheckInRecords()
        loadSettings()
    }
    
    private func loadCategories() {
        if let data = userDefaults.data(forKey: Constants.UserDefaultsKeys.categories),
           let decoded = try? decoder.decode([Category].self, from: data) {
            categories = decoded
        } else {
            // 首次启动，使用默认数据
            categories = Category.sampleCategories
            saveCategories()
        }
    }
    
    private func loadQuotes() {
        if let data = userDefaults.data(forKey: Constants.UserDefaultsKeys.quotes),
           let decoded = try? decoder.decode([Quote].self, from: data) {
            quotes = decoded
        } else {
            // 首次启动，加载默认语录
            loadDefaultQuotes()
        }
    }
    
    private func loadCheckInRecords() {
        if let data = userDefaults.data(forKey: Constants.UserDefaultsKeys.checkInRecords),
           let decoded = try? decoder.decode([CheckInRecord].self, from: data) {
            checkInRecords = decoded
        }
    }
    
    private func loadSettings() {
        if let data = userDefaults.data(forKey: Constants.UserDefaultsKeys.appSettings),
           let decoded = try? decoder.decode(AppSettings.self, from: data) {
            settings = decoded
        }
    }
    
    // MARK: - Save Data
    func saveCategories() {
        if let encoded = try? encoder.encode(categories) {
            userDefaults.set(encoded, forKey: Constants.UserDefaultsKeys.categories)
        }
    }
    
    func saveQuotes() {
        if let encoded = try? encoder.encode(quotes) {
            userDefaults.set(encoded, forKey: Constants.UserDefaultsKeys.quotes)
        }
    }
    
    func saveCheckInRecords() {
        if let encoded = try? encoder.encode(checkInRecords) {
            userDefaults.set(encoded, forKey: Constants.UserDefaultsKeys.checkInRecords)
        }
    }
    
    func saveSettings() {
        if let encoded = try? encoder.encode(settings) {
            userDefaults.set(encoded, forKey: Constants.UserDefaultsKeys.appSettings)
        }
    }
    
    // MARK: - Quote Operations
    func toggleFavorite(quote: Quote) {
        if let index = quotes.firstIndex(where: { $0.id == quote.id }) {
            quotes[index].isFavorite.toggle()
            saveQuotes()
        }
    }
    
    func getRandomQuote() -> Quote? {
        return quotes.randomElement()
    }
    
    func getQuotes(for categoryId: UUID) -> [Quote] {
        return quotes.filter { $0.categoryId == categoryId }
    }
    
    func getFavoriteQuotes() -> [Quote] {
        return quotes.filter { $0.isFavorite }
    }
    
    // MARK: - Check-in Operations
    func checkIn() {
        let today = Date().startOfDay()
        
        // 检查今天是否已打卡
        if !CheckInRecord.isCheckedIn(on: today, records: checkInRecords) {
            let record = CheckInRecord(date: today, quotesRead: 1)
            checkInRecords.append(record)
            saveCheckInRecords()
        }
    }
    
    func getConsecutiveDays() -> Int {
        return CheckInRecord.consecutiveDays(records: checkInRecords)
    }
    
    // MARK: - Load Default Quotes
    private func loadDefaultQuotes() {
        // 从 JSON 文件加载或使用示例数据
        if let url = Bundle.main.url(forResource: "quotes", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let decoded = try? decoder.decode([Quote].self, from: data) {
            quotes = decoded
        } else {
            quotes = Quote.sampleQuotes
        }
        saveQuotes()
    }
}
