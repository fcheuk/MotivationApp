//
//  SubscriptionView.swift
//  MotivationApp
//
//  Created on 2026-01-18.
//

import SwiftUI

struct SubscriptionView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss
    @State private var selectedPlan: SubscriptionPlan = .yearly
    @State private var isProcessing = false
    
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
                    isSelected: selectedPlan == plan
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
                if isProcessing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                } else {
                    Text("立即订阅")
                        .font(.system(size: 18, weight: .bold))
                }
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
        .disabled(isProcessing)
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
        isProcessing = true
        
        // 模拟订阅流程（实际应接入 StoreKit）
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            var settings = dataManager.settings
            settings.isSubscribed = true
            settings.subscriptionExpiryDate = Calendar.current.date(
                byAdding: selectedPlan == .yearly ? .year : .month,
                value: 1,
                to: Date()
            )
            dataManager.settings = settings
            dataManager.saveSettings()
            
            isProcessing = false
            dismiss()
        }
    }
    
    private func restorePurchase() {
        // 模拟恢复购买（实际应接入 StoreKit）
        isProcessing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isProcessing = false
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
    
    var price: String {
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
    let onTap: () -> Void
    
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
                    Text(plan.price)
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
