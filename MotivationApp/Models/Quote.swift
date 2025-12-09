//
//  Quote.swift
//  MotivationApp
//
//  Created on 2025-12-09.
//

import Foundation

struct Quote: Identifiable, Codable, Hashable {
    var id: UUID
    var content: String
    var author: String
    var categoryId: UUID
    var isFavorite: Bool
    var createdDate: Date
    
    init(
        id: UUID = UUID(),
        content: String,
        author: String,
        categoryId: UUID,
        isFavorite: Bool = false,
        createdDate: Date = Date()
    ) {
        self.id = id
        self.content = content
        self.author = author
        self.categoryId = categoryId
        self.isFavorite = isFavorite
        self.createdDate = createdDate
    }
}

// MARK: - Sample Data
extension Quote {
    static let sampleQuotes: [Quote] = [
        Quote(
            content: "成功不是终点，失败也不是终结，唯有勇气才是永恒。",
            author: "温斯顿·丘吉尔",
            categoryId: Category.sampleCategories[0].id
        ),
        Quote(
            content: "相信自己，你比想象中更强大。",
            author: "佚名",
            categoryId: Category.sampleCategories[1].id
        ),
        Quote(
            content: "每一个不曾起舞的日子，都是对生命的辜负。",
            author: "尼采",
            categoryId: Category.sampleCategories[2].id
        )
    ]
}
