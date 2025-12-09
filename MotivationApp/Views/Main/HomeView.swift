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
    @State private var showSettings = false
    @State private var showShareSheet = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 标题
                    VStack(spacing: 8) {
                        Text("今日激励")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(Date().formatted(style: .long))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // 连续打卡天数
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("已连续打卡 \(dataManager.getConsecutiveDays()) 天")
                            .font(.headline)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(Constants.UI.cornerRadius)
                    .padding(.horizontal)
                    
                    // 语录卡片
                    if let quote = viewModel.currentQuote {
                        QuoteCard(
                            quote: quote,
                            onFavorite: {
                                withAnimation {
                                    viewModel.toggleFavorite()
                                }
                            },
                            onShare: {
                                showShareSheet = true
                            }
                        )
                        .padding(.horizontal)
                    }
                    
                    // 刷新按钮
                    Button(action: {
                        withAnimation {
                            viewModel.loadRandomQuote()
                            dataManager.checkIn()
                        }
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("换一条")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "#FF6B6B"))
                        .cornerRadius(Constants.UI.cornerRadius)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showShareSheet) {
                if let quote = viewModel.currentQuote {
                    ShareSheet(items: [viewModel.shareQuote()])
                }
            }
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
