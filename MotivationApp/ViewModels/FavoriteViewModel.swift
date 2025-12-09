//
//  FavoriteViewModel.swift
//  MotivationApp
//
//  Created on 2025-12-09.
//

import Foundation
import Combine

class FavoriteViewModel: ObservableObject {
    @Published var favoriteQuotes: [Quote] = []
    
    private let dataManager: DataManager
    private var cancellables = Set<AnyCancellable>()
    
    init(dataManager: DataManager = .shared) {
        self.dataManager = dataManager
        
        // 监听语录数据变化，自动更新收藏列表
        dataManager.$quotes
            .map { quotes in
                quotes.filter { $0.isFavorite }
            }
            .assign(to: &$favoriteQuotes)
    }
    
    func removeFavorite(_ quote: Quote) {
        dataManager.toggleFavorite(quote: quote)
    }
    
    func getCategoryName(for quote: Quote) -> String {
        if let category = dataManager.categories.first(where: { $0.id == quote.categoryId }) {
            return category.name
        }
        return "未分类"
    }
}
