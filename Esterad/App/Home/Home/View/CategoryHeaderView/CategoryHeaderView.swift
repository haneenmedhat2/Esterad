//
//  CategoryHeaderView.swift
//  Esterad
//
//  Created by Haneen on 13/11/2025.
//

import Foundation
import UIKit

final class CategoryHeaderView: UICollectionReusableView {
    
    // MARK: - Properties -
    
    static let headerIdentifier = "CategoryHeaderView"
    static let elementKind = UICollectionView.elementKindSectionHeader
    
    var headerType: HeaderTypes = .product
    weak var delegate: CategoryHeaderViewDelegate?
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .categories)
        imageView.tintColor = .main
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "categories".localized
        label.font = .myMediumFont(ofSize: 16)
        label.textColor = .label
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var showAllButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("view_all".localized, for: .normal)
        button.setTitleColor(.main, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.addTarget(self, action: #selector(didTapShowAll), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let titleStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Initializers -
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Setup -
    
    private func setupUI() {
        backgroundColor = .clear
        
        titleStack.addArrangedSubview(iconImageView)
        titleStack.addArrangedSubview(titleLabel)
        
        addSubview(titleStack)
        addSubview(showAllButton)
        
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            titleStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            titleStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleStack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 8),

            
            showAllButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            showAllButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            showAllButton.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            showAllButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 8)
        ])
    }
    
    // MARK: - Actions -
    
    @objc private func didTapShowAll() {
        delegate?.didTapShowAll(headerType: headerType)
    }
}

extension CategoryHeaderView {
    func configure(
        title: String,
        isIconHidden: Bool = false,
        showAllButtonHidden: Bool = false,
        headerType: HeaderTypes? = .product
    ) {
        titleLabel.text = title
        iconImageView.isHidden = isIconHidden
        showAllButton.isHidden = showAllButtonHidden
        self.headerType = headerType ?? .product
        
    }
}

// MARK: - Header View Delegation -

protocol CategoryHeaderViewDelegate: AnyObject {
    func didTapShowAll(headerType : HeaderTypes? )
}
