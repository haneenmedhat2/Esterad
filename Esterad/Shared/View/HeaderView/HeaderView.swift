//
//  HeaderView.swift
//  Waraqa
//
//  Created by Haneen on 05/08/2025.
//

import UIKit

class HeaderView: UIView {
    
    //MARK: - Outlets -
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var title: UILabel!
    
    //MARK: - Properties -
    
  
    @IBInspectable var fontSize: CGFloat = 32 {
        didSet {
            updateTitleFont()
        }
    }

    @IBInspectable var iconSize: CGFloat = 80 {
        didSet {
            updateIconSize()
        }
    }
    private func updateTitleFont() {
        title.font = UIFont(name: UIFont.FontNames.bold.name, size: fontSize)
    }

    // Helper to apply equal width & height
    private func updateIconSize() {
        icon.translatesAutoresizingMaskIntoConstraints = false
        
        if let widthConstraint = icon.constraints.first(where: { $0.firstAttribute == .width }) {
            widthConstraint.constant = iconSize
        } else {
            icon.widthAnchor.constraint(equalToConstant: iconSize).isActive = true
        }
        
        if let heightConstraint = icon.constraints.first(where: { $0.firstAttribute == .height }) {
            heightConstraint.constant = iconSize
        } else {
            icon.heightAnchor.constraint(equalToConstant: iconSize).isActive = true
        }
    }
    
    //MARK: - Initializer -
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateTitleFont()
    }
    
   //MARK: - Nib file Configuration -
    
    func loadViewFromNib(nibName: String) -> UIView {
        let nib = UINib(nibName: nibName, bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as! UIView
    }
    
    func configureView() {
        let view = loadViewFromNib(nibName: "HeaderView")
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }
}
