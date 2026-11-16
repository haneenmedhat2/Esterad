//
//  CreateComplaintPopup.swift
//  Esterad
//
//  Created by Haneen on 06/11/2025.
//

import UIKit

class CreateComplaintPopup: BaseViewController {

    //MARK: - Outlets -
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var complaintTitleTextField: GeneralTextField!
    @IBOutlet weak var complaintReasonTextField: DropDownTextView!

    //MARK: - Properties -
    
    var delegate : CreateComplaintProtocol?

    //MARK: - Initializer  -
    
    init() {
        super.init(nibName: "CreateComplaintPopup", bundle: nil)
        self.modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
        shouldSetGradientBackground = false
    }
    
    //MARK: - View Configuration -
    
    func configView(){
        self.view.backgroundColor = .clear
        self.backView.backgroundColor  = .black.withAlphaComponent(0.6)
        self.backView.alpha = 0
        self.contentView.alpha = 0
        self.contentView.layer.cornerRadius = 12
        contentView.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backViewTapped))
           backView.isUserInteractionEnabled = true
           backView.addGestureRecognizer(tapGesture)
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
    
    func hide(completion: (() -> Void)? = nil) {
        self.dismiss(animated: false) {
            completion?()
        }
    }
    
    //MARK: - Actions -
        
    @IBAction func didTapSend(_ sender: UIButton) {
        guard let title = validateComplaintTitle() else { return }
        guard let reason = validateComplaintReason() else { return }
        
        delegate?.didTapOnSendButton(title: title, reason: reason)
        hide()
    }
    
    @objc private func backViewTapped() {
        hide()
    }
}

//MARK: - Validation -
extension CreateComplaintPopup {
    
    func validateComplaintTitle() -> String? {
        guard let title = complaintTitleTextField.txtField.text , !title.trimWhiteSpace().isEmpty else {
            show(errorMessage: ValidationError.emptyComplaintTitle.localizedDescription)
            return nil
        }
        return title
    }
    
    func validateComplaintReason() -> String? {
        guard let reason = complaintReasonTextField.textView.text , !reason.trimWhiteSpace().isEmpty else {
            show(errorMessage: ValidationError.emptyComplaintReason.localizedDescription)
            return nil
        }
        return reason
    }
}

//MARK: - WalletPopup Delegate Protocol -

protocol CreateComplaintProtocol: AnyObject {
    func didTapOnSendButton(title: String, reason : String)
}
