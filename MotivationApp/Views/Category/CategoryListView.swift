//
//  CategoryListView.swift
//  MotivationApp
//
//  Created on 2025-12-09.
//

import SwiftUI

struct CategoryListView: View {
    @StateObject private var viewModel = CategoryViewModel()
    @State private var selectedCategory: Category?
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.categories) { category in
                        Button(action: {
                            selectedCategory = category
                            viewModel.selectCategory(category)
                        }) {
                            CategoryCard(
                                category: category,
                                quoteCount: viewModel.getQuoteCount(for: category)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
            .navigationTitle("主题分类")
            .sheet(item: $selectedCategory) { category in
                CategoryDetailView(category: category)
            }
        }
    }
}

#Preview {
    CategoryListView()
        .environmentObject(DataManager.shared)
}
