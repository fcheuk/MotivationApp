//
//  MainTabView.swift
//  MotivationApp
//
//  Created on 2025-12-09.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 首页
            HomeView()
                .tabItem {
                    Label("首页", systemImage: "house.fill")
                }
                .tag(0)
            
            // 主题
            CategoryListView()
                .tabItem {
                    Label("主题", systemImage: "square.grid.2x2.fill")
                }
                .tag(1)
            
            // 收藏
            FavoriteView()
                .tabItem {
                    Label("收藏", systemImage: "heart.fill")
                }
                .tag(2)
            
            // 日历
            CalendarView()
                .tabItem {
                    Label("日历", systemImage: "calendar")
                }
                .tag(3)
            
            // 话题
            TopicListView()
                .tabItem {
                    Label("话题", systemImage: "bubble.left.and.bubble.right.fill")
                }
                .tag(4)
        }
        .accentColor(Color(hex: "#FF6B6B"))
    }
}

#Preview {
    MainTabView()
        .environmentObject(DataManager.shared)
}
