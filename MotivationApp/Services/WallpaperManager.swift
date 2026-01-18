//
//  WallpaperManager.swift
//  MotivationApp
//
//  Created on 2025-12-09.
//

import SwiftUI
import PhotosUI

// MARK: - 壁纸类型
enum WallpaperType: String, Codable, CaseIterable {
    case gradient = "gradient"          // 渐变背景
    case preset = "preset"              // 内置壁纸
    case custom = "custom"              // 用户自定义
    case themeWallpaper = "theme"       // 主题壁纸
}

// MARK: - 渐变主题
struct GradientTheme: Identifiable, Codable {
    let id: String
    let name: String
    let colors: [String]  // Hex颜色数组
    
    static let themes: [GradientTheme] = [
        GradientTheme(id: "dark_blue", name: "深邃蓝", colors: ["#1a1a2e", "#16213e", "#0f3460"]),
        GradientTheme(id: "sunset", name: "日落橙", colors: ["#2d1f3d", "#614385", "#516395"]),
        GradientTheme(id: "forest", name: "森林绿", colors: ["#134e5e", "#71b280", "#2c3e50"]),
        GradientTheme(id: "ocean", name: "海洋蓝", colors: ["#0f2027", "#203a43", "#2c5364"]),
        GradientTheme(id: "purple", name: "梦幻紫", colors: ["#1a0530", "#2d1b4e", "#4a2c7a"]),
        GradientTheme(id: "night", name: "夜空黑", colors: ["#0f0c29", "#302b63", "#24243e"])
    ]
}

// MARK: - 内置壁纸
struct PresetWallpaper: Identifiable, Codable {
    let id: String
    let name: String
    let imageName: String  // Assets中的图片名称
    
    static let wallpapers: [PresetWallpaper] = [
        PresetWallpaper(id: "mountain", name: "山峰", imageName: "wallpaper_mountain"),
        PresetWallpaper(id: "ocean", name: "海洋", imageName: "wallpaper_ocean"),
        PresetWallpaper(id: "forest", name: "森林", imageName: "wallpaper_forest"),
        PresetWallpaper(id: "stars", name: "星空", imageName: "wallpaper_stars"),
        PresetWallpaper(id: "sunset", name: "日落", imageName: "wallpaper_sunset"),
        PresetWallpaper(id: "city", name: "城市", imageName: "wallpaper_city")
    ]
}

// MARK: - 壁纸配置
struct WallpaperConfig: Codable {
    var type: WallpaperType
    var gradientThemeId: String?
    var presetWallpaperId: String?
    var customImageData: Data?
    var themeWallpaperId: String?
    
    static let `default` = WallpaperConfig(
        type: .gradient,
        gradientThemeId: "dark_blue",
        presetWallpaperId: nil,
        customImageData: nil,
        themeWallpaperId: nil
    )
}

// MARK: - 壁纸管理器
class WallpaperManager: ObservableObject {
    static let shared = WallpaperManager()
    
    @Published var config: WallpaperConfig {
        didSet {
            saveConfig()
        }
    }
    
    @Published var customImage: UIImage?
    
    private let configKey = "wallpaper_config"
    
    private init() {
        if let data = UserDefaults.standard.data(forKey: configKey),
           let config = try? JSONDecoder().decode(WallpaperConfig.self, from: data) {
            self.config = config
            // 加载自定义图片
            if let imageData = config.customImageData {
                self.customImage = UIImage(data: imageData)
            }
        } else {
            self.config = .default
        }
    }
    
    private func saveConfig() {
        if let data = try? JSONEncoder().encode(config) {
            UserDefaults.standard.set(data, forKey: configKey)
        }
    }
    
    // MARK: - 设置渐变主题
    func setGradientTheme(_ theme: GradientTheme) {
        config = WallpaperConfig(
            type: .gradient,
            gradientThemeId: theme.id,
            presetWallpaperId: nil,
            customImageData: nil
        )
        customImage = nil
    }
    
    // MARK: - 设置内置壁纸
    func setPresetWallpaper(_ wallpaper: PresetWallpaper) {
        config = WallpaperConfig(
            type: .preset,
            gradientThemeId: nil,
            presetWallpaperId: wallpaper.id,
            customImageData: nil
        )
        customImage = nil
    }
    
    // MARK: - 设置自定义壁纸
    func setCustomWallpaper(_ image: UIImage) {
        // 压缩图片以节省存储空间
        let compressedData = image.jpegData(compressionQuality: 0.7)
        config = WallpaperConfig(
            type: .custom,
            gradientThemeId: nil,
            presetWallpaperId: nil,
            customImageData: compressedData
        )
        customImage = image
    }
    
    // MARK: - 获取当前渐变主题
    var currentGradientTheme: GradientTheme? {
        guard let id = config.gradientThemeId else { return nil }
        return GradientTheme.themes.first { $0.id == id }
    }
    
    // MARK: - 获取当前内置壁纸
    var currentPresetWallpaper: PresetWallpaper? {
        guard let id = config.presetWallpaperId else { return nil }
        return PresetWallpaper.wallpapers.first { $0.id == id }
    }
    
    // MARK: - 设置主题壁纸
    func setThemeWallpaper(_ wallpaper: ThemeWallpaper) {
        config = WallpaperConfig(
            type: .themeWallpaper,
            gradientThemeId: nil,
            presetWallpaperId: nil,
            customImageData: nil,
            themeWallpaperId: wallpaper.id.uuidString
        )
        customImage = nil
    }
    
    // MARK: - 获取当前主题壁纸
    var currentThemeWallpaper: ThemeWallpaper? {
        guard let idString = config.themeWallpaperId,
              let id = UUID(uuidString: idString) else { return nil }
        return ThemeWallpaper.sampleWallpapers.first { $0.id == id }
    }
}
