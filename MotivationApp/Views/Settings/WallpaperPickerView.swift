//
//  WallpaperPickerView.swift
//  MotivationApp
//
//  Created on 2025-12-09.
//

import SwiftUI
import PhotosUI

struct WallpaperPickerView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var wallpaperManager = WallpaperManager.shared
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showingImagePicker = false
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // 渐变背景
                    sectionHeader("渐变背景")
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(GradientTheme.themes) { theme in
                            GradientThemeCell(
                                theme: theme,
                                isSelected: wallpaperManager.config.type == .gradient &&
                                           wallpaperManager.config.gradientThemeId == theme.id
                            ) {
                                wallpaperManager.setGradientTheme(theme)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // 内置壁纸
                    sectionHeader("精选壁纸")
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(PresetWallpaper.wallpapers) { wallpaper in
                            PresetWallpaperCell(
                                wallpaper: wallpaper,
                                isSelected: wallpaperManager.config.type == .preset &&
                                           wallpaperManager.config.presetWallpaperId == wallpaper.id
                            ) {
                                wallpaperManager.setPresetWallpaper(wallpaper)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // 自定义壁纸
                    sectionHeader("自定义壁纸")
                    HStack(spacing: 12) {
                        // 从相册选择按钮
                        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                            VStack(spacing: 8) {
                                Image(systemName: "photo.on.rectangle")
                                    .font(.system(size: 30))
                                Text("从相册选择")
                                    .font(.caption)
                            }
                            .foregroundColor(.white.opacity(0.7))
                            .frame(width: 100, height: 100)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                        }
                        
                        // 显示当前自定义壁纸
                        if wallpaperManager.config.type == .custom,
                           let image = wallpaperManager.customImage {
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.blue, lineWidth: 3)
                                    )
                                
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                                    .background(Circle().fill(.white))
                                    .offset(x: 5, y: -5)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("选择壁纸")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.primary)
                    }
                }
            }
            .onChange(of: selectedPhotoItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        await MainActor.run {
                            wallpaperManager.setCustomWallpaper(image)
                        }
                    }
                }
            }
        }
    }
    
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .foregroundColor(.primary)
            .padding(.horizontal)
            .padding(.top, 8)
    }
}

// MARK: - 渐变主题单元格
struct GradientThemeCell: View {
    let theme: GradientTheme
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                LinearGradient(
                    colors: theme.colors.compactMap { Color(hex: $0) },
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 3)
                )
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .background(Circle().fill(.white))
                        .offset(x: 5, y: -5)
                }
                
                VStack {
                    Spacer()
                    Text(theme.name)
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.bottom, 8)
                }
            }
        }
    }
}

// MARK: - 内置壁纸单元格
struct PresetWallpaperCell: View {
    let wallpaper: PresetWallpaper
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                // 尝试加载图片
                Group {
                    if let uiImage = loadWallpaperImage(wallpaper.imageName) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                    } else {
                        // 占位符 - 使用渐变色代替
                        LinearGradient(
                            colors: [Color.gray.opacity(0.5), Color.gray.opacity(0.3)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .overlay(
                            VStack {
                                Image(systemName: "photo")
                                    .font(.title)
                                    .foregroundColor(.white.opacity(0.5))
                                Text(wallpaper.name)
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        )
                    }
                }
                .frame(height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 3)
                )
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .background(Circle().fill(.white))
                        .offset(x: 5, y: -5)
                }
            }
        }
    }
    
    private func loadWallpaperImage(_ name: String) -> UIImage? {
        // 先尝试从 Assets 加载
        if let image = UIImage(named: name) {
            return image
        }
        // 尝试从 Bundle 加载 jpg
        if let path = Bundle.main.path(forResource: name, ofType: "jpg"),
           let image = UIImage(contentsOfFile: path) {
            return image
        }
        // 尝试从 Bundle 加载 png
        if let path = Bundle.main.path(forResource: name, ofType: "png"),
           let image = UIImage(contentsOfFile: path) {
            return image
        }
        return nil
    }
}

#Preview {
    WallpaperPickerView()
}
