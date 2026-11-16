//
//  LanguagePopUp.swift
//  Waraqa
//
//  Created by Haneen on 04/08/2025.
//

import UIKit

class LanguagePopUp: BaseViewController {

    //MARK: - Outlets -
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var englishBtn: RadioButton!
    @IBOutlet weak var arabicBtn: RadioButton!
    @IBOutlet weak var arabicStackView: UIStackView!
    @IBOutlet weak var englishStackView: UIStackView!
    @IBOutlet weak var arabicLabel: UILabel!
    @IBOutlet weak var englishLabel: UILabel!
    
    //MARK: - Properties -
    
    let isFirstTime: Bool
    private var radioButtons: [RadioButton] = []
    private var selectedLanguage: String?
    let viewModel = SettingsVM()
    
    //MARK: - Initializer  -
    
    init(isFirstTime: Bool = true) {
        self.isFirstTime = isFirstTime
        super.init(nibName: "LanguagePopUp", bundle: nil)
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
        
        arabicBtn.tag = 1
        englishBtn.tag = 2
        
        radioButtons = [arabicBtn, englishBtn]
        
        for button in radioButtons {
            button.addTarget(self, action: #selector(radioButtonTapped(_:)), for: .valueChanged)
        }
        let backTap = UITapGestureRecognizer(target: self, action: #selector(onBackViewTapped))
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(backTap)
        
        let arabicTap = UITapGestureRecognizer(target: self, action: #selector(onArabicTapped))
        arabicStackView.isUserInteractionEnabled = true
        arabicStackView.addGestureRecognizer(arabicTap)
        
        let englishTap = UITapGestureRecognizer(target: self, action: #selector(onEnglishTapped))
        englishStackView.isUserInteractionEnabled = true
        englishStackView.addGestureRecognizer(englishTap)
        
        if !isFirstTime {
            if Language.apiLanguage() == "en" {
                englishBtn.isOn = true
                selectedLanguage = "en"
            }
            
            if Language.apiLanguage() == "ar" {
                arabicBtn.isOn = true
                selectedLanguage = "ar"
            }
        }
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
    
    @IBAction func confirmlBtnTapped(_ sender: UIButton) {
        guard let language = selectedLanguage ,  !language.trimWhiteSpace().isEmpty else {
            self.show(errorMessage : ValidationError.unSelectedItem.localizedDescription)
            return
        }
        
        if language != Language.apiLanguage(){
            if !UserDefaults.guest {
                viewModel.changeLanguage(lang: language)
            }
            openAppSettings()
        }
        self.hide()
    }
    
    private func openAppSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            }
        }
    }
    
    @objc func radioButtonTapped(_ sender: RadioButton) {
        for button in radioButtons {
               button.isOn = (button == sender)
           }
        switch sender.tag {
        case 1:
            selectedLanguage = "ar"
        case 2:
            selectedLanguage = "en"
        default:
            break
        }
    }
    
    @objc private func onBackViewTapped() {
        self.hide()
    }
    
    @objc private func onArabicTapped() {
        radioButtonTapped(arabicBtn)
        arabicLabel.textColor = .main
        englishLabel.textColor = .hint
    }

    @objc private func onEnglishTapped() {
        radioButtonTapped(englishBtn)
        arabicLabel.textColor = .hint
        englishLabel.textColor = .main
    }
}
