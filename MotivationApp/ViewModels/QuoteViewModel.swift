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
    
    private let dataManager: DataManager
    private var cancellables = Set<AnyCancellable>()
    
    init(dataManager: DataManager = .shared) {
        self.dataManager = dataManager
        
        // 监听数据变化
        dataManager.$quotes
            .assign(to: &$quotes)
        
        // 加载随机语录
        loadRandomQuote()
    }
    
    func loadRandomQuote() {
        currentQuote = dataManager.getRandomQuote()
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
