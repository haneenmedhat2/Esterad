//
//  DoubleActionPopupView.swift
//  Waraqa
//
//  Created by Haneen on 26/08/2025.
//

import UIKit

class DoubleActionPopupView: BaseViewController {
    
    //MARK: - Outlets -
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var firstBtn: MainButton!
    @IBOutlet weak var secBtn: UIButton!
    @IBOutlet weak var lottieView: LottieView!
    
    //MARK: - Properites -
    
    var delegate : DoubleActionPopupProtocol?
    
    //MARK: - Initializer  -
    
    init() {
        super.init(nibName: "DoubleActionPopupView", bundle: nil)
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
        
        self.secBtn.layer.cornerRadius = 24
        self.secBtn.layer.borderWidth = 1
        self.secBtn.layer.borderColor = UIColor.error.cgColor
        self.secBtn.clipsToBounds = true
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
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut) {
            self.backView.alpha = 0
            self.contentView.alpha = 0
        } completion: { _ in
            self.dismiss(animated: false){
            }
            self.removeFromParent()
        }
    }
    
    //MARK: - Setup Popup -
       
    func setupView(type: DoubleActionPopupType) {
        titleLabel.text = type.title
        self.secBtn.setTitle(type.secBtnTitle, for: .normal)

        lottieView.animationName = type.lottieFileName
        lottieView.isInfinityLoop = false
        lottieView.play()
    }
    
    //MARK: - Action -
    
    @IBAction func didTapFirstBtn(_ sender: UIButton) {
        hide()
    }
    
    
    @IBAction func didTapSecBtn(_ sender: UIButton) {
        delegate?.didTapSecondAction()
        hide()
    }
    
//    @objc func didTapBackView() {
//        hide()
//    }
}

//MARK: - DoubleActionPopupView Protocol -

protocol DoubleActionPopupProtocol : AnyObject {
    func didTapSecondAction()
}
