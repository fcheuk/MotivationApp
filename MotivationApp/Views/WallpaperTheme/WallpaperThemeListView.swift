//
//  WallpaperThemeListView.swift
//  MotivationApp
//
//  Created on 2026-01-18.
//

import SwiftUI

struct WallpaperThemeListView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedTheme: WallpaperTheme?
    @State private var showSubscriptionSheet = false
    @Environment(\.dismiss) var dismiss
    
    let themes = WallpaperTheme.sampleThemes
    
    var body: some View {
        ZStack {
            Color(hex: "#1C1C1E")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                topNavigationBar
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        titleSection
                        themesGridSection
                        
                        if let theme = selectedTheme {
                            wallpaperPreviewSection(for: theme)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                }
            }
        }
        .sheet(isPresented: $showSubscriptionSheet) {
            SubscriptionView()
        }
    }
    
    private var topNavigationBar: some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(Color.white.opacity(0.15))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            Text("主题壁纸")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
            
            Spacer()
            
            Color.clear
                .frame(width: 32, height: 32)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("选择主题")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            
            Text("点击主题查看壁纸，订阅后可下载所有壁纸")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(.top, 8)
    }
    
    private var themesGridSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("主题分类")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                ForEach(themes) { theme in
                    WallpaperThemeCard(
                        theme: theme,
                        isSelected: selectedTheme?.id == theme.id
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTheme = theme
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func wallpaperPreviewSection(for theme: WallpaperTheme) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("\(theme.name)壁纸")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                if theme.isPremium && !dataManager.settings.hasActiveSubscription {
                    HStack(spacing: 4) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 12))
                        Text("订阅解锁")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(.yellow)
                }
            }
            
            WallpaperGridView(
                themeId: theme.id,
                isSubscribed: dataManager.settings.hasActiveSubscription,
                onWallpaperTap: { wallpaper in
                    handleWallpaperTap(wallpaper)
                }
            )
        }
        .padding(.top, 8)
    }
    
    private func handleWallpaperTap(_ wallpaper: ThemeWallpaper) {
        if dataManager.settings.hasActiveSubscription || !wallpaper.isPremium {
            WallpaperManager.shared.setThemeWallpaper(wallpaper)
        } else {
            showSubscriptionSheet = true
        }
    }
}

// MARK: - 壁纸主题卡片
struct WallpaperThemeCard: View {
    let theme: WallpaperTheme
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(theme.color.opacity(0.2))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: theme.icon)
                        .font(.system(size: 24))
                        .foregroundColor(theme.color)
                    
                    if theme.isPremium {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.yellow)
                            .offset(x: 20, y: -20)
                    }
                }
                
                Text(theme.name)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? theme.color.opacity(0.3) : Color.white.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? theme.color : Color.clear, lineWidth: 2)
            )
        }
    }
}

#Preview {
    WallpaperThemeListView()
        .environmentObject(DataManager.shared)
}
