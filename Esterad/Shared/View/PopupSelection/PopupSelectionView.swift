//
//  PopupSelectionView.swift
//  Cleaf
//
//  Created by Haneen on 29/04/2025.
//

import UIKit

class PopupSelectionView: BaseViewController {
    
    //MARK: - Outlets -
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var tableView: TableViewContentSized!
    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var closeImage: UIImageView!
    
    //MARK: - Properties -
    
    var selectionArray : [SelectionModelPicker] = []
    var selectedIndex : IndexPath?
    var selectionDelegate : SelectionPopUpDelegate?
    
    //MARK: - Nib file configuration -
    
    init(selectionArray:[SelectionModelPicker]) {
        self.selectionArray = selectionArray
        super.init(nibName: "PopupSelectionView", bundle: nil)
        self.modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configView()
    }
    
    //MARK: - View setup -
    
    func configView() {
        self.view.backgroundColor = .clear
        self.backView.backgroundColor  = .black.withAlphaComponent(0.6)
        self.backView.alpha = 0
        self.contentView.alpha = 0
        self.contentView.layer.cornerRadius = 12
        
        backView.isUserInteractionEnabled = true
        contentView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onCloseTapped))
        closeImage.addGestureRecognizer(tapGesture)
    }

    //MARK: - Action -
    
    @IBAction func confirmlBtnTapped(_ sender: UIButton) {
        guard let selectedIndex = selectedIndex else {
            self.show(errorMessage : ValidationError.unSelectedItem.localizedDescription)
            return
        }
        let selectedItem = selectionArray[selectedIndex.row]
        selectionDelegate?.onsSelectedItem(items: selectedItem)
        self.hide()
    }
    
    @objc func onCloseTapped(){
        self.hide()
    }
    
    //MARK: - View presentation -
    
    func appear(sender: UIViewController){
        sender.present(self, animated: false) {
            self.show()
        }
    }
    
    func show(){
        UIView.animate(withDuration: 1, delay: 0.1) {
            self.backView.alpha = 1
            self.contentView.alpha = 1
        }
    }
    
    func hide(){
        UIView.animate(withDuration: 1, delay: 0.0, options: .curveEaseOut) {
            self.backView.alpha = 0
            self.contentView.alpha = 0
        } completion: { _ in
            self.dismiss(animated: false)
            self.removeFromParent()
        }
    }
}

//MARK: - TableView DataSource & Delegate -

extension PopupSelectionView: UITableViewDataSource, UITableViewDelegate {
    
    func configureTableView(){
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(cellType: PopupSelectionViewCell.self, bundle: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectionArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        let cell = tableView.dequeueReusableCell(with: PopupSelectionViewCell.self, for: indexPath)
        cell.selectionLabel.text = selectionArray[indexPath.row].pickerName
        cell.selectionStyle = .none
        cell.isCircleFilled = (indexPath == selectedIndex)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let previousIndex = selectedIndex , previousIndex != indexPath {
            tableView.reloadRows(at: [previousIndex], with: .none)
            tableView.reloadData()
        }
        
        selectedIndex = indexPath
        tableView.reloadRows(at: [indexPath], with: .none)
        tableView.reloadData()
    }
}
