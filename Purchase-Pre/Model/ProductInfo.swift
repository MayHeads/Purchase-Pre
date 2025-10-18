//
//  ProductInfo.swift
//  Purchase-Pre
//
//  Created by mayheaders on 2025/10/18.
//

import Foundation

/// 商品信息模型
struct ProductInfo {
    let productId: String
    let title: String
    let description: String
    let price: String
    let isPurchased: Bool
    
    init(productId: String, title: String, description: String, price: String, isPurchased: Bool = false) {
        self.productId = productId
        self.title = title
        self.description = description
        self.price = price
        self.isPurchased = isPurchased
    }
}

/// 购买结果枚举
enum PurchaseResult {
    case success(ProductInfo)
    case failure(String)
    case cancelled
    case deferred
}

/// 恢复购买结果枚举
enum RestoreResult {
    case success([ProductInfo])
    case failure(String)
    case nothingToRestore
}
