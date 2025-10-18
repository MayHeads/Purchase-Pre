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
                    let productInfo = ProductInfo(
                        productId: skProduct.productIdentifier,
                        title: skProduct.localizedTitle,
                        description: skProduct.localizedDescription,
                        price: skProduct.price.stringValue,
                        isPurchased: self.isProductPurchased(skProduct.productIdentifier)
                    )
                    products.append(productInfo)
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
                    
                    print("购买成功: \(purchase.productId)")
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
                    print("购买失败: \(error.localizedDescription)")
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
    
    /// 检查是否购买了指定产品（从苹果服务器验证）
    func checkProductPurchased(productId: String, completion: @escaping (Bool) -> Void) {
        SwiftyStoreKit.verifyReceipt(using: AppleReceiptValidator(service: .sandbox, sharedSecret: "f283f4bb1bcb4fc7ab4a3ab63f07b6fd")) { result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success(let receipt):
                    let isPurchased = self?.checkProductInReceipt(receipt: receipt, productId: productId) ?? false
                    completion(isPurchased)
                case .error:
                    // 如果生产环境失败，尝试沙盒环境
                    self?.checkProductPurchasedSandbox(productId: productId, completion: completion)
                }
            }
        }
    }
    
    /// 检查沙盒环境的购买状态
    private func checkProductPurchasedSandbox(productId: String, completion: @escaping (Bool) -> Void) {
        SwiftyStoreKit.verifyReceipt(using: AppleReceiptValidator(service: .sandbox, sharedSecret: "f283f4bb1bcb4fc7ab4a3ab63f07b6fd")) { result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success(let receipt):
                    let isPurchased = self?.checkProductInReceipt(receipt: receipt, productId: productId) ?? false
                    completion(isPurchased)
                case .error:
                    completion(false)
                }
            }
        }
    }
    
    /// 检查收据中是否包含指定产品
    private func checkProductInReceipt(receipt: ReceiptInfo, productId: String) -> Bool {
        guard let inAppPurchases = receipt["in_app"] as? [[String: Any]] else {
            return false
        }
        
        for purchase in inAppPurchases {
            if let productIdInReceipt = purchase["product_id"] as? String,
               productIdInReceipt == productId {
                // 检查购买状态
                if let transactionState = purchase["transaction_state"] as? Int {
                    // 1 = 购买成功, 2 = 恢复购买
                    return transactionState == 1 || transactionState == 2
                }
            }
        }
        return false
    }
    
    /// 获取所有已购买的产品ID（从苹果服务器）
    func getAllPurchasedProducts(completion: @escaping ([String]) -> Void) {
        print("开始验证生产环境收据...")
        SwiftyStoreKit.verifyReceipt(using: AppleReceiptValidator(service: .production, sharedSecret: "f283f4bb1bcb4fc7ab4a3ab63f07b6fd")) { result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success(let receipt):
                    print("生产环境收据验证成功，收据内容: \(receipt)")
                    let purchasedProducts = self?.extractPurchasedProducts(from: receipt) ?? []
                    print("从生产环境收据中提取的已购买产品: \(purchasedProducts)")
                    completion(purchasedProducts)
                case .error(let error):
                    print("生产环境收据验证失败: \(error)")
                    // 如果生产环境失败，尝试沙盒环境
                    self?.getAllPurchasedProductsSandbox(completion: completion)
                }
            }
        }
    }
    
    /// 从沙盒环境获取已购买产品
     func getAllPurchasedProductsSandbox(completion: @escaping ([String]) -> Void) {
        print("开始验证沙盒收据...")
        // 对于沙盒环境，通常不需要共享密钥，或者使用空字符串
        SwiftyStoreKit.verifyReceipt(using: AppleReceiptValidator(service: .sandbox, sharedSecret: "f283f4bb1bcb4fc7ab4a3ab63f07b6fd")) { result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success(let receipt):
                    print("沙盒收据验证成功，收据内容: \(receipt)")
                    let purchasedProducts = self?.extractPurchasedProducts(from: receipt) ?? []
                    print("从沙盒收据中提取的已购买产品: \(purchasedProducts)")
                    completion(purchasedProducts)
                case .error(let error):
                    print("沙盒收据验证失败: \(error)")
                    completion([])
                }
            }
        }
    }
    
    /// 从收据中提取已购买的产品ID
    private func extractPurchasedProducts(from receipt: ReceiptInfo) -> [String] {
        print("开始解析收据...")
        print("收据的所有键: \(receipt.keys)")
        
        var purchasedProducts: [String] = []
        
        // 首先尝试从 latest_receipt_info 中获取（这是新的收据格式）
        if let latestReceiptInfo = receipt["latest_receipt_info"] as? [[String: Any]] {
            print("找到 \(latestReceiptInfo.count) 个最新收据记录")
            
            // 按产品ID分组，只保留最新的记录
            var latestPurchases: [String: [String: Any]] = [:]
            
            for (index, purchase) in latestReceiptInfo.enumerated() {
                print("最新收据记录 \(index): \(purchase)")
                
                if let productId = purchase["product_id"] as? String,
                   let purchaseDate = purchase["purchase_date_ms"] as? Int64 {
                    print("产品ID: \(productId), 购买时间: \(purchaseDate)")
                    
                    // 只保留每个产品的最新购买记录
                    if let existingPurchase = latestPurchases[productId],
                       let existingDate = existingPurchase["purchase_date_ms"] as? Int64 {
                        if purchaseDate > existingDate {
                            latestPurchases[productId] = purchase
                            print("更新产品 \(productId) 的最新购买记录")
                        }
                    } else {
                        latestPurchases[productId] = purchase
                        print("添加产品 \(productId) 的购买记录")
                    }
                }
            }
            
            // 检查每个产品是否仍然有效（未过期）
            print("最新购买记录数量: \(latestPurchases.count)")
            for (productId, purchase) in latestPurchases {
                print("检查产品 \(productId) 的有效性...")
                
                // 检查是否有过期时间
                if let expiresDate = purchase["expires_date_ms"] as? Int64 {
                    let currentTime = Int64(Date().timeIntervalSince1970 * 1000)
                    print("当前时间: \(currentTime), 过期时间: \(expiresDate)")
                    if currentTime < expiresDate {
                        print("产品 \(productId) 仍然有效，过期时间: \(expiresDate)")
                        if !purchasedProducts.contains(productId) {
                            purchasedProducts.append(productId)
                            print("添加有效产品: \(productId)")
                        }
                    } else {
                        print("产品 \(productId) 已过期，当前时间: \(currentTime), 过期时间: \(expiresDate)")
                    }
                } else {
                    // 如果没有过期时间，说明是永久购买
                    print("产品 \(productId) 是永久购买")
                    if !purchasedProducts.contains(productId) {
                        purchasedProducts.append(productId)
                        print("添加永久产品: \(productId)")
                    }
                }
            }
        }
        
        // 如果 latest_receipt_info 中没有数据，尝试从 in_app 中获取（旧格式）
        if purchasedProducts.isEmpty {
            if let inAppPurchases = receipt["in_app"] as? [[String: Any]] {
                print("找到 \(inAppPurchases.count) 个内购记录")
                
                for (index, purchase) in inAppPurchases.enumerated() {
                    print("内购记录 \(index): \(purchase)")
                    
                    if let productId = purchase["product_id"] as? String,
                       let transactionState = purchase["transaction_state"] as? Int {
                        print("产品ID: \(productId), 交易状态: \(transactionState)")
                        
                        // 1 = 购买成功, 2 = 恢复购买
                        if transactionState == 1 || transactionState == 2 {
                            print("添加已购买产品: \(productId)")
                            purchasedProducts.append(productId)
                        } else {
                            print("交易状态不是已购买: \(transactionState)")
                        }
                    } else {
                        print("无法解析产品ID或交易状态")
                    }
                }
            } else {
                print("收据中没有找到 in_app 数据")
            }
        }
        
        print("最终提取的已购买产品: \(purchasedProducts)")
        return purchasedProducts
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
