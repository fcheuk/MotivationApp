//
//  SettingsView.swift
//  MotivationApp
//
//  Created on 2025-12-09.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // 升级高级版横幅
                    PremiumBanner()
                        .padding(.horizontal)
                        .padding(.top, 16)
                        .padding(.bottom, 24)
                    
                    // 设置列表
                    VStack(spacing: 0) {
                        SettingsRow(icon: "square.grid.2x2", title: "小组件设定")
                        Divider().padding(.leading, 56)
                        
                        SettingsRow(icon: "lock.shield", title: "隐私政策") {
                            openURL("https://example.com/privacy")
                        }
                        Divider().padding(.leading, 56)
                        
                        SettingsRow(icon: "doc.text", title: "服务条款") {
                            openURL("https://example.com/terms")
                        }
                        Divider().padding(.leading, 56)
                        
                        SettingsRow(icon: "star", title: "给我们评价") {
                            rateApp()
                        }
                        Divider().padding(.leading, 56)
                        
                        SettingsRow(icon: "arrow.clockwise", title: "恢复购买")
                    }
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.primary)
                    }
                }
            }
        }
    }
    
    private func rateApp() {
        if let url = URL(string: "https://apps.apple.com/app/motivation") {
            UIApplication.shared.open(url)
        }
    }
    
    private func openURL(_ urlString: String) {
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - 高级版横幅
struct PremiumBanner: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("升级高级版")
                    .font(.headline)
                    .foregroundColor(.primary)
                Text("解锁所有功能，找到内心的平静。")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "heart.fill")
                .font(.system(size: 40))
                .foregroundColor(.red)
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

// MARK: - 设置行
struct SettingsRow: View {
    let icon: String
    let title: String
    var action: (() -> Void)? = nil
    
    var body: some View {
        Button(action: { action?() }) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(.white.opacity(0.7))
                    .frame(width: 28, height: 28)
                
                Text(title)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(DataManager.shared)
}
