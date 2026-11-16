//
//  CancelOrderPopup.swift
//  Esterad
//
//  Created by Haneen on 02/12/2025.
//

import UIKit

class CancelOrderPopup: BaseViewController {
    
    //MARK: - Outlets -
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var cancelReasonTextView: DropDownTextView!
    @IBOutlet weak var noteLabe: UILabel!
    
    //MARK: - Properties -
    
    var delegate : CancelOrderProtocol?
    let orderType : OrderType
    
    //MARK: - Initializer  -
    
    init(orderType : OrderType){
        self.orderType = orderType
        super.init(nibName: "CancelOrderPopup", bundle: nil)
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
         
//        switch orderType {
//        case .normal:
//            noteLabe.isHidden = false
//        case .special:
//            noteLabe.isHidden = true
//        }
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
            self.dismiss(animated: false){
                
            }
            
            self.removeFromParent()
        }
    }
    
    //MARK: - Actions -
 
    @objc func onBackViewTapped(){
        hide()
    }
    
    @IBAction func didTapBack(_ sender: UIButton) {
        hide()
    }
    
    @IBAction func didTapConfirmCancellation(_ sender: UIButton) {
        guard let reason = validateCancellationReason() else { return }
        delegate?.didTapCancelOrder(reason: reason)
        hide()
    }
}

//MARK: - Validation -
extension CancelOrderPopup {
    
    func validateCancellationReason() -> String? {
        guard let reason = cancelReasonTextView.textView.text , !reason.trimWhiteSpace().isEmpty else {
            show(errorMessage: ValidationError.emptyReason.localizedDescription)
            return nil
        }
        return reason
    }
}

//MARK: - Delegate Protocol -

protocol CancelOrderProtocol {
    func didTapCancelOrder(reason : String)
}
