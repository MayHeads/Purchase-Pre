# Purchase-Pre iOS 内购应用

这是一个使用 Swift 和 SwiftyStoreKit 实现的 iOS 内购应用，支持简体中文和英文两种语言。

## 功能特性

- ✅ 内购商品展示和购买
- ✅ 恢复购买功能
- ✅ 购买状态查询
- ✅ 收据验证（从苹果服务器验证购买状态）
- ✅ 国际化支持（简体中文/英文）
- ✅ MVVM 架构模式
- ✅ Combine 响应式编程
- ✅ SnapKit 自动布局

## 项目结构

```
Purchase-Pre/
├── Model/
│   └── ProductInfo.swift          # 商品信息模型
├── Service/
│   └── PurchaseService.swift      # 内购服务管理
├── View/
│   └── ViewController.swift       # 主视图控制器
├── Cell/
│   └── ProductTableViewCell.swift # 商品展示单元格
├── Tool/
│   └── LocalizationHelper.swift   # 本地化工具类
├── zh-Hans.lproj/
│   └── Localizable.strings        # 简体中文本地化文件
└── en.lproj/
    └── Localizable.strings        # 英文本地化文件
```

## 国际化支持

### 支持的语言

- 🇨🇳 简体中文 (zh-Hans)
- 🇺🇸 英文 (en)

### 如何添加新语言

1. 在项目根目录创建新的语言文件夹，例如：
   ```
   fr.lproj/          # 法语
   de.lproj/          # 德语
   ja.lproj/         # 日语
   ```

2. 复制 `en.lproj/Localizable.strings` 到新文件夹

3. 翻译所有字符串值

4. 在 Xcode 项目设置中添加新语言支持

### 本地化字符串使用

```swift
// 使用 LocalizationHelper 获取本地化字符串
let title = LocalizationHelper.inAppPurchaseTitle
let buttonText = LocalizationHelper.purchaseButton

// 带参数的本地化字符串
let message = LocalizationHelper.localizedString(for: "purchase_success_product", arguments: productName)
```

### 本地化字符串列表

#### 主界面
- `in_app_purchase_title`: "内购商品" / "In-App Purchase"
- `purchase_button`: "购买" / "Purchase"
- `restore_button`: "恢复购买" / "Restore Purchases"
- `check_purchased_button`: "查询已购买产品" / "Check Purchased Products"

#### 商品信息
- `product_title`: "商品标题" / "Product Title"
- `product_description`: "商品描述" / "Product Description"
- `product_price`: "价格" / "Price"
- `product_purchased`: "已购买" / "Purchased"

#### 购买状态
- `purchase_success`: "购买成功" / "Purchase Successful"
- `purchase_failed`: "购买失败" / "Purchase Failed"
- `purchase_cancelled`: "购买已取消" / "Purchase Cancelled"
- `restore_success`: "恢复购买成功" / "Restore Successful"
- `restore_failed`: "恢复购买失败" / "Restore Failed"
- `nothing_to_restore`: "没有可恢复的购买" / "Nothing to Restore"

#### 查询结果
- `purchased_products_title`: "已购买产品" / "Purchased Products"
- `no_purchased_products`: "没有已购买的产品" / "No purchased products"
- `purchased_products_list`: "已购买的产品: %@" / "Purchased products: %@"
- `product_purchase_status`: "产品购买状态" / "Product Purchase Status"
- `product_purchased_status`: "已购买 %@" / "Purchased %@"
- `product_not_purchased_status`: "未购买 %@" / "Not purchased %@"

#### 错误信息
- `error_title`: "错误" / "Error"
- `error_unknown`: "未知错误，请联系客服" / "Unknown error, please contact support"
- `error_payment_cancelled`: "用户取消支付" / "Payment cancelled by user"
- `error_payment_invalid`: "购买标识符无效" / "Invalid purchase identifier"
- `error_payment_not_allowed`: "设备不允许进行支付" / "Payment not allowed on this device"
- `error_store_product_not_available`: "商品在当前商店不可用" / "Product not available in current store"
- `error_network_connection_failed`: "无法连接到网络" / "Unable to connect to network"
- `error_fetch_products_failed`: "获取商品信息失败: %@" / "Failed to fetch product information: %@"
- `error_no_products_found`: "没有找到任何商品，请检查App Store Connect中的产品配置" / "No products found, please check your App Store Connect configuration"

#### 加载状态
- `loading`: "加载中..." / "Loading..."
- `loading_products`: "正在加载商品..." / "Loading products..."
- `verifying_receipt`: "正在验证收据..." / "Verifying receipt..."

#### 按钮和操作
- `ok_button`: "确定" / "OK"
- `info_title`: "提示" / "Information"

#### 购买相关
- `restore_success_count`: "成功恢复 %d 个商品" / "Successfully restored %d products"
- `purchase_success_product`: "成功购买: %@" / "Successfully purchased: %@"
- `purchase_deferred`: "购买等待批准" / "Purchase waiting for approval"
- `not_purchased`: "未购买" / "Not purchased"

## 技术实现

### 架构模式
- **MVVM**: Model-View-ViewModel 架构
- **Combine**: 响应式编程框架
- **SnapKit**: 自动布局库

### 核心功能
- **SwiftyStoreKit**: 内购功能实现
- **收据验证**: 从苹果服务器验证购买状态
- **本地存储**: UserDefaults 存储购买状态
- **国际化**: 多语言支持

### 依赖库
```ruby
pod 'SwiftyStoreKit'
pod 'SnapKit'
pod 'SwiftyBeaver'
```

## 使用方法

1. 在 App Store Connect 中配置内购商品
2. 更新 `ViewController.swift` 中的 `productIds` 数组
3. 运行应用进行测试

## 注意事项

- 确保在 App Store Connect 中正确配置内购商品
- 测试时使用沙盒环境
- 生产环境需要正确的共享密钥
- 支持 iOS 14.0 及以上版本

## 开发环境

- Xcode 16.0+
- iOS 14.0+
- Swift 5.0+
- CocoaPods

## 许可证

本项目仅供学习和参考使用。