//
//  QuoteViewModel.swift
//  MotivationApp
//
//  Created on 2025-12-09.
//

import Foundation
import Combine

class QuoteViewModel: ObservableObject {
    @Published var currentQuote: Quote?
    @Published var quotes: [Quote] = []
    @Published var currentIndex: Int = 0
    
    private let dataManager: DataManager
    private var cancellables = Set<AnyCancellable>()
    
    init(dataManager: DataManager = .shared) {
        self.dataManager = dataManager
        
        // 监听数据变化
        dataManager.$quotes
            .sink { [weak self] newQuotes in
                self?.quotes = newQuotes
                // 确保索引有效
                if let self = self, !newQuotes.isEmpty {
                    self.currentIndex = min(self.currentIndex, newQuotes.count - 1)
                    self.currentQuote = newQuotes[self.currentIndex]
                }
            }
            .store(in: &cancellables)
        
        // 加载第一条语录
        loadInitialQuote()
    }
    
    func loadInitialQuote() {
        if !quotes.isEmpty {
            currentIndex = 0
            currentQuote = quotes[currentIndex]
        } else if let quote = dataManager.getRandomQuote() {
            currentQuote = quote
            if let index = dataManager.quotes.firstIndex(where: { $0.id == quote.id }) {
                currentIndex = index
                quotes = dataManager.quotes
            }
        }
    }
    
    func loadRandomQuote() {
        guard !quotes.isEmpty else {
            currentQuote = dataManager.getRandomQuote()
            return
        }
        currentIndex = Int.random(in: 0..<quotes.count)
        currentQuote = quotes[currentIndex]
    }
    
    /// 下一句（上滑触发）
    func nextQuote() {
        guard !quotes.isEmpty else { return }
        currentIndex = (currentIndex + 1) % quotes.count
        currentQuote = quotes[currentIndex]
    }
    
    /// 上一句（下滑触发）
    func previousQuote() {
        guard !quotes.isEmpty else { return }
        currentIndex = (currentIndex - 1 + quotes.count) % quotes.count
        currentQuote = quotes[currentIndex]
    }
    
    /// 获取下一句内容（用于预览，不改变当前索引）
    var nextQuoteContent: Quote? {
        guard !quotes.isEmpty else { return nil }
        let nextIndex = (currentIndex + 1) % quotes.count
        return quotes[nextIndex]
    }
    
    /// 获取上一句内容（用于预览，不改变当前索引）
    var previousQuoteContent: Quote? {
        guard !quotes.isEmpty else { return nil }
        let prevIndex = (currentIndex - 1 + quotes.count) % quotes.count
        return quotes[prevIndex]
    }
    
    func toggleFavorite() {
        guard let quote = currentQuote else { return }
        dataManager.toggleFavorite(quote: quote)
        // 更新当前语录的收藏状态
        if let updatedQuote = dataManager.quotes.first(where: { $0.id == quote.id }) {
            currentQuote = updatedQuote
        }
    }
    
    func shareQuote() -> String {
        guard let quote = currentQuote else { return "" }
        return "\"\(quote.content)\" - \(quote.author)"
    }
}
