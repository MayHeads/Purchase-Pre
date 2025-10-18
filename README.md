# Purchase-Pre iOS 内购应用

这是一个使用 SwiftyStoreKit 实现的 iOS 内购功能示例应用。

## 功能特性

- ✅ 商品信息展示
- ✅ 内购功能实现
- ✅ 恢复购买功能
- ✅ 本地购买状态存储
- ✅ MVVM 架构模式
- ✅ Combine 响应式编程
- ✅ SnapKit 自动布局

## 项目结构

```
Purchase-Pre/
├── Model/
│   └── ProductInfo.swift          # 商品信息模型
├── Service/
│   └── PurchaseService.swift      # 内购服务管理类
├── Cell/
│   └── ProductTableViewCell.swift # 商品展示Cell
├── ViewController.swift            # 主视图控制器
└── README.md                      # 项目说明文档
```

## 使用说明

### 1. 配置商品ID

在 `ViewController.swift` 中，将 `productIds` 数组中的商品ID替换为你在 App Store Connect 中配置的实际商品ID：

```swift
private let productIds = ["com.yourcompany.purchasepre.premium"] // 请替换为你的实际商品ID
```

### 2. 主要功能

#### 商品展示
- 自动从 App Store 获取商品信息
- 显示商品标题、描述和价格
- 显示购买状态

#### 购买功能
- 点击购买按钮进行内购
- 支持原子性购买（立即交付内容）
- 自动保存购买状态到本地

#### 恢复购买
- 点击"恢复购买"按钮
- 恢复之前购买的商品
- 支持跨设备同步

### 3. 本地存储

购买状态使用 `UserDefaults` 进行本地存储：
- 键名：`PurchasedProducts`
- 存储格式：`[String]` 数组
- 自动同步到 iCloud（如果启用）

## 技术实现

### 架构模式
- **MVVM**: 视图与业务逻辑分离
- **Combine**: 响应式编程，数据绑定
- **单例模式**: PurchaseService 使用单例模式

### 依赖库
- **SwiftyStoreKit**: 内购功能实现
- **SnapKit**: 自动布局
- **Combine**: 响应式编程

### 关键类说明

#### PurchaseService
- 管理内购相关功能
- 处理商品信息获取
- 处理购买和恢复购买
- 管理本地存储

#### ProductInfo
- 商品信息模型
- 包含商品ID、标题、描述、价格等
- 购买状态标识

#### ProductTableViewCell
- 商品展示单元格
- 显示商品信息和购买按钮
- 根据购买状态更新UI

## 注意事项

1. **商品ID配置**: 确保在 App Store Connect 中正确配置商品
2. **沙盒测试**: 使用沙盒账户进行测试
3. **网络连接**: 内购需要网络连接
4. **设备限制**: 某些功能需要真实设备测试

## 测试步骤

1. 在 App Store Connect 中创建内购商品
2. 配置商品ID到代码中
3. 使用沙盒账户登录设备
4. 运行应用进行测试
5. 测试购买和恢复购买功能

## 错误处理

应用包含完整的错误处理机制：
- 网络错误
- 支付取消
- 商品不可用
- 设备限制等

所有错误都会通过弹窗提示用户。

## 扩展功能

可以基于此项目扩展以下功能：
- 订阅商品支持
- 服务器验证
- 更多商品类型
- 购买历史记录
- 用户界面优化

## 联系支持

如有问题，请检查：
1. 商品ID是否正确
2. 网络连接是否正常
3. 沙盒账户是否有效
4. 设备是否支持内购功能
