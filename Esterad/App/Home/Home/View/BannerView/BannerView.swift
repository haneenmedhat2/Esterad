//
//  OfferViewController.swift
//  Cleaf
//
//  Created by Haneen on 01/06/2025.
//

import UIKit
import Kingfisher


class BannerSliderView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private var sliderList : [Ad] = []
    private var collectionView: UICollectionView!
    private var pageStackView: UIStackView!
    private var collectionHeightConstraint: NSLayoutConstraint!

    
    private var autoScrollTimer: Timer?
    private var currentIndex = 0
    var didSelectAddress: ((Ad) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCollectionView()
        setupPageIndicator()
        startAutoScrollTimer()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCollectionView()
        setupPageIndicator()
        startAutoScrollTimer()
    }
    
    deinit {
        autoScrollTimer?.invalidate()
    }
    
    func setSliderList(list: [Ad]) {
        sliderList = list
        collectionView.reloadData()
        layoutIfNeeded()
        updateCollectionHeight()
        setupPageIndicator()
    }

    private func updateCollectionHeight() {
        let width = collectionView.bounds.width
        guard width > 0 else { return }

        let height = width / 2
        collectionHeightConstraint.constant = height
        layoutIfNeeded()
    }

    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.sectionInset = .zero

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isPagingEnabled = true
        collectionView.decelerationRate = .normal
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(cellType: AdsCell.self)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.semanticContentAttribute = .forceLeftToRight
        collectionHeightConstraint = collectionView.heightAnchor.constraint(equalToConstant: 145)
        collectionHeightConstraint.isActive = true

        addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: self.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
           // collectionView.heightAnchor.constraint(equalToConstant: 150)
        ])
    }

    
    private func setupPageIndicator() {
        pageStackView?.removeFromSuperview()
        pageStackView = nil
        
        
        pageStackView = UIStackView()
        pageStackView.axis = .horizontal
        pageStackView.spacing = 4
        pageStackView.alignment = .center
        pageStackView.distribution = .equalCentering
        pageStackView.translatesAutoresizingMaskIntoConstraints = false
        pageStackView.semanticContentAttribute = .forceLeftToRight
        
        for i in 0..<sliderList.count {
            let dot = UIView()
            dot.layer.cornerRadius = 4
            dot.backgroundColor = i == 0 ? .main : .alphaMain
            dot.translatesAutoresizingMaskIntoConstraints = false
            dot.widthAnchor.constraint(equalToConstant: i == 0 ? 16 : 8).isActive = true
            dot.heightAnchor.constraint(equalToConstant: 8).isActive = true
            pageStackView.addArrangedSubview(dot)
        }
        
        addSubview(pageStackView)
        NSLayoutConstraint.activate([
            pageStackView.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 12),
            pageStackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            pageStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    private func updatePageIndicator(to index: Int) {
        for (i, dot) in pageStackView.arrangedSubviews.enumerated() {
            if let view = dot as? UIView {
                view.backgroundColor = i == index ? .main : UIColor.alphaMain
                view.constraints.forEach { constraint in
                    if constraint.firstAttribute == .width {
                        constraint.constant = i == index ? 16: 8
                    }
                }
                view.layer.cornerRadius = 4
                view.layoutIfNeeded()
            }
        }
    }
    
    private func startAutoScrollTimer() {
        autoScrollTimer = Timer.scheduledTimer(timeInterval: 7.0, target: self, selector: #selector(autoScroll), userInfo: nil, repeats: true)
    }
    
    @objc private func autoScroll() {
        guard sliderList.count > 0 else { return }
        currentIndex = (currentIndex + 1) % sliderList.count
        let indexPath = IndexPath(item: currentIndex, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
        updatePageIndicator(to: currentIndex)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateCurrentIndex()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        updateCurrentIndex()
    }
    
    private func updateCurrentIndex() {
        let pageWidth = collectionView.bounds.width
        guard pageWidth > 0 else { return }

        let index = Int(round(collectionView.contentOffset.x / pageWidth))
        currentIndex = max(0, min(index, sliderList.count - 1))
        updatePageIndicator(to: currentIndex)
    }

    
    // MARK: - Collection View
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sliderList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(with: AdsCell.self, for: indexPath)
        let item = sliderList[indexPath.item]
        cell.setupCell(model: item)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = sliderList[indexPath.item]
        didSelectAddress?(item)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(
            width: collectionView.frame.width,
            height: collectionView.frame.height
        )
    }
}
