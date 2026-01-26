//
//  TopicListView.swift
//  MotivationApp
//
//  Created on 2026-01-12.
//

import SwiftUI

struct TopicListView: View {
    @EnvironmentObject var dataManager: DataManager
    @StateObject private var viewModel = TopicViewModel()
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var showSubscriptionSheet = false
    @State private var selectedTopic: Topic?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color(hex: "#2C3E50")
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    topNavigationBar
                    
                    VStack(spacing: 24) {
                        titleSection
                        
                        // 未订阅时显示解锁横幅
                        if !subscriptionManager.isSubscribed {
                            unlockPromoBanner
                        }
                        
                        categoriesSection
                        
                        // 底部解锁全部按钮（未订阅时显示）
                        if !subscriptionManager.isSubscribed {
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
        .fullScreenCover(item: $selectedTopic) { topic in
            TopicDetailView(topic: topic)
                .environmentObject(dataManager)
        }
    }
    
    // MARK: - 处理话题点击
    private func handleTopicTap(_ topic: Topic) {
        let isLocked = topic.isLocked && !subscriptionManager.isSubscribed
        if isLocked {
            showSubscriptionSheet = true
        } else {
            selectedTopic = topic
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
            
            Button(action: {
            }) {
                Text("编辑")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    private var titleSection: some View {
        HStack {
            Text("探索话题")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
            Spacer()
        }
        .padding(.top, 8)
    }
    
    private var unlockPromoBanner: some View {
        Button(action: {
            showSubscriptionSheet = true
        }) {
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
                        Text("解锁所有话题")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.black)
                        
                        Text("浏览跟喜欢的话题并进行关注，这样就能得更具个性化的体验")
                            .font(.system(size: 13))
                            .foregroundColor(.black.opacity(0.7))
                            .lineLimit(2)
                    }
                    .padding(.leading, 20)
                    
                    Spacer()
                    
                    Image(systemName: "iphone")
                        .font(.system(size: 60))
                        .foregroundColor(.black.opacity(0.2))
                        .rotationEffect(.degrees(15))
                        .padding(.trailing, 20)
                }
            }
            .frame(height: 120)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        }
    }
    
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(viewModel.categoryTopics) { topic in
                Button(action: { handleTopicTap(topic) }) {
                    TopicCard(
                        topic: topic,
                        isFullWidth: true,
                        isSubscribed: subscriptionManager.isSubscribed
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
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
                Text("解锁全部话题")
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

struct TopicCard: View {
    let topic: Topic
    var isFullWidth: Bool = false
    var isSubscribed: Bool = false
    
    // 订阅后解锁所有话题
    private var isLocked: Bool {
        topic.isLocked && !isSubscribed
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: topic.icon)
                .font(.system(size: 20))
                .foregroundColor(.white.opacity(0.8))
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(topic.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
            
            Spacer()
            
            if isLocked {
                Image(systemName: "lock.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
        .frame(maxWidth: isFullWidth ? .infinity : nil)
    }
}

#Preview {
    TopicListView()
}
