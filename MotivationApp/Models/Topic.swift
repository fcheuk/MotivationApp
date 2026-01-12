//
//  Topic.swift
//  MotivationApp
//
//  Created on 2026-01-12.
//

import Foundation
import SwiftUI

enum TopicType: String, Codable {
    case quick
    case category
}

struct Topic: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var icon: String
    var colorHex: String
    var type: TopicType
    var isLocked: Bool
    var quoteCount: Int
    
    init(
        id: UUID = UUID(),
        name: String,
        icon: String,
        colorHex: String,
        type: TopicType = .category,
        isLocked: Bool = false,
        quoteCount: Int = 0
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
        self.type = type
        self.isLocked = isLocked
        self.quoteCount = quoteCount
    }
    
    var color: Color {
        Color(hex: colorHex) ?? .blue
    }
}

// MARK: - Sample Data
extension Topic {
    static let sampleTopics: [Topic] = [
        Topic(
            name: "我的喜欢",
            icon: "heart.fill",
            colorHex: "#FF6B6B",
            type: .quick,
            isLocked: false,
            quoteCount: 12
        ),
        Topic(
            name: "我的收藏",
            icon: "bookmark.fill",
            colorHex: "#4ECDC4",
            type: .quick,
            isLocked: false,
            quoteCount: 8
        ),
        Topic(
            name: "你自己的金句",
            icon: "pencil",
            colorHex: "#95E1D3",
            type: .quick,
            isLocked: false,
            quoteCount: 5
        ),
        Topic(
            name: "最近阅读过的金句",
            icon: "clock.fill",
            colorHex: "#F38181",
            type: .quick,
            isLocked: true,
            quoteCount: 20
        ),
        Topic(
            name: "不健康的关系",
            icon: "heart.slash.fill",
            colorHex: "#AA96DA",
            type: .category,
            isLocked: true,
            quoteCount: 15
        ),
        Topic(
            name: "力量",
            icon: "bolt.fill",
            colorHex: "#FCBAD3",
            type: .category,
            isLocked: true,
            quoteCount: 25
        ),
        Topic(
            name: "积极乐观",
            icon: "sun.max.fill",
            colorHex: "#FFD93D",
            type: .category,
            isLocked: true,
            quoteCount: 30
        ),
        Topic(
            name: "坚强",
            icon: "shield.fill",
            colorHex: "#6BCB77",
            type: .category,
            isLocked: true,
            quoteCount: 18
        ),
        Topic(
            name: "信心",
            icon: "star.fill",
            colorHex: "#4D96FF",
            type: .category,
            isLocked: true,
            quoteCount: 22
        ),
        Topic(
            name: "企业家",
            icon: "briefcase.fill",
            colorHex: "#FF6B9D",
            type: .category,
            isLocked: true,
            quoteCount: 16
        )
    ]
}
