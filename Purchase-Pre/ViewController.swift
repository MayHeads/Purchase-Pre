//
//  ViewController.swift
//  Purchase-Pre
//
//  Created by mayheaders on 2025/10/18.
//

import UIKit
import SnapKit
import Combine

class ViewController: UIViewController {
    
    // MARK: - UI Elements
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = LocalizationHelper.inAppPurchaseTitle
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.textColor = .label
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ProductTableViewCell.self, forCellReuseIdentifier: "ProductCell")
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = .systemBackground
        return tableView
    }()
    
    private lazy var restoreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(LocalizationHelper.restoreButton, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitleColor(.systemBlue, for: .normal)
        button.backgroundColor = .systemGray6
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(restoreButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private lazy var checkPurchasedButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(LocalizationHelper.checkPurchasedButton, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitleColor(.systemBlue, for: .normal)
        button.backgroundColor = .systemGray6
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(checkPurchasedButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Properties
    
    private let purchaseService = PurchaseService.shared
    private var cancellables = Set<AnyCancellable>()
    
    // 商品ID列表 - 请替换为你在App Store Connect中配置的实际商品ID
    private let productIds = ["jwd.week", "jwd.year"] // 请替换为你的实际商品ID
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        loadProducts()
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(restoreButton)
        view.addSubview(checkPurchasedButton)
        view.addSubview(loadingIndicator)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(30)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(checkPurchasedButton.snp.top).offset(-20)
        }
        
        restoreButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(checkPurchasedButton.snp.top).offset(-10)
            make.height.equalTo(50)
        }
        
        checkPurchasedButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            make.height.equalTo(50)
        }
        
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func setupBindings() {
        // 监听加载状态
        purchaseService.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.loadingIndicator.startAnimating()
                } else {
                    self?.loadingIndicator.stopAnimating()
                }
            }
            .store(in: &cancellables)
        
        // 监听商品列表变化
        purchaseService.$products
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        // 监听错误信息
        purchaseService.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                if let errorMessage = errorMessage {
                    self?.showAlert(title: LocalizationHelper.errorTitle, message: errorMessage)
                }
            }
            .store(in: &cancellables)
        
//        self.getAllPurchasedProducts()
        
        purchaseService.getAllPurchasedProductsSandbox { x in
            debugPrint("Sandbox 已购买的产品: \(x)")
        }
    }
    
    // MARK: - Actions
    
    private func loadProducts() {
        purchaseService.fetchProducts(productIds: productIds)
    }
    
    @objc private func restoreButtonTapped() {
        purchaseService.restorePurchases { [weak self] result in
            switch result {
            case .success(let products):
                let message = LocalizationHelper.localizedString(for: "restore_success_count", arguments: products.count)
                self?.showAlert(title: LocalizationHelper.restoreSuccess, message: message)
            case .failure(let error):
                self?.showAlert(title: LocalizationHelper.restoreFailed, message: error)
            case .nothingToRestore:
                self?.showAlert(title: LocalizationHelper.nothingToRestore, message: LocalizationHelper.nothingToRestore)
            }
        }
    }
    
    private func purchaseProduct(_ product: ProductInfo) {
        purchaseService.purchaseProduct(productId: product.productId) { [weak self] result in
            switch result {
            case .success(let productInfo):
                let message = LocalizationHelper.localizedString(for: "purchase_success_product", arguments: productInfo.title)
                self?.showAlert(title: LocalizationHelper.purchaseSuccess, message: message)
                self?.tableView.reloadData()
            case .failure(let error):
                self?.showAlert(title: LocalizationHelper.purchaseFailed, message: error)
            case .cancelled:
                self?.showAlert(title: LocalizationHelper.purchaseCancelled, message: LocalizationHelper.purchaseCancelled)
            case .deferred:
                let message = LocalizationHelper.localizedString(for: "purchase_deferred")
                self?.showAlert(title: LocalizationHelper.localizedString(for: "info_title"), message: message)
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: LocalizationHelper.localizedString(for: "ok_button"), style: .default))
        present(alert, animated: true)
    }
    
    @objc private func checkPurchasedButtonTapped() {
        purchaseService.getAllPurchasedProductsSandbox { [weak self] purchasedProducts in
            let message = purchasedProducts.isEmpty ? LocalizationHelper.noPurchasedProducts : LocalizationHelper.purchasedProductsList(purchasedProducts.joined(separator: ", "))
            self?.showAlert(title: LocalizationHelper.purchasedProductsTitle, message: message)
        }
    }
    
    /// 检查特定产品是否已购买
    private func checkSpecificProduct(productId: String) {
        purchaseService.checkProductPurchased(productId: productId) { [weak self] isPurchased in
            let message = isPurchased ? LocalizationHelper.productPurchasedStatus(productId) : LocalizationHelper.productNotPurchasedStatus(productId)
            self?.showAlert(title: LocalizationHelper.productPurchaseStatus, message: message)
        }
    }
    
    /// 获取所有已购买的产品
//    private func getAllPurchasedProducts() {
//        purchaseService.getAllPurchasedProductsSandbox { [weak self] purchasedProducts in
//            let message = purchasedProducts.isEmpty ? "没有已购买的产品" : "已购买的产品: \(purchasedProducts.joined(separator: ", "))"
//            self?.showAlert(title: "购买状态", message: message)
//        }
//    }
}

// MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return purchaseService.products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as! ProductTableViewCell
        let product = purchaseService.products[indexPath.row]
        cell.configure(with: product)
        cell.onPurchaseTapped = { [weak self] in
            self?.purchaseProduct(product)
        }
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}

