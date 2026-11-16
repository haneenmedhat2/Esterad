//
//  CompanyDetailsCollectionCell.swift
//  Esterad
//
//  Created by Haneen on 20/12/2025.
//

import Foundation
import UIKit
import Kingfisher

class CompanyDetailsCollectionCell: UICollectionViewCell {

    //MARK: - Outlets -

    @IBOutlet weak var companyImage: UIImageView!
    @IBOutlet weak var companyName: UILabel!
    @IBOutlet weak var companyLocation: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var companyDescTextview: UITextView!
    @IBOutlet weak var filterSearchStackView: UIStackView!
    
    //MARK: - Properties -

    var delegate : CompanyDetailsProtocol?
    var categoryList : [DelegateCategory] = []
    
    //MARK: - Initializer -
    
    override func awakeFromNib() {
           super.awakeFromNib()
           configureCollectionView()
           viewSetup()
       }
    
    func viewSetup(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(didSelectFilter))
        filterSearchStackView.addGestureRecognizer(tap)
    }
    
    func configure(with model: Delegate) {
        companyImage.kf.setImage(with: URL(string: model.logo ?? ""),placeholder: UIImage(resource: .companyDetails ),
                                 options: [.onFailureImage(UIImage(resource: .companyDetails ))])
        companyName.text = model.name
        companyLocation.text = model.address
        companyDescTextview.text = model.desc
        categoryList = model.categories ?? []
        collectionView.reloadData()
    }
    
    //MARK: - Action -
    
    @objc func didSelectFilter(){
        delegate?.didSelectFilter()
    }
}

//MARK: - CollectionView Configuration -

extension CompanyDetailsCollectionCell : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(cellType: SectionCell.self)
        collectionView.register(CategoryHeaderView.self,
                                forSupplementaryViewOfKind: CategoryHeaderView.elementKind,
                                withReuseIdentifier: CategoryHeaderView.headerIdentifier)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryList.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(with: SectionCell.self, for: indexPath)
        let item = categoryList[indexPath.row]
        cell.sectionLabel.text = item.name
        return cell
    }
        
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
 
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: CategoryHeaderView.headerIdentifier,
            for: indexPath
        ) as! CategoryHeaderView
        
        header.configure(
            title: "related_categories".localized,
            isIconHidden: true,
            showAllButtonHidden: true
        )
        return header
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: 110, height: 40)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 40)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
    }
}

//MARK: - Delegate Protocol -

protocol CompanyDetailsProtocol : AnyObject {
    func didSelectFilter()
}
