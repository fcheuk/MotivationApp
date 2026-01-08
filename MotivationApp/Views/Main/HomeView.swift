//
//  HomeView.swift
//  MotivationApp
//
//  Created on 2025-12-09.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var dataManager: DataManager
    @StateObject private var viewModel = QuoteViewModel()
    @State private var dragOffset: CGFloat = 0
    @State private var isTransitioning: Bool = false
    @State private var transitionDirection: TransitionDirection = .none
    @State private var showShareSheet = false
    
    enum TransitionDirection {
        case none, up, down
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenHeight = geometry.size.height
            
            ZStack {
                // 全屏背景图
                backgroundView
                    .ignoresSafeArea()
                
                // 内容区域
                VStack(spacing: 0) {
                    // 可滑动的文案区域
                    ZStack {
                        // 上一页内容（从上方进入）
                        if transitionDirection == .down, let prevQuote = viewModel.previousQuoteContent {
                            quoteView(for: prevQuote)
                                .offset(y: dragOffset - screenHeight)
                        }
                        
                        // 当前页内容
                        if let currentQuote = viewModel.currentQuote {
                            quoteView(for: currentQuote)
                                .offset(y: dragOffset)
                        }
                        
                        // 下一页内容（从下方进入）
                        if transitionDirection == .up, let nextQuote = viewModel.nextQuoteContent {
                            quoteView(for: nextQuote)
                                .offset(y: dragOffset + screenHeight)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle()) // 确保整个区域可响应手势
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                dragOffset = value.translation.height
                                // 根据滑动方向显示对应的预览页
                                if value.translation.height < 0 {
                                    transitionDirection = .up
                                } else if value.translation.height > 0 {
                                    transitionDirection = .down
                                }
                            }
                            .onEnded { value in
                                let velocityThreshold: CGFloat = 300
                                let distanceThreshold: CGFloat = screenHeight / 3 // 滑动距离超过1/3屏幕
                                let velocity = value.predictedEndLocation.y - value.location.y
                                let distance = value.translation.height
                                
                                if velocity < -velocityThreshold || distance < -distanceThreshold {
                                    // 快速上滑 或 滑动距离超过1/3 -> 切换到下一句
                                    withAnimation(.easeOut(duration: 0.3)) {
                                        dragOffset = -screenHeight
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        viewModel.nextQuote()
                                        dataManager.checkIn()
                                        dragOffset = 0
                                        transitionDirection = .none
                                    }
                                } else if velocity > velocityThreshold || distance > distanceThreshold {
                                    // 快速下滑 或 滑动距离超过1/3 -> 切换到上一句
                                    withAnimation(.easeOut(duration: 0.3)) {
                                        dragOffset = screenHeight
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        viewModel.previousQuote()
                                        dataManager.checkIn()
                                        dragOffset = 0
                                        transitionDirection = .none
                                    }
                                } else {
                                    // 速度不够且距离不够，返回原位
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
        .sheet(isPresented: $showShareSheet) {
            if let quote = viewModel.currentQuote {
                ShareSheet(items: [viewModel.shareQuote()])
            }
        }
    }
    
    // MARK: - 背景视图
    private var backgroundView: some View {
        ZStack {
            // 渐变背景作为默认
            LinearGradient(
                colors: [
                    Color(hex: "#1a1a2e") ?? Color.black,
                    Color(hex: "#16213e") ?? Color.black,
                    Color(hex: "#0f3460") ?? Color.blue
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
        }
    }
    
    // MARK: - 单个语录视图（包含文案和按钮）
    private func quoteView(for quote: Quote) -> some View {
        VStack(spacing: 0) {
            Spacer()
            
            // 文案内容
            VStack(spacing: 16) {
                Text(quote.content)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(8)
                    .padding(.horizontal, 24)
                    .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                
                // 作者
                HStack {
                    Spacer()
                    Text("— \(quote.author)")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.trailing, 24)
                }
            }
            
            Spacer()
            
            // 底部按钮（跟随滑动）
            actionButtonsView(for: quote)
                .padding(.bottom, 16)
        }
    }
    
    // MARK: - 底部按钮视图
    private func actionButtonsView(for quote: Quote) -> some View {
        HStack(spacing: 40) {
            // 下载按钮
            Button(action: {
                saveQuoteAsImage()
            }) {
                Image(systemName: "square.and.arrow.down")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            // 点赞/收藏按钮
            Button(action: {
                withAnimation {
                    viewModel.toggleFavorite()
                }
            }) {
                Image(systemName: quote.isFavorite ? "heart.fill" : "heart")
                    .font(.title2)
                    .foregroundColor(quote.isFavorite ? .red : .white.opacity(0.8))
            }
        }
        .padding(.vertical, 16)
    }
    
    // MARK: - 保存图片
    private func saveQuoteAsImage() {
        guard let quote = viewModel.currentQuote else { return }
        
        // 创建要保存的视图
        let renderer = ImageRenderer(content:
            ZStack {
                // 背景
                LinearGradient(
                    colors: [
                        Color(hex: "#1a1a2e") ?? Color.black,
                        Color(hex: "#16213e") ?? Color.black,
                        Color(hex: "#0f3460") ?? Color.blue
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                // 文案
                VStack(spacing: 16) {
                    Text(quote.content)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(8)
                        .padding(.horizontal, 24)
                    
                    HStack {
                        Spacer()
                        Text("— \(quote.author)")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.trailing, 24)
                    }
                }
            }
            .frame(width: 390, height: 844)
        )
        
        renderer.scale = UIScreen.main.scale
        
        if let uiImage = renderer.uiImage {
            UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
        }
    }
}

// 分享面板
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    HomeView()
        .environmentObject(DataManager.shared)
}
