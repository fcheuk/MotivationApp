//
//  CategoryDetailView.swift
//  MotivationApp
//
//  Created on 2025-12-09.
//

import SwiftUI

struct CategoryDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    let category: Category
    
    var quotes: [Quote] {
        dataManager.getQuotes(for: category.id)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // 分类信息
                    VStack(spacing: 12) {
                        Image(systemName: category.icon)
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                            .frame(width: 100, height: 100)
                            .background(
                                Circle()
                                    .fill(category.color)
                            )
                        
                        Text(category.name)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(category.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("\(quotes.count) 条语录")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 20)
                    
                    // 语录列表
                    ForEach(quotes) { quote in
                        QuoteListItem(quote: quote)
                            .padding(.horizontal)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct QuoteListItem: View {
    @EnvironmentObject var dataManager: DataManager
    let quote: Quote
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(quote.content)
                .font(.body)
                .foregroundColor(.primary)
            
            HStack {
                Text(quote.author)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: {
                    dataManager.toggleFavorite(quote: quote)
                }) {
                    Image(systemName: quote.isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(quote.isFavorite ? .red : .gray)
                }
            }
        }
        .padding()
        .cardStyle()
    }
}

#Preview {
    CategoryDetailView(category: Category.sampleCategories[0])
        .environmentObject(DataManager.shared)
}
