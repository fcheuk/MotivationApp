//
//  CategoryListView.swift
//  MotivationApp
//
//  Created on 2025-12-09.
//

import SwiftUI

struct CategoryListView: View {
    @EnvironmentObject var dataManager: DataManager
    @ObservedObject var wallpaperManager = WallpaperManager.shared
    @State private var selectedThemeFilter: WallpaperTheme?
    @State private var showSubscriptionSheet = false
    @Environment(\.dismiss) var dismiss
    
    private var filteredWallpapers: [ThemeWallpaper] {
        if let theme = selectedThemeFilter {
            return ThemeWallpaper.wallpapers(for: theme.id)
        }
        return ThemeWallpaper.sampleWallpapers
    }
    
    var body: some View {
        ZStack {
            // 浅灰色背景
            Color(hex: "#F2F2F7")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                topNavigationBar
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        titleSection
                        filterSection
                        wallpapersGridSection
                        
                        // 底部解锁全部按钮
                        if !dataManager.settings.hasActiveSubscription {
                            unlockAllButton
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)
                }
            }
        }
        .sheet(isPresented: $showSubscriptionSheet) {
            SubscriptionView()
                .environmentObject(dataManager)
        }
    }
    
    // MARK: - 顶部导航栏
    private var topNavigationBar: some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                    .frame(width: 28, height: 28)
                    .background(Color.gray.opacity(0.15))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            Button(action: {
                showSubscriptionSheet = true
            }) {
                Text("解锁全部")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(16)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    // MARK: - 标题
    private var titleSection: some View {
        Text("主题")
            .font(.system(size: 32, weight: .bold))
            .foregroundColor(.black)
    }
    
    // MARK: - 筛选器
    private var filterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                // "所有"筛选项
                FilterPill(
                    title: "所有",
                    isSelected: selectedThemeFilter == nil
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedThemeFilter = nil
                    }
                }
                
                // 各主题筛选项
                ForEach(WallpaperTheme.sampleThemes) { theme in
                    FilterPill(
                        title: theme.name,
                        isSelected: selectedThemeFilter?.id == theme.id,
                        isPremium: theme.isPremium
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedThemeFilter = theme
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - 壁纸网格
    private var wallpapersGridSection: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ], spacing: 12) {
            ForEach(filteredWallpapers) { wallpaper in
                WallpaperCard(
                    wallpaper: wallpaper,
                    isLocked: wallpaper.isPremium && !dataManager.settings.hasActiveSubscription,
                    isSelected: wallpaperManager.config.type == .themeWallpaper &&
                               wallpaperManager.config.themeWallpaperId == wallpaper.id.uuidString
                ) {
                    handleWallpaperTap(wallpaper)
                }
            }
        }
    }
    
    private func handleWallpaperTap(_ wallpaper: ThemeWallpaper) {
        if dataManager.settings.hasActiveSubscription || !wallpaper.isPremium {
            wallpaperManager.setThemeWallpaper(wallpaper)
        } else {
            showSubscriptionSheet = true
        }
    }
    
    // MARK: - 底部解锁全部按钮
    private var unlockAllButton: some View {
        Button(action: {
            showSubscriptionSheet = true
        }) {
            HStack(spacing: 8) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 16))
                Text("解锁全部主题壁纸")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [Color.orange, Color.orange.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
        }
        .padding(.top, 10)
    }
}

// MARK: - 筛选胶囊
struct FilterPill: View {
    let title: String
    let isSelected: Bool
    var isPremium: Bool = false
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                
                if isPremium {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 9))
                        .foregroundColor(.orange)
                }
            }
            .foregroundColor(isSelected ? .black : .gray)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? .white : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: isSelected ? Color.black.opacity(0.08) : Color.clear, radius: 4, x: 0, y: 2)
        }
    }
}

// MARK: - 壁纸卡片
struct WallpaperCard: View {
    let wallpaper: ThemeWallpaper
    let isLocked: Bool
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            GeometryReader { geometry in
                ZStack(alignment: .bottom) {
                    // 壁纸图片或占位图
                    if let image = UIImage(named: wallpaper.thumbnailName) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .clipped()
                    } else {
                        // 占位渐变背景
                        LinearGradient(
                            colors: [
                                Color(hex: "#E8E8ED") ?? .gray,
                                Color(hex: "#D1D1D6") ?? .gray
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    }
                    
                    // 底部渐变遮罩和文字
                    LinearGradient(
                        colors: [Color.clear, Color.black.opacity(0.6)],
                        startPoint: .center,
                        endPoint: .bottom
                    )
                    
                    // 壁纸名称
                    Text(wallpaper.name)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.bottom, 8)
                    
                    // 锁定图标
                    if isLocked {
                        Color.black.opacity(0.3)
                        
                        Image(systemName: "lock.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                    }
                    
                    // 选中标记
                    if isSelected {
                        VStack {
                            HStack {
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.blue)
                                    .background(Circle().fill(.white).padding(2))
                            }
                            Spacer()
                        }
                        .padding(6)
                    }
                }
            }
            .aspectRatio(0.75, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
    }
}

#Preview {
    CategoryListView()
        .environmentObject(DataManager.shared)
}
