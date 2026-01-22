//
//  SubscriptionView.swift
//  MotivationApp
//
//  Created on 2026-01-18.
//

import SwiftUI
import StoreKit

struct SubscriptionView: View {
    @EnvironmentObject var dataManager: DataManager
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @Environment(\.dismiss) var dismiss
    @State private var selectedPlan: SubscriptionPlan = .yearly
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        ZStack {
            // 背景渐变
            LinearGradient(
                colors: [
                    Color(hex: "#1a1a2e") ?? .black,
                    Color(hex: "#16213e") ?? .blue,
                    Color(hex: "#0f3460") ?? .blue
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 关闭按钮
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                            .frame(width: 32, height: 32)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        headerSection
                        featuresSection
                        plansSection
                        subscribeButton
                        termsSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            
            if subscriptionManager.isLoading {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            }
        }
        .alert("提示", isPresented: $showAlert) {
            Button("确定", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
        .onChange(of: subscriptionManager.isSubscribed) { _, isSubscribed in
            if isSubscribed {
                dismiss()
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // 皇冠图标
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.yellow, Color.orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Image(systemName: "crown.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.white)
            }
            
            Text("解锁高级版")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            
            Text("畅享所有主题壁纸和高级功能")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
    }
    
    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            FeatureRow(icon: "photo.stack.fill", title: "全部主题壁纸", description: "解锁所有精选壁纸")
            FeatureRow(icon: "arrow.down.circle.fill", title: "无限下载", description: "随时下载喜欢的壁纸")
            FeatureRow(icon: "sparkles", title: "优先更新", description: "第一时间获取新壁纸")
            FeatureRow(icon: "xmark.circle.fill", title: "无广告体验", description: "纯净无干扰的使用体验")
        }
        .padding(20)
        .background(Color.white.opacity(0.08))
        .cornerRadius(20)
    }
    
    private var plansSection: some View {
        VStack(spacing: 12) {
            ForEach(SubscriptionPlan.allCases, id: \.self) { plan in
                PlanCard(
                    plan: plan,
                    isSelected: selectedPlan == plan,
                    product: plan == .monthly ? subscriptionManager.monthlyProduct : subscriptionManager.yearlyProduct
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedPlan = plan
                    }
                }
            }
        }
    }
    
    private var subscribeButton: some View {
        Button(action: {
            subscribe()
        }) {
            HStack {
                Text(subscribeButtonText)
                    .font(.system(size: 18, weight: .bold))
            }
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                LinearGradient(
                    colors: [Color.yellow, Color.orange],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
        }
        .disabled(subscriptionManager.isLoading)
    }
    
    private var subscribeButtonText: String {
        let product = selectedPlan == .monthly ? subscriptionManager.monthlyProduct : subscriptionManager.yearlyProduct
        if let product = product {
            return "立即订阅 \(product.displayPrice)"
        }
        return "立即订阅"
    }
    
    private var termsSection: some View {
        VStack(spacing: 8) {
            Text("订阅将自动续费，可随时在设置中取消")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.5))
            
            HStack(spacing: 16) {
                Button("服务条款") {}
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
                
                Button("隐私政策") {}
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
                
                Button("恢复购买") {
                    restorePurchase()
                }
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.6))
            }
        }
    }
    
    private func subscribe() {
        let product = selectedPlan == .monthly ? subscriptionManager.monthlyProduct : subscriptionManager.yearlyProduct
        
        guard let product = product else {
            alertMessage = "产品信息加载中，请稍后再试"
            showAlert = true
            return
        }
        
        Task {
            do {
                let success = try await subscriptionManager.purchase(product)
                if success {
                    // 购买成功，视图会自动关闭
                }
            } catch {
                alertMessage = error.localizedDescription
                showAlert = true
            }
        }
    }
    
    private func restorePurchase() {
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

// MARK: - 订阅计划
enum SubscriptionPlan: CaseIterable {
    case monthly
    case yearly
    
    var title: String {
        switch self {
        case .monthly: return "月度订阅"
        case .yearly: return "年度订阅"
        }
    }
    
    var fallbackPrice: String {
        switch self {
        case .monthly: return "¥18"
        case .yearly: return "¥128"
        }
    }
    
    var period: String {
        switch self {
        case .monthly: return "/月"
        case .yearly: return "/年"
        }
    }
    
    var savings: String? {
        switch self {
        case .monthly: return nil
        case .yearly: return "省40%"
        }
    }
}

// MARK: - 功能行
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(.yellow)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
        }
    }
}

// MARK: - 计划卡片
struct PlanCard: View {
    let plan: SubscriptionPlan
    let isSelected: Bool
    var product: Product?
    let onTap: () -> Void
    
    private var displayPrice: String {
        product?.displayPrice ?? plan.fallbackPrice
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(plan.title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        if let savings = plan.savings {
                            Text(savings)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.yellow)
                                .cornerRadius(8)
                        }
                    }
                }
                
                Spacer()
                
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(displayPrice)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(plan.period)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.white.opacity(0.15) : Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.yellow : Color.white.opacity(0.1), lineWidth: isSelected ? 2 : 1)
            )
        }
    }
}

#Preview {
    SubscriptionView()
        .environmentObject(DataManager.shared)
}
