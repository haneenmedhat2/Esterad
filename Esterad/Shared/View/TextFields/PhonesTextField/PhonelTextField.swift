//
//  GeneralTextField.swift
//  Cleaf
//
//  Created by Haneen Medhat on 26/04/2025.
//

import UIKit
@IBDesignable
class PhoneTextField: UIView {
    
 //MARK: - Outlets -
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var txtField: UITextField!
    @IBOutlet weak var phonesBtn: UIButton!
    @IBOutlet weak var trailingIconImg: UIImageView!
    @IBOutlet weak var countryIcon: UIImageView!
    @IBOutlet weak var phoneStackView: UIStackView!
    @IBOutlet weak var txtFieldStackView: UIStackView!
    @IBOutlet weak var countryCodeStackView: UIStackView!
    
//MARK: - Properties -
    
    var onTap : (() -> ())?
    @IBInspectable var titleTxt : String = "" {
        didSet{
            titleLabel.text = titleTxt.localized
        }
    }

    @IBInspectable var placeHolderTxt : String = "" {
        didSet{
            txtField.placeholder = placeHolderTxt.localized
        }
    }
    
    @IBInspectable var stackBorderColor : UIColor? {
        didSet{
            txtFieldStackView.layer.borderColor = stackBorderColor?.cgColor
            txtFieldStackView.layer.borderWidth = 1
            txtFieldStackView.layer.masksToBounds = true
        }
    }
    
    @IBInspectable var stackBackgroundColor : UIColor = UIColor.textFieldBackground {
        didSet{
            txtFieldStackView.backgroundColor = stackBackgroundColor
        }
    }
    
    @IBInspectable var countryStackView : Bool = false {
        didSet{
            countryCodeStackView.isHidden = countryStackView
        }
    }
    
    //MARK: - Initializer -
    
    override init(frame:CGRect){
        super.init(frame: frame)
        configureView()
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
        setupView()

    }
    //MARK: - Nib file configuration -
    
    func loadViewFromNib(nibName:String) -> UIView{
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as! UIView
    }
    
    func configureView(){
        let view = loadViewFromNib(nibName: "PhoneTextField")
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    func setupView(){
        txtField.keyboardType = .asciiCapableNumberPad
    }
    
//MARK: - Actions -
    
    @IBAction func showPhoneView(_ sender: UIButton) {
        onTap?()
    }
}
