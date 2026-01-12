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
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color(hex: "#1C1C1E")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                topNavigationBar
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        titleSection
                        filterSection
                        
                        if !viewModel.combinedThemes.isEmpty {
                            combinedThemesSection
                        }
                        
                        recommendedSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                }
            }
        }
        .sheet(item: $selectedCategory) { category in
            CategoryDetailView(category: category)
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
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            Button(action: {
            }) {
                Text("解锁全部")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(20)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    private var titleSection: some View {
        Text("主题")
            .font(.system(size: 32, weight: .bold))
            .foregroundColor(.white)
            .padding(.top, 8)
    }
    
    private var filterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                Button(action: {
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .semibold))
                        Text("创建主题")
                            .font(.system(size: 15, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(20)
                }
                
                ForEach(CategoryFilter.allCases, id: \.self) { filter in
                    FilterChip(
                        title: filter.rawValue,
                        isSelected: viewModel.selectedFilter == filter
                    ) {
                        viewModel.setFilter(filter)
                    }
                }
            }
        }
    }
    
    private var combinedThemesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("组合主题")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                }) {
                    Text("查看全部")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.combinedThemes) { category in
                        Button(action: {
                            selectedCategory = category
                            viewModel.selectCategory(category)
                        }) {
                            CombinedThemeCard(
                                category: category,
                                width: 200,
                                height: 140
                            )
                        }
                    }
                }
            }
        }
    }
    
    private var recommendedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("推荐")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            let columns = [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ]
            
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(viewModel.filteredCategories) { category in
                    Button(action: {
                        selectedCategory = category
                        viewModel.selectCategory(category)
                    }) {
                        ThemeCard(
                            category: category,
                            width: (UIScreen.main.bounds.width - 44) / 2,
                            height: 200
                        )
                    }
                }
            }
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(isSelected ? Color(hex: "#1C1C1E") : .white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(isSelected ? .white : Color.white.opacity(0.15))
                .cornerRadius(20)
        }
    }
}

#Preview {
    CategoryListView()
        .environmentObject(DataManager.shared)
}
