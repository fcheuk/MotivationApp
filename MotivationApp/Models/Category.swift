//
//  Category.swift
//  MotivationApp
//
//  Created on 2025-12-09.
//

import Foundation
import SwiftUI

enum CategoryType: String, Codable {
    case normal
    case combined
    case seasonal
}

struct Category: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var icon: String
    var colorHex: String
    var description: String
    var imageName: String?
    var type: CategoryType
    var isNew: Bool
    var isFeatured: Bool
    var tags: [String]
    
    init(
        id: UUID = UUID(),
        name: String,
        icon: String,
        colorHex: String,
        description: String,
        imageName: String? = nil,
        type: CategoryType = .normal,
        isNew: Bool = false,
        isFeatured: Bool = false,
        tags: [String] = []
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
        self.description = description
        self.imageName = imageName
        self.type = type
        self.isNew = isNew
        self.isFeatured = isFeatured
        self.tags = tags
    }
    
    var color: Color {
        Color(hex: colorHex) ?? .blue
    }
}

// MARK: - Sample Data
extension Category {
    static let sampleCategories: [Category] = [
        Category(
            name: "动画",
            icon: "play.circle.fill",
            colorHex: "#4A90E2",
            description: "动态主题组合",
            imageName: "theme_animation",
            type: .combined,
            isNew: false,
            isFeatured: true,
            tags: ["组合"]
        ),
        Category(
            name: "季节",
            icon: "leaf.fill",
            colorHex: "#7ED321",
            description: "四季主题",
            imageName: "theme_season",
            type: .combined,
            isNew: false,
            isFeatured: true,
            tags: ["组合", "季节"]
        ),
        Category(
            name: "动力",
            icon: "flame.fill",
            colorHex: "#FF6B6B",
            description: "激励你追求梦想",
            imageName: "theme_motivation_1",
            type: .normal,
            isNew: true,
            isFeatured: true,
            tags: ["推荐", "新"]
        ),
        Category(
            name: "动力",
            icon: "flame.fill",
            colorHex: "#F5A623",
            description: "激发内在动力",
            imageName: "theme_motivation_2",
            type: .normal,
            isNew: false,
            isFeatured: true,
            tags: ["推荐"]
        ),
        Category(
            name: "动力",
            icon: "flame.fill",
            colorHex: "#FF8C42",
            description: "保持前进动力",
            imageName: "theme_motivation_3",
            type: .normal,
            isNew: false,
            isFeatured: true,
            tags: ["推荐"]
        ),
        Category(
            name: "动力",
            icon: "flame.fill",
            colorHex: "#FFB84D",
            description: "持续动力源泉",
            imageName: "theme_motivation_4",
            type: .normal,
            isNew: false,
            isFeatured: true,
            tags: ["推荐"]
        ),
        Category(
            name: "动力",
            icon: "flame.fill",
            colorHex: "#5B9BD5",
            description: "冬日动力",
            imageName: "theme_motivation_5",
            type: .normal,
            isNew: false,
            isFeatured: true,
            tags: ["推荐"]
        ),
        Category(
            name: "动力",
            icon: "flame.fill",
            colorHex: "#2C3E50",
            description: "夜间动力",
            imageName: "theme_motivation_6",
            type: .normal,
            isNew: false,
            isFeatured: true,
            tags: ["推荐"]
        )
    ]
}
