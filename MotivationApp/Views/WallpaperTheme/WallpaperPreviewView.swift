//
//  WallpaperPreviewView.swift
//  MotivationApp
//
//  Created on 2026-01-22.
//

import SwiftUI

struct WallpaperPreviewView: View {
    let wallpaper: ThemeWallpaper
    let isSubscribed: Bool
    var onSubscribeTap: (() -> Void)?
    
    @Environment(\.dismiss) var dismiss
    @State private var showSaveSuccess = false
    @State private var showSaveError = false
    
    private var isLocked: Bool {
        wallpaper.isPremium && !isSubscribed
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // 壁纸预览
            wallpaperImage
            
            // 水印（非订阅用户）
            if isLocked {
                watermarkOverlay
            }
            
            // 顶部导航栏
            VStack {
                topBar
                Spacer()
            }
            
            // 底部操作栏
            VStack {
                Spacer()
                bottomBar
            }
        }
        .alert("保存成功", isPresented: $showSaveSuccess) {
            Button("确定", role: .cancel) {}
        } message: {
            Text("壁纸已保存到相册")
        }
        .alert("保存失败", isPresented: $showSaveError) {
            Button("确定", role: .cancel) {}
        } message: {
            Text("请在设置中允许访问相册")
        }
    }
    
    // MARK: - 壁纸图片
    private var wallpaperImage: some View {
        Group {
            if let image = loadWallpaperImage(wallpaper.imageName) {
                GeometryReader { geo in
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                }
            } else {
                // 占位图
                LinearGradient(
                    colors: [
                        Color(hex: "#2C3E50") ?? .gray,
                        Color(hex: "#3498DB") ?? .blue
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .overlay(
                    VStack(spacing: 12) {
                        Image(systemName: "photo")
                            .font(.system(size: 48))
                            .foregroundColor(.white.opacity(0.5))
                        Text(wallpaper.name)
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.7))
                    }
                )
            }
        }
        .ignoresSafeArea()
    }
    
    // MARK: - 水印遮罩
    private var watermarkOverlay: some View {
        ZStack {
            // 半透明遮罩
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            // 水印网格
            GeometryReader { geo in
                let rows = Int(geo.size.height / 150)
                let cols = Int(geo.size.width / 150)
                
                VStack(spacing: 80) {
                    ForEach(0..<rows, id: \.self) { row in
                        HStack(spacing: 60) {
                            ForEach(0..<cols, id: \.self) { col in
                                watermarkText
                                    .rotationEffect(.degrees(-30))
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            // 中央解锁提示
            VStack(spacing: 16) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.white)
                
                Text("订阅解锁高清无水印")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                Button(action: {
                    onSubscribeTap?()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 16))
                        Text("立即订阅")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [Color.yellow, Color.orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
                }
            }
            .padding(32)
            .background(Color.black.opacity(0.6))
            .cornerRadius(24)
        }
    }
    
    private var watermarkText: some View {
        Text("MotivationApp")
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(.white.opacity(0.3))
    }
    
    // MARK: - 顶部导航栏
    private var topBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.black.opacity(0.4))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            Text(wallpaper.name)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
            
            Spacer()
            
            Color.clear
                .frame(width: 40, height: 40)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
    
    // MARK: - 底部操作栏
    private var bottomBar: some View {
        HStack(spacing: 20) {
            // 设为壁纸按钮
            Button(action: {
                if isLocked {
                    onSubscribeTap?()
                } else {
                    WallpaperManager.shared.setThemeWallpaper(wallpaper)
                    dismiss()
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                    Text("设为壁纸")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.blue)
                .cornerRadius(14)
            }
            
            // 保存到相册按钮
            Button(action: {
                if isLocked {
                    onSubscribeTap?()
                } else {
                    saveToPhotos()
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: isLocked ? "lock.fill" : "arrow.down.circle.fill")
                        .font(.system(size: 18))
                    Text("保存")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(isLocked ? .gray : .white)
                .frame(width: 100)
                .padding(.vertical, 16)
                .background(isLocked ? Color.gray.opacity(0.3) : Color.white.opacity(0.2))
                .cornerRadius(14)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 34)
    }
    
    // MARK: - 加载壁纸图片
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
    
    // MARK: - 保存到相册
    private func saveToPhotos() {
        guard let image = loadWallpaperImage(wallpaper.imageName) else {
            showSaveError = true
            return
        }
        
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        showSaveSuccess = true
    }
}

#Preview {
    WallpaperPreviewView(
        wallpaper: ThemeWallpaper(
            themeId: UUID(),
            name: "测试壁纸",
            imageName: "wallpaper_test",
            isPremium: true
        ),
        isSubscribed: false,
        onSubscribeTap: {}
    )
}
