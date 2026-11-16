//
//  CategoryFilterPopup.swift
//  Esterad
//
//  Created by Haneen on 24/11/2025.
//

import UIKit

class CategoryFilterPopup: BaseViewController {
    
    //MARK: - Outlets -
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var categoryPickerField: PickerFieldView!
    
    //MARK: - Properties -
    
    var delegate : CategoryFilterDelegate?
    var delegateCategories : [DelegateCategory]
    var selectedItem : DelegateCategory? = nil
    
    //MARK: - Initializer  -
    
    init(delegateCategories : [DelegateCategory]) {
        self.delegateCategories = delegateCategories
        super.init(nibName: "CategoryFilterPopup", bundle: nil)
        self.modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shouldSetGradientBackground = false
        configView()
    }
    
    //MARK: - View Configuration -
    
    func configView(){
        self.view.backgroundColor = .clear
        self.backView.backgroundColor  = .black.withAlphaComponent(0.6)
        self.backView.alpha = 0
        self.contentView.alpha = 0
        self.contentView.layer.cornerRadius = 12
        contentView.isUserInteractionEnabled = true
        
        let backTap = UITapGestureRecognizer(target: self, action: #selector(onBackViewTapped))
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(backTap)
        
        categoryPickerField.txtField.text = selectedItem?.name
        categoryPickerField.delegate = self
     
    }
    
    func appear(sender:UIViewController){
        sender.present(self, animated: false){
            self.show()
        }
    }
    
    func show(){
        UIView.animate(withDuration: 1, delay: 0.1){
            self.backView.alpha = 1
            self.contentView.alpha = 1
        }
    }
    
    func hide(){
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut) {
            self.backView.alpha = 0
            self.contentView.alpha = 0
        } completion: { _ in
            self.dismiss(animated: false) {
                
            }
            self.removeFromParent()
        }
    }
    
    //MARK: - Actions -
    
    @objc private func onBackViewTapped() {
        self.hide()
    }
    
    @IBAction func didTapShowRsult(_ sender: UIButton) {
      delegate?.didDismissPopup(model: selectedItem)
      hide()
    }
}

extension CategoryFilterPopup : PickerFieldViewDelegate {
    
    func pickerFieldViewDidTap(_ view: PickerFieldView) {
        let popup = SelectionPicker()
        popup.titleText = "section".localized
        popup.pickerList = delegateCategories
        popup.selectedItem = selectedItem
        
        popup.onItemSelected = { [weak self] item in
            guard let self = self else { return }
            self.selectedItem = item as? DelegateCategory
            self.categoryPickerField.txtField.text = item?.pickerName
        }
        
        popup.appear(sender: self)
    }
}

//MARK: - Delegate Protocol -

protocol CategoryFilterDelegate {
    func didDismissPopup(model:DelegateCategory?)
}
