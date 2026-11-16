//
//  RoomsVC.swift
//  Esterad
//
//  Created by Haneen on 15/10/2025.
//

import UIKit

class RoomsVC: BaseViewController {
    
    //MARK: - Outlets -
    
    @IBOutlet weak var tableView: TableViewContentSized!
    
    //MARK: - Properties -
    
    let viewModel : RoomsVMProtocol
    
    //MARK: - Initializer -
    
    init(viewModel :RoomsVMProtocol){
        self.viewModel = viewModel
        super.init(nibName: "RoomsVC", bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Life Cycle -
    
    override func viewDidLoad(){
        super.viewDidLoad()
        initialConfiguration()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.getRooms()
    }
    
    //MARK: - Initial Setup -
    
    private func initialConfiguration(){
        self.title = "chat".localized
        configureTableView()
        bindToViewModel()
        setupNotificationButton()
    }
    
    //MARK: - ViewModel binding -
    
    private func bindToViewModel(){
        loading(viewModel.isLoadingPublisher)
        
        viewModel.chatRoomsPublisher
            .sinkOnMain { [weak self] result in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        error(viewModel.errorPublisher)
    }
}

//MARK: - TableView Configutations -

extension RoomsVC : UITableViewDelegate , UITableViewDataSource {
    
    private func configureTableView(){
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(cellType: RoomCell.self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.setPlaceholder(isEmpty: viewModel.roomsList.isEmpty , separator: .none, style: .emptyRooms)
        return viewModel.roomsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: RoomCell.self, for: indexPath)
        let item = viewModel.roomsList[indexPath.row]
        cell.setupCell(model: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = viewModel.roomsList[indexPath.row]
        let vc = ChatVC(viewModel: ChatVM(roomId: item.id ?? 0, senderName: item.name ?? ""))
        vc.hidesBottomBarWhenPushed = true
        push(vc)
    } 
}

//MARK: - Routes -

extension RoomsVC {
    func goToNotification(){
      let vc = NotificationVC(viewModel: NotificationVM())
        vc.hidesBottomBarWhenPushed = true
        push(vc)
    }
}
