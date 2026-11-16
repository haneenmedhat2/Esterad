//
//  ProfileView.swift
//  Esterad
//
//  Created by Haneen on 30/10/2025.
//

import UIKit
import Kingfisher

class ProfileView: UIView {

    //MARK: - Outlets -
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    
    //MARK: - Properties -

    //MARK: - Initializer -
    
    override init(frame:CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
    }
    
    //MARK: - Nib file configuration -
    
    func loadViewFromNib(nibName:String) -> UIView {
        let nib = UINib(nibName: nibName, bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as! UIView
    }
    
    func configureView(){
        let view = loadViewFromNib(nibName: "ProfileView")
        view.frame = self.bounds
        self.addSubview(view)
        
        profileImage.layer.cornerRadius = profileImage.frame.height / 2
        profileImage.layer.borderColor = UIColor.textFieldBorder.cgColor
        profileImage.layer.borderWidth = 1
    }
 
    //MARK: - View Setup -
    
    func setupView(image: String ,username : String , phone: String , countryKey : String ){
        profileImage.kf.setImage(with: URL(string: image),placeholder: UIImage(resource: .avatar),
                                 options: [.onFailureImage(UIImage(resource: .avatar))])
        usernameLabel.text = username
        phoneLabel.text = countryKey + " " + phone
    }
}
