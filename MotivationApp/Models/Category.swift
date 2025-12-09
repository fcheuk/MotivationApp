//
//  Category.swift
//  MotivationApp
//
//  Created on 2025-12-09.
//

import Foundation
import SwiftUI

struct Category: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var icon: String
    var colorHex: String
    var description: String
    
    init(
        id: UUID = UUID(),
        name: String,
        icon: String,
        colorHex: String,
        description: String
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
        self.description = description
    }
    
    var color: Color {
        Color(hex: colorHex) ?? .blue
    }
}

// MARK: - Sample Data
extension Category {
    static let sampleCategories: [Category] = [
        Category(
            name: "励志",
            icon: "flame.fill",
            colorHex: "#FF6B6B",
            description: "激励你追求梦想"
        ),
        Category(
            name: "自信",
            icon: "star.fill",
            colorHex: "#4ECDC4",
            description: "建立自信心"
        ),
        Category(
            name: "生活",
            icon: "heart.fill",
            colorHex: "#95E1D3",
            description: "感悟生活智慧"
        ),
        Category(
            name: "学习",
            icon: "book.fill",
            colorHex: "#F38181",
            description: "激发学习动力"
        ),
        Category(
            name: "工作",
            icon: "briefcase.fill",
            colorHex: "#AA96DA",
            description: "提升工作效率"
        ),
        Category(
            name: "健康",
            icon: "figure.walk",
            colorHex: "#FCBAD3",
            description: "关注身心健康"
        )
    ]
}
