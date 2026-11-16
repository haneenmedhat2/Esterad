//
//  SuccessPopup.swift
//  Cleaf
//
//  Created by Haneen on 14/05/2025.
//

import UIKit

class SuccessPopup: BaseViewController {

    //MARK: - Outlets -
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var successTitle: UILabel!
    @IBOutlet weak var popupImage: UIImageView!
    
    //MARK: - Properties -
    
    var popupTitle : String
    var onPopupHidden: (() -> Void)?


    //MARK: - Initializer  -
    
    init(successTitle: String = "Message sent successfully".localized) {
        popupTitle = successTitle
        super.init(nibName: "SuccessPopup", bundle: nil)
        self.modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
        successTitle.text = popupTitle
    }

    
    //MARK: - View Configuration -
    
    func configView(){
        self.view.backgroundColor = .clear
        self.backView.backgroundColor  = .black.withAlphaComponent(0.6)
        self.backView.alpha = 0
        self.contentView.alpha = 0
        self.contentView.layer.cornerRadius = 12
        contentView.isUserInteractionEnabled = true
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
        } completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                self.hide()
            }
        }
    }
    
    func hide(){
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut) {
            self.backView.alpha = 0
            self.contentView.alpha = 0
        } completion: { _ in
            self.dismiss(animated: false){
                self.onPopupHidden?()

            }
            self.removeFromParent()
        }
    }
}
