//
//  CategoryViewModel.swift
//  MotivationApp
//
//  Created on 2025-12-09.
//

import Foundation
import Combine

class CategoryViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var selectedCategory: Category?
    @Published var quotesInCategory: [Quote] = []
    
    private let dataManager: DataManager
    private var cancellables = Set<AnyCancellable>()
    
    init(dataManager: DataManager = .shared) {
        self.dataManager = dataManager
        
        // 监听分类数据变化
        dataManager.$categories
            .assign(to: &$categories)
    }
    
    func selectCategory(_ category: Category) {
        selectedCategory = category
        loadQuotesForCategory(category)
    }
    
    func loadQuotesForCategory(_ category: Category) {
        quotesInCategory = dataManager.getQuotes(for: category.id)
    }
    
    func getQuoteCount(for category: Category) -> Int {
        return dataManager.getQuotes(for: category.id).count
    }
}
