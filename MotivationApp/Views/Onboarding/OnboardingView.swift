//
//  OnboardingView.swift
//  MotivationApp
//
//  Created on 2025-12-09.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0
    
    let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "quote.bubble.fill",
            title: "欢迎使用激励语录",
            description: "每天一句激励语录\n让你充满正能量",
            color: Color(hex: "#FF6B6B") ?? .red
        ),
        OnboardingPage(
            icon: "heart.text.square.fill",
            title: "丰富的主题分类",
            description: "励志、自信、生活、学习\n多种主题任你选择",
            color: Color(hex: "#4ECDC4") ?? .blue
        ),
        OnboardingPage(
            icon: "calendar.badge.checkmark",
            title: "打卡记录你的成长",
            description: "坚持每日阅读\n见证自己的进步",
            color: Color(hex: "#95E1D3") ?? .green
        )
    ]
    
    var body: some View {
        VStack {
            // 页面内容
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    OnboardingPageView(page: pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            
            // 底部按钮
            Button(action: {
                if currentPage < pages.count - 1 {
                    withAnimation {
                        currentPage += 1
                    }
                } else {
                    hasCompletedOnboarding = true
                }
            }) {
                Text(currentPage < pages.count - 1 ? "下一步" : "开始使用")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(pages[currentPage].color)
                    .cornerRadius(Constants.UI.cornerRadius)
            }
            .padding(.horizontal, Constants.UI.padding)
            .padding(.bottom, 32)
        }
    }
}

struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
    let color: Color
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: page.icon)
                .font(.system(size: 100))
                .foregroundColor(page.color)
            
            Text(page.title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text(page.description)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
    }
}

#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
}
