//
//  ThemeCard.swift
//  MotivationApp
//
//  Created on 2026-01-12.
//

import SwiftUI

struct ThemeCard: View {
    let category: Category
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let imageName = category.imageName {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: width, height: height)
                    .clipped()
            } else {
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                category.color.opacity(0.8),
                                category.color
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: width, height: height)
            }
            
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0),
                    Color.black.opacity(0.7)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(category.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            .padding(12)
        }
        .frame(width: width, height: height)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct CombinedThemeCard: View {
    let category: Category
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        ZStack(alignment: .center) {
            if let imageName = category.imageName {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: width, height: height)
                    .clipped()
            } else {
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                category.color.opacity(0.8),
                                category.color
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: width, height: height)
            }
            
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.3),
                    Color.black.opacity(0.5)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            
            Text(category.name)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .frame(width: width, height: height)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    VStack(spacing: 20) {
        ThemeCard(
            category: Category.sampleCategories[2],
            width: 160,
            height: 200
        )
        
        CombinedThemeCard(
            category: Category.sampleCategories[0],
            width: 200,
            height: 140
        )
    }
    .padding()
}
