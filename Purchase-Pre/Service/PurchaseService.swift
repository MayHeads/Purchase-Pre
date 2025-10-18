//
//  PurchaseService.swift
//  Purchase-Pre
//
//  Created by mayheaders on 2025/10/18.
//

import Foundation
import StoreKit
import SwiftyStoreKit
import Combine
import Dispatch

/// 内购服务管理类
class PurchaseService: ObservableObject {
    
    static let shared = PurchaseService()
    
    @Published var products: [ProductInfo] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let userDefaults = UserDefaults.standard
    private let purchasedProductsKey = "PurchasedProducts"
    
    private init() {
        setupTransactionObserver()
    }
    
    // MARK: - 初始化设置
    
    /// 设置交易观察者
    private func setupTransactionObserver() {
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    self.savePurchasedProduct(purchase.productId)
                case .failed, .purchasing, .deferred:
                    break
                @unknown default:
                    break
                }
            }
        }
    }
    
    // MARK: - 商品信息获取
    
    /// 获取商品信息
    func fetchProducts(productIds: [String]) {
        isLoading = true
        errorMessage = nil
        
        SwiftyStoreKit.retrieveProductsInfo(Set(productIds)) { result in
         
                
                self.isLoading = false
                
                if let error = result.error {
                    self.errorMessage = "获取商品信息失败: \(error.localizedDescription)"
                    return
                }
            
               let invalidIDs = result.invalidProductIDs
            
                print("Invalid product IDs: \(invalidIDs)")
            
                let count = result.retrievedProducts.count
            
            print("Retrieved \(count) products")
                
                var products: [ProductInfo] = []
                for product in result.retrievedProducts {
                    
                    print("Product: \(product.localizedDescription), price: \(product.priceLocale.currencySymbol ?? "")\(product.price)")
                    
                    let skProduct = product as SKProduct
//                    let productInfo = ProductInfo(
//                        productId: product.id,
//                        title: product.displayName,
//                        description: product.description,
//                        price: product.displayPrice,
//                        isPurchased: self.isProductPurchased(product.id)
//                    )
//                    products.append(productInfo)
                }
                
                self.products = products
//            }
        }
    }
    
    // MARK: - 购买功能
    
    /// 购买商品
    func purchaseProduct(productId: String, completion: @escaping (PurchaseResult) -> Void) {
        SwiftyStoreKit.purchaseProduct(productId, quantity: 1, atomically: true) { result in
//            DispatchQueue.main.async { [weak self] in
//                guard let self = self else { return }
                
                switch result {
                case .success(let purchase):
                    let productInfo = ProductInfo(
                        productId: purchase.productId,
                        title: self.getProductTitle(for: purchase.productId),
                        description: self.getProductDescription(for: purchase.productId),
                        price: self.getProductPrice(for: purchase.productId),
                        isPurchased: true
                    )
                    self.savePurchasedProduct(purchase.productId)
                    completion(.success(productInfo))
                    
                case .error(let error):
                    let errorMessage = self.getErrorMessage(for: error)
                    completion(.failure(errorMessage))
                    
               
                }
//            }
        }
    }
    
    // MARK: - 恢复购买
    
    /// 恢复购买
    func restorePurchases(completion: @escaping (RestoreResult) -> Void) {
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            DispatchQueue.main.async { [weak self] in
                if results.restoreFailedPurchases.count > 0 {
                    completion(.failure("恢复购买失败"))
                } else if results.restoredPurchases.count > 0 {
                    var restoredProducts: [ProductInfo] = []
                    for purchase in results.restoredPurchases {
                        let productInfo = ProductInfo(
                            productId: purchase.productId,
                            title: self?.getProductTitle(for: purchase.productId) ?? "未知商品",
                            description: self?.getProductDescription(for: purchase.productId) ?? "商品描述",
                            price: self?.getProductPrice(for: purchase.productId) ?? "价格未知",
                            isPurchased: true
                        )
                        restoredProducts.append(productInfo)
                        self?.savePurchasedProduct(purchase.productId)
                    }
                    completion(.success(restoredProducts))
                } else {
                    completion(.nothingToRestore)
                }
            }
        }
    }
    
    // MARK: - 本地存储管理
    
    /// 保存已购买商品
    private func savePurchasedProduct(_ productId: String) {
        var purchasedProducts = getPurchasedProducts()
        if !purchasedProducts.contains(productId) {
            purchasedProducts.append(productId)
            userDefaults.set(purchasedProducts, forKey: purchasedProductsKey)
        }
    }
    
    /// 获取已购买商品列表
    private func getPurchasedProducts() -> [String] {
        return userDefaults.stringArray(forKey: purchasedProductsKey) ?? []
    }
    
    /// 检查商品是否已购买
    func isProductPurchased(_ productId: String) -> Bool {
        return getPurchasedProducts().contains(productId)
    }
    
    // MARK: - 辅助方法
    
    /// 获取商品标题
    private func getProductTitle(for productId: String) -> String {
        return products.first { $0.productId == productId }?.title ?? "未知商品"
    }
    
    /// 获取商品描述
    private func getProductDescription(for productId: String) -> String {
        return products.first { $0.productId == productId }?.description ?? "商品描述"
    }
    
    /// 获取商品价格
    private func getProductPrice(for productId: String) -> String {
        return products.first { $0.productId == productId }?.price ?? "价格未知"
    }
    
    /// 获取错误信息
    private func getErrorMessage(for error: SKError) -> String {
        switch error.code {
        case .unknown:
            return "未知错误，请联系客服"
        case .clientInvalid:
            return "不允许进行支付"
        case .paymentCancelled:
            return "用户取消支付"
        case .paymentInvalid:
            return "购买标识符无效"
        case .paymentNotAllowed:
            return "设备不允许进行支付"
        case .storeProductNotAvailable:
            return "商品在当前商店不可用"
        case .cloudServicePermissionDenied:
            return "拒绝访问云服务信息"
        case .cloudServiceNetworkConnectionFailed:
            return "无法连接到网络"
        case .cloudServiceRevoked:
            return "用户已撤销使用此云服务的权限"
        default:
            return error.localizedDescription
        }
    }
}
