//
//  PickerListPopup.swift
//  Esterad
//
//  Created by Haneen on 17/11/2025.
//

import UIKit

class PickerListPopup: BaseViewController {
    
    //MARK: - Outlets -
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: TableViewContentSized!
    
    //MARK: - Properties -
    
    var titleText: String = ""
    var pickerList: [PickerModel] = []
    var onItemSelected: ((PickerModel?) -> Void)?
    var selectedItem: PickerModel?

    //MARK: - Initializer  -
    
    init() {
        super.init(nibName: "PickerListPopup", bundle: nil)
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
extension PickerListPopup: UITableViewDataSource, UITableViewDelegate {

    func configureTableView(){
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "BasicCell")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pickerList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BasicCell", for: indexPath)
        let item = pickerList[indexPath.row]
        cell.textLabel?.text = item.name
        cell.textLabel?.font = .systemFont(ofSize: 16)
        cell.selectionStyle = .none
        cell.tintColor = .main
        if item.id == selectedItem?.id {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let value = pickerList[indexPath.row]
        
        if selectedItem?.id == value.id {
            selectedItem = nil
            tableView.reloadData()
            onItemSelected?(nil)
            dismiss(animated: true)
            return
        }
        
        selectedItem = value
        tableView.reloadData()
        onItemSelected?(value)
        dismiss(animated: true)
    }

}
