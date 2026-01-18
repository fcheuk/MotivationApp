//
//  WallpaperGridView.swift
//  MotivationApp
//
//  Created on 2026-01-18.
//

import SwiftUI

struct WallpaperGridView: View {
    let themeId: UUID
    let isSubscribed: Bool
    let onWallpaperTap: (ThemeWallpaper) -> Void
    
    private var wallpapers: [ThemeWallpaper] {
        ThemeWallpaper.wallpapers(for: themeId)
    }
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ], spacing: 12) {
            ForEach(wallpapers) { wallpaper in
                WallpaperThumbnail(
                    wallpaper: wallpaper,
                    isLocked: wallpaper.isPremium && !isSubscribed
                ) {
                    onWallpaperTap(wallpaper)
                }
            }
        }
    }
}

// MARK: - 壁纸缩略图
struct WallpaperThumbnail: View {
    let wallpaper: ThemeWallpaper
    let isLocked: Bool
    let onTap: () -> Void
    
    @ObservedObject private var wallpaperManager = WallpaperManager.shared
    
    private var isCurrentWallpaper: Bool {
        wallpaperManager.config.type == .themeWallpaper &&
        wallpaperManager.config.themeWallpaperId == wallpaper.id.uuidString
    }
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // 壁纸图片
                if let image = UIImage(named: wallpaper.thumbnailName) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 140)
                        .clipped()
                } else {
                    // 占位图
                    placeholderView
                }
                
                // 锁定遮罩
                if isLocked {
                    lockedOverlay
                }
                
                // 选中标记
                if isCurrentWallpaper {
                    selectedOverlay
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isCurrentWallpaper ? Color.blue : Color.clear, lineWidth: 3)
            )
        }
    }
    
    private var placeholderView: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hex: "#2C3E50") ?? .gray,
                    Color(hex: "#3498DB") ?? .blue
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: 4) {
                Image(systemName: "photo")
                    .font(.system(size: 24))
                    .foregroundColor(.white.opacity(0.5))
                
                Text(wallpaper.name)
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(1)
            }
        }
        .frame(height: 140)
    }
    
    private var lockedOverlay: some View {
        ZStack {
            Color.black.opacity(0.5)
            
            VStack(spacing: 4) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                
                Text("订阅解锁")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
    }
    
    private var selectedOverlay: some View {
        VStack {
            HStack {
                Spacer()
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.blue)
                    .background(Circle().fill(.white).padding(2))
            }
            Spacer()
        }
        .padding(8)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        WallpaperGridView(
            themeId: WallpaperTheme.seasonThemeId,
            isSubscribed: false
        ) { wallpaper in
            print("Tapped: \(wallpaper.name)")
        }
        .padding()
    }
}
