//
//  SubscriptionManager.swift
//  MotivationApp
//
//  Created on 2026-01-22.
//

import Foundation
import StoreKit

/// 订阅管理器 - 使用 StoreKit 2 处理应用内订阅
@MainActor
class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()
    
    // MARK: - Published Properties
    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs: Set<String> = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var subscriptionStatus: SubscriptionStatus = .notSubscribed
    
    // MARK: - Subscription Status
    enum SubscriptionStatus: Equatable {
        case notSubscribed
        case subscribed(expirationDate: Date?)
        case expired
        case inGracePeriod
        
        var isActive: Bool {
            switch self {
            case .subscribed, .inGracePeriod:
                return true
            case .notSubscribed, .expired:
                return false
            }
        }
    }
    
    // MARK: - Private Properties
    private var updateListenerTask: Task<Void, Error>?
    private let productIDs: Set<String> = [
        Constants.Subscription.monthlyProductID,
        Constants.Subscription.yearlyProductID
    ]
    
    // MARK: - Initialization
    private init() {
        updateListenerTask = listenForTransactions()
        
        Task {
            await loadProducts()
            await updateSubscriptionStatus()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Load Products
    func loadProducts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let storeProducts = try await Product.products(for: productIDs)
            
            // 按价格排序（月度在前，年度在后）
            products = storeProducts.sorted { $0.price < $1.price }
            isLoading = false
        } catch {
            errorMessage = "无法加载产品信息: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    // MARK: - Purchase
    func purchase(_ product: Product) async throws -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await updateSubscriptionStatus()
                await transaction.finish()
                isLoading = false
                return true
                
            case .userCancelled:
                isLoading = false
                return false
                
            case .pending:
                isLoading = false
                errorMessage = "购买待处理，请稍后查看"
                return false
                
            @unknown default:
                isLoading = false
                return false
            }
        } catch {
            isLoading = false
            errorMessage = "购买失败: \(error.localizedDescription)"
            throw error
        }
    }
    
    // MARK: - Restore Purchases
    func restorePurchases() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await AppStore.sync()
            await updateSubscriptionStatus()
            isLoading = false
            
            if subscriptionStatus.isActive {
                errorMessage = nil
            } else {
                errorMessage = "未找到可恢复的购买"
            }
        } catch {
            isLoading = false
            errorMessage = "恢复购买失败: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Update Subscription Status
    func updateSubscriptionStatus() async {
        var foundActiveSubscription = false
        var latestExpirationDate: Date?
        
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                
                if productIDs.contains(transaction.productID) {
                    purchasedProductIDs.insert(transaction.productID)
                    foundActiveSubscription = true
                    
                    if let expirationDate = transaction.expirationDate {
                        if latestExpirationDate == nil || expirationDate > latestExpirationDate! {
                            latestExpirationDate = expirationDate
                        }
                    }
                }
            } catch {
                // 验证失败，跳过此交易
                continue
            }
        }
        
        if foundActiveSubscription {
            subscriptionStatus = .subscribed(expirationDate: latestExpirationDate)
        } else {
            subscriptionStatus = .notSubscribed
            purchasedProductIDs.removeAll()
        }
    }
    
    // MARK: - Transaction Listener
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached { [weak self] in
            for await result in Transaction.updates {
                do {
                    guard let self = self else { return }
                    let transaction = try self.checkVerified(result)
                    await self.updateSubscriptionStatus()
                    await transaction.finish()
                } catch {
                    // 交易验证失败
                }
            }
        }
    }
    
    // MARK: - Verify Transaction
    private nonisolated func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    // MARK: - Helper Methods
    var isSubscribed: Bool {
        subscriptionStatus.isActive
    }
    
    var subscriptionExpirationDate: Date? {
        if case .subscribed(let date) = subscriptionStatus {
            return date
        }
        return nil
    }
    
    func product(for productID: String) -> Product? {
        products.first { $0.id == productID }
    }
    
    var monthlyProduct: Product? {
        product(for: Constants.Subscription.monthlyProductID)
    }
    
    var yearlyProduct: Product? {
        product(for: Constants.Subscription.yearlyProductID)
    }
}

// MARK: - Store Errors
enum StoreError: Error, LocalizedError {
    case failedVerification
    case purchaseFailed
    case productNotFound
    
    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "交易验证失败"
        case .purchaseFailed:
            return "购买失败"
        case .productNotFound:
            return "未找到产品"
        }
    }
}
