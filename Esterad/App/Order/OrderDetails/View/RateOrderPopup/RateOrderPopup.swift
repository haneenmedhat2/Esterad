//
//  RateOrderPopup.swift
//  Esterad
//
//  Created by Haneen on 02/12/2025.
//

import UIKit
import Cosmos

class RateOrderPopup: BaseViewController {
    
    //MARK: - Outlets -
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var rateTextView: DropDownTextView!
    @IBOutlet weak var ratingView: CosmosView!
    
    //MARK: - Properties -
    
    var delegate : RateOrderProtocol?
    
    //MARK: - Initializer  -
    
    init(){
        super.init(nibName: "RateOrderPopup", bundle: nil)
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
    
    //MARK: - Actions -
 
    @objc func onBackViewTapped(){
        hide()
    }
        
    @IBAction func didTapRate(_ sender: UIButton) {
        guard let starsRating = validateStarsRating() else { return }
         delegate?.didTapRateOrder(rate : starsRating ,comment : valitadteComment())
        hide()
    }
}

//MARK: - Validation -

extension RateOrderPopup {
    
    func validateStarsRating() -> Double? {
        if  ratingView.rating > 0 {
            return ratingView.rating
        } else {
            show(errorMessage: ValidationError.emptyRatingStars.localizedDescription)
            return nil
        }
    }
    
    func valitadteComment() -> String? {
        guard let comment = rateTextView.textView.text , !comment.trimWhiteSpace().isEmpty else {
            return nil
        }
        return comment
    }
}

//MARK: - Delegate Protocol -

protocol RateOrderProtocol {
    func didTapRateOrder(rate : Double ,comment : String?)
}
