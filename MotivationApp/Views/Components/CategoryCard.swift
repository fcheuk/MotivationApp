//
//  CategoryCard.swift
//  MotivationApp
//
//  Created on 2025-12-09.
//

import SwiftUI

struct CategoryCard: View {
    let category: Category
    let quoteCount: Int
    
    var body: some View {
        VStack(spacing: 12) {
            // 图标
            Image(systemName: category.icon)
                .font(.system(size: 32))
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(
                    Circle()
                        .fill(category.color)
                )
            
            // 分类名称
            Text(category.name)
                .font(.headline)
                .foregroundColor(.primary)
            
            // 语录数量
            Text("\(quoteCount) 条")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(width: Constants.UI.categoryCardSize, height: Constants.UI.categoryCardSize + 20)
        .cardStyle()
    }
}

#Preview {
    CategoryCard(
        category: Category.sampleCategories[0],
        quoteCount: 10
    )
    .padding()
}
