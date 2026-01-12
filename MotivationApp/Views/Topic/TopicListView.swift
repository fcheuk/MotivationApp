//
//  TopicListView.swift
//  MotivationApp
//
//  Created on 2026-01-12.
//

import SwiftUI

struct TopicListView: View {
    @StateObject private var viewModel = TopicViewModel()
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
                        searchBar
                        unlockPromoBanner
                        quickAccessSection
                        categoriesSection
                        
                        Spacer(minLength: 300)
                        
                        bottomUnlockSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)
                }
            }
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
    
    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.white.opacity(0.5))
                .font(.system(size: 16))
            
            TextField("搜索话题", text: $viewModel.searchText)
                .foregroundColor(.white)
                .font(.system(size: 16))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var unlockPromoBanner: some View {
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
    
    private var quickAccessSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            let columns = [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ]
            
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(viewModel.quickAccessTopics) { topic in
                    TopicCard(topic: topic)
                }
            }
        }
    }
    
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("分类")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            ForEach(viewModel.categoryTopics) { topic in
                TopicCard(topic: topic, isFullWidth: true)
            }
        }
    }
    
    private var bottomUnlockSection: some View {
        VStack(spacing: 24) {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(hex: "#4A5568") ?? .gray,
                        Color(hex: "#2D3748") ?? .gray
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    Text("购买高级版")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("解锁所有话题")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.vertical, 60)
            }
            .frame(height: 200)
            .cornerRadius(20)
            
            Button(action: {
            }) {
                Text("解锁全部")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(.white)
                    .cornerRadius(25)
            }
        }
    }
}

struct TopicCard: View {
    let topic: Topic
    var isFullWidth: Bool = false
    
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
            
            if topic.isLocked {
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
