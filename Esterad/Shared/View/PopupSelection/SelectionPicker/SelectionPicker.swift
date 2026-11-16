//
//  SelectionPicker.swift
//  Esterad
//
//  Created by Haneen on 20/12/2025.
//

import UIKit

class SelectionPicker: BaseViewController {
    
    //MARK: - Outlets -
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: TableViewContentSized!
    
    //MARK: - Properties -
    
    var titleText: String = ""
    var pickerList: [SelectionModelPicker] = []
    var selectedItem: SelectionModelPicker?
    var onItemSelected: ((SelectionModelPicker?) -> Void)?

    //MARK: - Initializer  -
    
    init() {
        super.init(nibName: "SelectionPicker", bundle: nil)
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
        configureTableView()
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
        
        titleLabel.text = titleText
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
    
    @objc private func onBackViewTapped() {
        self.hide()
    }
}

// MARK: - UITableView Configuration  -
extension SelectionPicker: UITableViewDelegate, UITableViewDataSource {
    
    func configureTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "BasicCell")
        tableView.delegate = self
        tableView.dataSource = self
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        pickerList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BasicCell", for: indexPath)
        let item = pickerList[indexPath.row]
        
        cell.textLabel?.text = item.pickerName
        cell.selectionStyle = .none
        cell.tintColor = .main
        if item.pickerId == selectedItem?.pickerId {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let value = pickerList[indexPath.row]

        if selectedItem?.pickerId == value.pickerId {
            selectedItem = nil
            tableView.reloadData()
            onItemSelected?(nil)
            hide()
            return
        }

        selectedItem = value
        tableView.reloadData()
        onItemSelected?(value)
        hide()
    }
}
