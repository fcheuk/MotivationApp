//
//  SettingsView.swift
//  MotivationApp
//
//  Created on 2025-12-09.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var showSubscriptionView = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        ZStack {
            Color(hex: "#2C3E50")
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    topNavigationBar
                    
                    VStack(spacing: 24) {
                        titleSection
                        
                        // 升级高级版横幅
                        if subscriptionManager.isSubscribed {
                            SubscribedBanner(expirationDate: subscriptionManager.subscriptionExpirationDate)
                        } else {
                            PremiumBanner {
                                showSubscriptionView = true
                            }
                        }
                        
                        // 设置列表
                        VStack(spacing: 0) {
                            SettingsRow(icon: "square.grid.2x2", title: "小组件设定")
                            
                            SettingsRow(icon: "lock.shield", title: "隐私政策") {
                                openURL("https://example.com/privacy")
                            }
                            
                            SettingsRow(icon: "doc.text", title: "服务条款") {
                                openURL("https://example.com/terms")
                            }
                            
                            SettingsRow(icon: "star", title: "给我们评价") {
                                rateApp()
                            }
                            
                            SettingsRow(icon: "arrow.clockwise", title: "恢复购买") {
                                restorePurchases()
                            }
                        }
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)
                }
            }
        }
        .sheet(isPresented: $showSubscriptionView) {
            SubscriptionView()
        }
        .alert("提示", isPresented: $showAlert) {
            Button("确定", role: .cancel) {}
        } message: {
            Text(alertMessage)
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
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    private var titleSection: some View {
        HStack {
            Text("设置")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
            Spacer()
        }
        .padding(.top, 8)
    }
    
    private func rateApp() {
        if let url = URL(string: "https://apps.apple.com/app/motivation") {
            UIApplication.shared.open(url)
        }
    }
    
    private func openURL(_ urlString: String) {
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
    private func restorePurchases() {
        Task {
            await subscriptionManager.restorePurchases()
            if let error = subscriptionManager.errorMessage {
                alertMessage = error
                showAlert = true
            } else if subscriptionManager.isSubscribed {
                alertMessage = "购买已恢复"
                showAlert = true
            }
        }
    }
}

// MARK: - 高级版横幅
struct PremiumBanner: View {
    var onTap: (() -> Void)? = nil
    
    var body: some View {
        Button(action: { onTap?() }) {
        ZStack(alignment: .leading) {
            LinearGradient(
                colors: [
                    Color(hex: "#FFB6C1") ?? .pink,
                    Color(hex: "#B19CD9") ?? .purple
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("升级高级版")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text("解锁所有功能，找到内心的平静。")
                        .font(.system(size: 13))
                        .foregroundColor(.black.opacity(0.7))
                }
                .padding(.leading, 20)
                
                Spacer()
                
                Image(systemName: "heart.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.black.opacity(0.2))
                    .padding(.trailing, 20)
            }
        }
        .frame(height: 120)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 已订阅横幅
struct SubscribedBanner: View {
    var expirationDate: Date?
    
    private var expirationText: String {
        if let date = expirationDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy年MM月dd日"
            return "有效期至 \(formatter.string(from: date))"
        }
        return "永久有效"
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            LinearGradient(
                colors: [
                    Color(hex: "#4CAF50") ?? .green,
                    Color(hex: "#2E7D32") ?? .green
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.yellow)
                        
                        Text("高级版会员")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Text(expirationText)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.leading, 20)
                
                Spacer()
                
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.white.opacity(0.2))
                    .padding(.trailing, 20)
            }
        }
        .frame(height: 100)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

// MARK: - 设置行
struct SettingsRow: View {
    let icon: String
    let title: String
    var action: (() -> Void)? = nil
    
    var body: some View {
        Button(action: { action?() }) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.white.opacity(0.8))
                    .frame(width: 40, height: 40)
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(DataManager.shared)
}
