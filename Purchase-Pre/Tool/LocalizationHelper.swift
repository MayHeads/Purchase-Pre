import Foundation

/// 本地化工具类
class LocalizationHelper {
    
    /// 获取本地化字符串
    /// - Parameter key: 本地化键
    /// - Returns: 本地化字符串
    static func localizedString(for key: String) -> String {
        return NSLocalizedString(key, comment: "")
    }
    
    /// 获取带参数的本地化字符串
    /// - Parameters:
    ///   - key: 本地化键
    ///   - arguments: 参数
    /// - Returns: 本地化字符串
    static func localizedString(for key: String, arguments: CVarArg...) -> String {
        let format = NSLocalizedString(key, comment: "")
        return String(format: format, arguments: arguments)
    }
}

// MARK: - 常用本地化字符串扩展
extension LocalizationHelper {
    
    // MARK: - 主界面
    static var inAppPurchaseTitle: String {
        return localizedString(for: "in_app_purchase_title")
    }
    
    static var purchaseButton: String {
        return localizedString(for: "purchase_button")
    }
    
    static var restoreButton: String {
        return localizedString(for: "restore_button")
    }
    
    static var checkPurchasedButton: String {
        return localizedString(for: "check_purchased_button")
    }
    
    // MARK: - 商品信息
    static var productTitle: String {
        return localizedString(for: "product_title")
    }
    
    static var productDescription: String {
        return localizedString(for: "product_description")
    }
    
    static var productPrice: String {
        return localizedString(for: "product_price")
    }
    
    static var productPurchased: String {
        return localizedString(for: "product_purchased")
    }
    
    // MARK: - 购买状态
    static var purchaseSuccess: String {
        return localizedString(for: "purchase_success")
    }
    
    static var purchaseFailed: String {
        return localizedString(for: "purchase_failed")
    }
    
    static var purchaseCancelled: String {
        return localizedString(for: "purchase_cancelled")
    }
    
    static var restoreSuccess: String {
        return localizedString(for: "restore_success")
    }
    
    static var restoreFailed: String {
        return localizedString(for: "restore_failed")
    }
    
    static var nothingToRestore: String {
        return localizedString(for: "nothing_to_restore")
    }
    
    // MARK: - 查询结果
    static var purchasedProductsTitle: String {
        return localizedString(for: "purchased_products_title")
    }
    
    static var noPurchasedProducts: String {
        return localizedString(for: "no_purchased_products")
    }
    
    static func purchasedProductsList(_ products: String) -> String {
        return localizedString(for: "purchased_products_list", arguments: products)
    }
    
    static var productPurchaseStatus: String {
        return localizedString(for: "product_purchase_status")
    }
    
    static func productPurchasedStatus(_ productId: String) -> String {
        return localizedString(for: "product_purchased_status", arguments: productId)
    }
    
    static func productNotPurchasedStatus(_ productId: String) -> String {
        return localizedString(for: "product_not_purchased_status", arguments: productId)
    }
    
    // MARK: - 错误信息
    static var errorTitle: String {
        return localizedString(for: "error_title")
    }
    
    static var errorUnknown: String {
        return localizedString(for: "error_unknown")
    }
    
    static var errorPaymentCancelled: String {
        return localizedString(for: "error_payment_cancelled")
    }
    
    static var errorPaymentInvalid: String {
        return localizedString(for: "error_payment_invalid")
    }
    
    static var errorPaymentNotAllowed: String {
        return localizedString(for: "error_payment_not_allowed")
    }
    
    static var errorStoreProductNotAvailable: String {
        return localizedString(for: "error_store_product_not_available")
    }
    
    static var errorNetworkConnectionFailed: String {
        return localizedString(for: "error_network_connection_failed")
    }
    
    static func errorFetchProductsFailed(_ error: String) -> String {
        return localizedString(for: "error_fetch_products_failed", arguments: error)
    }
    
    static var errorNoProductsFound: String {
        return localizedString(for: "error_no_products_found")
    }
    
    // MARK: - 加载状态
    static var loading: String {
        return localizedString(for: "loading")
    }
    
    static var loadingProducts: String {
        return localizedString(for: "loading_products")
    }
    
    static var verifyingReceipt: String {
        return localizedString(for: "verifying_receipt")
    }
}
