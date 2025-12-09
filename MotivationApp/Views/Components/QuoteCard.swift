//
//  QuoteCard.swift
//  MotivationApp
//
//  Created on 2025-12-09.
//

import SwiftUI

struct QuoteCard: View {
    let quote: Quote
    let onFavorite: () -> Void
    let onShare: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            // 语录内容
            Text(quote.content)
                .font(.title2)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
                .padding(.horizontal)
            
            // 作者
            Text("— \(quote.author)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // 操作按钮
            HStack(spacing: 32) {
                Button(action: onFavorite) {
                    Image(systemName: quote.isFavorite ? "heart.fill" : "heart")
                        .font(.title2)
                        .foregroundColor(quote.isFavorite ? .red : .gray)
                }
                
                Button(action: onShare) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }
            .padding(.top, 8)
        }
        .padding(Constants.UI.cardPadding)
        .frame(maxWidth: .infinity)
        .cardStyle()
    }
}

#Preview {
    QuoteCard(
        quote: Quote.sampleQuotes[0],
        onFavorite: {},
        onShare: {}
    )
    .padding()
}
