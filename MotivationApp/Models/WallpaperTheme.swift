//
//  WallpaperTheme.swift
//  MotivationApp
//
//  Created on 2026-01-18.
//

import Foundation
import SwiftUI

// MARK: - JSON 数据结构
struct WallpaperThemesData: Codable {
    let themes: [WallpaperTheme]
    let wallpapers: [ThemeWallpaper]
}

// MARK: - 壁纸主题（分类）
struct WallpaperTheme: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var icon: String
    var colorHex: String
    var description: String
    var isPremium: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, name, icon, colorHex, description, isPremium
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let idString = try container.decode(String.self, forKey: .id)
        self.id = UUID(uuidString: idString) ?? UUID()
        self.name = try container.decode(String.self, forKey: .name)
        self.icon = try container.decode(String.self, forKey: .icon)
        self.colorHex = try container.decode(String.self, forKey: .colorHex)
        self.description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
        self.isPremium = try container.decodeIfPresent(Bool.self, forKey: .isPremium) ?? false
    }
    
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
    
    enum CodingKeys: String, CodingKey {
        case id, themeId, name, imageName, thumbnailName, isPremium
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let idString = try container.decode(String.self, forKey: .id)
        self.id = UUID(uuidString: idString) ?? UUID()
        let themeIdString = try container.decode(String.self, forKey: .themeId)
        self.themeId = UUID(uuidString: themeIdString) ?? UUID()
        self.name = try container.decode(String.self, forKey: .name)
        self.imageName = try container.decode(String.self, forKey: .imageName)
        self.thumbnailName = try container.decodeIfPresent(String.self, forKey: .thumbnailName) ?? self.imageName
        self.isPremium = try container.decodeIfPresent(Bool.self, forKey: .isPremium) ?? false
    }
    
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

// MARK: - 从 JSON 加载数据
extension WallpaperTheme {
    private static var _cachedData: WallpaperThemesData?
    
    static func loadData() -> WallpaperThemesData {
        if let cached = _cachedData {
            return cached
        }
        
        guard let url = Bundle.main.url(forResource: "wallpaper_themes", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode(WallpaperThemesData.self, from: data) else {
            print("⚠️ 无法加载 wallpaper_themes.json，使用空数据")
            return WallpaperThemesData(themes: [], wallpapers: [])
        }
        
        _cachedData = decoded
        return decoded
    }
    
    static var sampleThemes: [WallpaperTheme] {
        loadData().themes
    }
}

// MARK: - 壁纸数据加载
extension ThemeWallpaper {
    static var sampleWallpapers: [ThemeWallpaper] {
        WallpaperTheme.loadData().wallpapers
    }
    
    static func wallpapers(for themeId: UUID) -> [ThemeWallpaper] {
        return sampleWallpapers.filter { $0.themeId == themeId }
    }
}
