//
//  SearchTabView.swift
//  Waraqa
//
//  Created by Haneen on 13/09/2025.
//

import UIKit

class HomeModeTypesView: UIView {
    
    //MARK: - Outlets -
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: - Properite -
    
    var selectedIndex : IndexPath = IndexPath(item: 0, section: 0)
    var homeTypes: [HomeModeTypes] = HomeModeTypes.allCases
    var delegate : HomeModeTypesDelegate?
    var category : Category?
    
    //MARK: - Initializer -
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        setupCollectionView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
        setupCollectionView()
    }
    
    //MARK: - Nib File Configuration -
    
    func loadViewFromNib(nibName:String) -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as! UIView
    }
    
    func configureView(){
        let view = loadViewFromNib(nibName: "HomeModeTypesView")
        view.frame = self.bounds
        self.addSubview(view)
    }
}

//MARK: - Collection View Setup -

extension HomeModeTypesView:
    UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(cellType: HomeModeTypesCell.self, bundle: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return homeTypes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(with: HomeModeTypesCell.self, for: indexPath)
        let isCellSelected = indexPath == selectedIndex
        guard let category = category else { return  cell}
        cell.setupCell(type : homeTypes[indexPath.item], category : category )
        cell.updateCellSelection(isCellSelected: isCellSelected)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath
        delegate?.didSelectItem(at: homeTypes[indexPath.item])
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
           let spacing: CGFloat = 8
           let itemsCount = CGFloat(homeTypes.count)
           let totalSpacing = spacing * (itemsCount - 1)
           let availableWidth = collectionView.frame.width - totalSpacing
           let itemWidth = availableWidth / itemsCount
           
           return CGSize(width: itemWidth, height: 70)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
}

//MARK: - Selection Protocol -

protocol HomeModeTypesDelegate: AnyObject {
    func didSelectItem(at type: HomeModeTypes)
}

