//
//  WallpaperTheme.swift
//  MotivationApp
//
//  Created on 2026-01-18.
//

import Foundation
import SwiftUI

// MARK: - 壁纸主题（分类）
struct WallpaperTheme: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var icon: String
    var colorHex: String
    var description: String
    var isPremium: Bool
    
    init(
        id: UUID = UUID(),
        name: String,
        icon: String,
        colorHex: String,
        description: String = "",
        isPremium: Bool = false
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
        self.description = description
        self.isPremium = isPremium
    }
    
    var color: Color {
        Color(hex: colorHex) ?? .blue
    }
}

// MARK: - 主题壁纸
struct ThemeWallpaper: Identifiable, Codable, Hashable {
    var id: UUID
    var themeId: UUID
    var name: String
    var imageName: String
    var thumbnailName: String
    var isPremium: Bool
    
    init(
        id: UUID = UUID(),
        themeId: UUID,
        name: String,
        imageName: String,
        thumbnailName: String? = nil,
        isPremium: Bool = false
    ) {
        self.id = id
        self.themeId = themeId
        self.name = name
        self.imageName = imageName
        self.thumbnailName = thumbnailName ?? imageName
        self.isPremium = isPremium
    }
}

// MARK: - 预设主题数据
extension WallpaperTheme {
    static let seasonThemeId = UUID(uuidString: "00000001-0000-0000-0000-000000000001")!
    static let sceneryThemeId = UUID(uuidString: "00000002-0000-0000-0000-000000000002")!
    static let foodThemeId = UUID(uuidString: "00000003-0000-0000-0000-000000000003")!
    static let cityThemeId = UUID(uuidString: "00000004-0000-0000-0000-000000000004")!
    static let animalThemeId = UUID(uuidString: "00000005-0000-0000-0000-000000000005")!
    
    static let sampleThemes: [WallpaperTheme] = [
        WallpaperTheme(
            id: seasonThemeId,
            name: "季节",
            icon: "leaf.fill",
            colorHex: "#FF9500",
            description: "四季更迭，感受自然之美",
            isPremium: false
        ),
        WallpaperTheme(
            id: sceneryThemeId,
            name: "风景",
            icon: "mountain.2.fill",
            colorHex: "#34C759",
            description: "壮丽山河，心旷神怡",
            isPremium: false
        ),
        WallpaperTheme(
            id: foodThemeId,
            name: "美食",
            icon: "fork.knife",
            colorHex: "#FF3B30",
            description: "色香味俱全，治愈你的心",
            isPremium: true
        ),
        WallpaperTheme(
            id: cityThemeId,
            name: "城市",
            icon: "building.2.fill",
            colorHex: "#5856D6",
            description: "都市霓虹，繁华夜景",
            isPremium: true
        ),
        WallpaperTheme(
            id: animalThemeId,
            name: "动物",
            icon: "pawprint.fill",
            colorHex: "#AF52DE",
            description: "可爱萌宠，治愈心灵",
            isPremium: true
        )
    ]
}

// MARK: - 预设壁纸数据
extension ThemeWallpaper {
    static let sampleWallpapers: [ThemeWallpaper] = [
        // 季节主题壁纸 - 使用现有的精选壁纸资源
        ThemeWallpaper(
            themeId: WallpaperTheme.seasonThemeId,
            name: "冬日雪景",
            imageName: "wallpaper_mountain",  // 使用现有的山峰壁纸
            isPremium: false
        ),
        ThemeWallpaper(
            themeId: WallpaperTheme.seasonThemeId,
            name: "秋日暖阳",
            imageName: "wallpaper_sunset",    // 使用现有的日落壁纸
            isPremium: false
        ),
        ThemeWallpaper(
            themeId: WallpaperTheme.seasonThemeId,
            name: "夏日森林",
            imageName: "wallpaper_forest",    // 使用现有的森林壁纸
            isPremium: true
        ),
        ThemeWallpaper(
            themeId: WallpaperTheme.seasonThemeId,
            name: "春日星空",
            imageName: "wallpaper_stars",     // 使用现有的星空壁纸
            isPremium: true
        ),
        
        // 风景主题壁纸 - 使用现有的精选壁纸资源
        ThemeWallpaper(
            themeId: WallpaperTheme.sceneryThemeId,
            name: "雪山日出",
            imageName: "wallpaper_mountain",  // 使用现有的山峰壁纸
            isPremium: false
        ),
        ThemeWallpaper(
            themeId: WallpaperTheme.sceneryThemeId,
            name: "碧海蓝天",
            imageName: "wallpaper_ocean",     // 使用现有的海洋壁纸
            isPremium: false
        ),
        ThemeWallpaper(
            themeId: WallpaperTheme.sceneryThemeId,
            name: "森林小径",
            imageName: "wallpaper_forest",    // 使用现有的森林壁纸
            isPremium: false
        ),
        ThemeWallpaper(
            themeId: WallpaperTheme.sceneryThemeId,
            name: "璀璨星空",
            imageName: "wallpaper_stars",     // 使用现有的星空壁纸
            isPremium: true
        ),
        ThemeWallpaper(
            themeId: WallpaperTheme.sceneryThemeId,
            name: "日落余晖",
            imageName: "wallpaper_sunset",    // 使用现有的日落壁纸
            isPremium: true
        ),
        
        // 城市主题壁纸 - 使用现有的精选壁纸资源
        ThemeWallpaper(
            themeId: WallpaperTheme.cityThemeId,
            name: "都市夜景",
            imageName: "wallpaper_city",      // 使用现有的城市壁纸
            isPremium: false
        ),
        ThemeWallpaper(
            themeId: WallpaperTheme.cityThemeId,
            name: "城市星空",
            imageName: "wallpaper_stars",     // 使用现有的星空壁纸
            isPremium: true
        ),
        
        // 美食主题壁纸 - 暂无现有资源，保留占位
        ThemeWallpaper(
            themeId: WallpaperTheme.foodThemeId,
            name: "精致甜点",
            imageName: "theme_food_dessert",
            isPremium: true
        ),
        ThemeWallpaper(
            themeId: WallpaperTheme.foodThemeId,
            name: "咖啡时光",
            imageName: "theme_food_coffee",
            isPremium: true
        ),
        
        // 动物主题壁纸 - 暂无现有资源，保留占位
        ThemeWallpaper(
            themeId: WallpaperTheme.animalThemeId,
            name: "可爱猫咪",
            imageName: "theme_animal_cat",
            isPremium: true
        ),
        ThemeWallpaper(
            themeId: WallpaperTheme.animalThemeId,
            name: "忠诚狗狗",
            imageName: "theme_animal_dog",
            isPremium: true
        ),
        ThemeWallpaper(
            themeId: WallpaperTheme.animalThemeId,
            name: "野生动物",
            imageName: "theme_animal_wild",
            isPremium: true
        )
    ]
    
    static func wallpapers(for themeId: UUID) -> [ThemeWallpaper] {
        return sampleWallpapers.filter { $0.themeId == themeId }
    }
}
