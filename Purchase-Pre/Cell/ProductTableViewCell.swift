//
//  ProductTableViewCell.swift
//  Purchase-Pre
//
//  Created by mayheaders on 2025/10/18.
//

import UIKit
import SnapKit

class ProductTableViewCell: UITableViewCell {
    
    // MARK: - UI Elements
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .label
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 3
        return label
    }()
    
    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .systemBlue
        label.textAlignment = .right
        return label
    }()
    
    private lazy var purchaseButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemBlue.cgColor
        button.addTarget(self, action: #selector(purchaseButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        label.layer.cornerRadius = 6
        label.layer.masksToBounds = true
        return label
    }()
    
    // MARK: - Properties
    
    var onPurchaseTapped: (() -> Void)?
    private var product: ProductInfo?
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .systemBackground
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(purchaseButton)
        contentView.addSubview(statusLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(priceLabel.snp.leading).offset(-8)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(priceLabel.snp.leading).offset(-8)
        }
        
        priceLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-16)
            make.width.equalTo(80)
        }
        
        purchaseButton.snp.makeConstraints { make in
            make.top.equalTo(priceLabel.snp.bottom).offset(8)
            make.trailing.equalToSuperview().offset(-16)
            make.width.equalTo(80)
            make.height.equalTo(32)
        }
        
        statusLabel.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(16)
            make.width.equalTo(100)
            make.height.equalTo(24)
            make.bottom.equalToSuperview().offset(-12)
        }
    }
    
    // MARK: - Configuration
    
    func configure(with product: ProductInfo) {
        self.product = product
        
        titleLabel.text = product.title
        descriptionLabel.text = product.description
        priceLabel.text = product.price
        
        if product.isPurchased {
            purchaseButton.setTitle("已购买", for: .normal)
            purchaseButton.setTitleColor(.systemGreen, for: .normal)
            purchaseButton.backgroundColor = .systemGreen.withAlphaComponent(0.1)
            purchaseButton.layer.borderColor = UIColor.systemGreen.cgColor
            purchaseButton.isEnabled = false
            
            statusLabel.text = "已购买"
            statusLabel.textColor = .white
            statusLabel.backgroundColor = .systemGreen
        } else {
            purchaseButton.setTitle("购买", for: .normal)
            purchaseButton.setTitleColor(.systemBlue, for: .normal)
            purchaseButton.backgroundColor = .clear
            purchaseButton.layer.borderColor = UIColor.systemBlue.cgColor
            purchaseButton.isEnabled = true
            
            statusLabel.text = "未购买"
            statusLabel.textColor = .white
            statusLabel.backgroundColor = .systemGray
        }
    }
    
    // MARK: - Actions
    
    @objc private func purchaseButtonTapped() {
        guard let product = product, !product.isPurchased else { return }
        onPurchaseTapped?()
    }
}
