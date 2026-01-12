//
//  CategoryViewModel.swift
//  MotivationApp
//
//  Created on 2025-12-09.
//

import Foundation
import Combine

enum CategoryFilter: String, CaseIterable {
    case all = "所有"
    case new = "新"
    case seasonal = "季节"
    case featured = "最受欢迎"
}

class CategoryViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var selectedCategory: Category?
    @Published var quotesInCategory: [Quote] = []
    @Published var selectedFilter: CategoryFilter = .all
    
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
    
    func setFilter(_ filter: CategoryFilter) {
        selectedFilter = filter
    }
    
    var combinedThemes: [Category] {
        return categories.filter { $0.type == .combined }
    }
    
    var filteredCategories: [Category] {
        let normalCategories = categories.filter { $0.type == .normal }
        
        switch selectedFilter {
        case .all:
            return normalCategories
        case .new:
            return normalCategories.filter { $0.isNew }
        case .seasonal:
            return normalCategories.filter { $0.tags.contains("季节") }
        case .featured:
            return normalCategories.filter { $0.isFeatured }
        }
    }
}
