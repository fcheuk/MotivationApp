//
//  FavoriteView.swift
//  MotivationApp
//
//  Created on 2025-12-09.
//

import SwiftUI

struct FavoriteView: View {
    @StateObject private var viewModel = FavoriteViewModel()
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.favoriteQuotes.isEmpty {
                    // 空状态
                    VStack(spacing: 16) {
                        Image(systemName: "heart.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("还没有收藏的语录")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("在首页或主题中点击❤️收藏喜欢的语录")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    // 收藏列表
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.favoriteQuotes) { quote in
                                FavoriteQuoteCard(
                                    quote: quote,
                                    categoryName: viewModel.getCategoryName(for: quote),
                                    onRemove: {
                                        withAnimation {
                                            viewModel.removeFavorite(quote)
                                        }
                                    }
                                )
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("我的收藏")
        }
    }
}

struct FavoriteQuoteCard: View {
    let quote: Quote
    let categoryName: String
    let onRemove: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 分类标签
            Text(categoryName)
                .font(.caption)
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color(hex: "#FF6B6B"))
                .cornerRadius(8)
            
            // 语录内容
            Text(quote.content)
                .font(.body)
                .foregroundColor(.primary)
            
            // 作者和操作
            HStack {
                Text(quote.author)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: onRemove) {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .cardStyle()
    }
}

#Preview {
    FavoriteView()
        .environmentObject(DataManager.shared)
}
