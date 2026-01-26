//
//  TopicDetailView.swift
//  MotivationApp
//
//  Created on 2026-01-25.
//

import SwiftUI

struct TopicDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    @ObservedObject private var wallpaperManager = WallpaperManager.shared
    
    let topic: Topic
    
    @State private var currentIndex: Int = 0
    @State private var dragOffset: CGFloat = 0
    @State private var transitionDirection: TransitionDirection = .none
    @State private var isFollowing: Bool = false
    
    enum TransitionDirection {
        case none, up, down
    }
    
    // 获取该话题下的词条
    private var quotes: [Quote] {
        // 如果 dataManager 中有词条则使用，否则使用示例数据
        let allQuotes = dataManager.quotes.isEmpty ? Quote.sampleQuotes : dataManager.quotes
        return allQuotes
    }
    
    private var currentQuote: Quote? {
        guard !quotes.isEmpty, currentIndex < quotes.count else { return nil }
        return quotes[currentIndex]
    }
    
    private var previousQuote: Quote? {
        guard currentIndex > 0 else { return nil }
        return quotes[currentIndex - 1]
    }
    
    private var nextQuote: Quote? {
        guard currentIndex < quotes.count - 1 else { return nil }
        return quotes[currentIndex + 1]
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenHeight = geometry.size.height
            
            ZStack {
                // 背景
                backgroundView
                    .ignoresSafeArea()
                
                // 内容
                VStack(spacing: 0) {
                    // 顶部导航栏
                    topNavigationBar
                    
                    // 词条内容区域（可滑动）
                    ZStack {
                        // 上一页内容（从上方进入）
                        if transitionDirection == .down, let prevQuote = previousQuote {
                            quoteContentView(quote: prevQuote)
                                .offset(y: dragOffset - screenHeight)
                        }
                        
                        // 当前页内容
                        if let quote = currentQuote {
                            quoteContentView(quote: quote)
                                .offset(y: dragOffset)
                        }
                        
                        // 下一页内容（从下方进入）
                        if transitionDirection == .up, let nextQuote = nextQuote {
                            quoteContentView(quote: nextQuote)
                                .offset(y: dragOffset + screenHeight)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                dragOffset = value.translation.height
                                if value.translation.height < 0 {
                                    transitionDirection = .up
                                } else if value.translation.height > 0 {
                                    transitionDirection = .down
                                }
                            }
                            .onEnded { value in
                                let velocityThreshold: CGFloat = 300
                                let distanceThreshold: CGFloat = screenHeight / 3
                                let velocity = value.predictedEndLocation.y - value.location.y
                                let distance = value.translation.height
                                
                                if velocity < -velocityThreshold || distance < -distanceThreshold {
                                    // 上滑 -> 下一条
                                    if currentIndex < quotes.count - 1 {
                                        withAnimation(.easeOut(duration: 0.3)) {
                                            dragOffset = -screenHeight
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            currentIndex += 1
                                            dragOffset = 0
                                            transitionDirection = .none
                                        }
                                    } else {
                                        withAnimation(.easeOut(duration: 0.3)) {
                                            dragOffset = 0
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            transitionDirection = .none
                                        }
                                    }
                                } else if velocity > velocityThreshold || distance > distanceThreshold {
                                    // 下滑 -> 上一条
                                    if currentIndex > 0 {
                                        withAnimation(.easeOut(duration: 0.3)) {
                                            dragOffset = screenHeight
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            currentIndex -= 1
                                            dragOffset = 0
                                            transitionDirection = .none
                                        }
                                    } else {
                                        withAnimation(.easeOut(duration: 0.3)) {
                                            dragOffset = 0
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            transitionDirection = .none
                                        }
                                    }
                                } else {
                                    withAnimation(.easeOut(duration: 0.3)) {
                                        dragOffset = 0
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        transitionDirection = .none
                                    }
                                }
                            }
                    )
                    
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - 顶部导航栏
    private var topNavigationBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
            }
            
            Spacer()
            
            Text(topic.name)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
            
            Spacer()
            
            Button(action: { isFollowing.toggle() }) {
                Text(isFollowing ? "已关注" : "关注")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isFollowing ? .white.opacity(0.7) : .white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .stroke(Color.white.opacity(0.5), lineWidth: 1)
                    )
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }
    
    // MARK: - 词条内容视图
    private func quoteContentView(quote: Quote) -> some View {
        VStack {
            Spacer()
            
            Text(quote.content)
                .font(.system(size: 26, weight: .medium))
                .foregroundColor(Color(hex: "#D4C5A9") ?? .white)
                .multilineTextAlignment(.leading)
                .lineSpacing(12)
                .padding(.horizontal, 24)
                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
            
            Spacer()
            
            // 底部操作按钮
            HStack(spacing: 40) {
                Button(action: {}) {
                    Image(systemName: "hand.thumbsdown")
                        .font(.system(size: 24))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Button(action: {
                    dataManager.toggleFavorite(quote: quote)
                }) {
                    Image(systemName: quote.isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 24))
                        .foregroundColor(quote.isFavorite ? .red : .white.opacity(0.7))
                }
            }
            .padding(.vertical, 20)
            .padding(.bottom, 30)
        }
    }
    
    // MARK: - 背景视图
    private var backgroundView: some View {
        ZStack {
            switch wallpaperManager.config.type {
            case .gradient:
                if let theme = wallpaperManager.currentGradientTheme {
                    LinearGradient(
                        colors: theme.colors.compactMap { Color(hex: $0) },
                        startPoint: .top,
                        endPoint: .bottom
                    )
                } else {
                    defaultGradient
                }
                
            case .preset:
                if let wallpaper = wallpaperManager.currentPresetWallpaper,
                   let uiImage = loadWallpaperImage(wallpaper.imageName) {
                    GeometryReader { geo in
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geo.size.width, height: geo.size.height)
                            .clipped()
                    }
                } else {
                    defaultGradient
                }
                
            case .custom:
                if let image = wallpaperManager.customImage {
                    GeometryReader { geo in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geo.size.width, height: geo.size.height)
                            .clipped()
                    }
                } else {
                    defaultGradient
                }
                
            case .themeWallpaper:
                if let themeWallpaper = wallpaperManager.currentThemeWallpaper,
                   let uiImage = loadWallpaperImage(themeWallpaper.imageName) {
                    GeometryReader { geo in
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geo.size.width, height: geo.size.height)
                            .clipped()
                    }
                } else {
                    defaultGradient
                }
            }
        }
    }
    
    private var defaultGradient: some View {
        LinearGradient(
            colors: [
                Color(hex: "#1a1a2e") ?? .black,
                Color(hex: "#16213e") ?? .black,
                Color(hex: "#0f3460") ?? .blue
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private func loadWallpaperImage(_ name: String) -> UIImage? {
        if let image = UIImage(named: name) {
            return image
        }
        if let path = Bundle.main.path(forResource: name, ofType: "jpg"),
           let image = UIImage(contentsOfFile: path) {
            return image
        }
        if let path = Bundle.main.path(forResource: name, ofType: "png"),
           let image = UIImage(contentsOfFile: path) {
            return image
        }
        return nil
    }
}

#Preview {
    TopicDetailView(topic: Topic.sampleTopics[4])
        .environmentObject(DataManager.shared)
}
