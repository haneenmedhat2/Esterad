//
//  PopupSelectionViewCell.swift
//  Cleaf
//
//  Created by Haneen on 29/04/2025.
//

import UIKit

class PopupSelectionViewCell: UITableViewCell {
    
   //MARK: - Outlets-
    
    @IBOutlet weak var selectionLabel: UILabel!
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var innerView: UIView!
    
    //MARK: - Properties -

    var isCircleFilled : Bool = false {
        didSet {
            updateCircleApearance()
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCircle()
        setupInnerCircle()
    }
   
    private func setupCircle(){
        circleView.layer.cornerRadius = circleView.frame.height / 2
        circleView.layer.masksToBounds = true
        circleView.layer.borderWidth = 1
        circleView.layer.borderColor = UIColor.hint.cgColor
        circleView.backgroundColor = .clear
    }
    private func setupInnerCircle() {
        innerView.layer.cornerRadius = innerView.frame.height / 2
        innerView.backgroundColor = UIColor.main
        innerView.isHidden = true
    }
    
    private func updateCircleApearance(){
        innerView.isHidden = !isCircleFilled
        circleView.layer.borderColor = UIColor.main.cgColor
    }
}
