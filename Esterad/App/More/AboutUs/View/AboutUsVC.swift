//
//  AboutUsVC.swift
//  Esterad
//
//  Created by Haneen on 11/11/2025.
//

import UIKit

class AboutUsVC: BaseViewController {

    //MARK: - Outlets -
    
    @IBOutlet weak var contentTextView: UITextView!
    
    //MARK: - Properties -
    
    var viewModel : AboutUsVMProtocol
    
    //MARK: - Initializer -
    
    init(viewModel : AboutUsVMProtocol){
        self.viewModel = viewModel
        super.init(nibName: "AboutUsVC", bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Life Cycle -
    
    override func viewDidLoad(){
        super.viewDidLoad()
        initialConfiguration()
    }
    
    //MARK: - Initial Setup -
    
    func initialConfiguration() {
        self.title = "about_app".localized
        bindViewModel()
        viewModel.aboutUsRequest()
    }
    
    //MARK: - ViewModel Binding -
    
    private func bindViewModel() {
        
        viewModel.aboutUsPublisher
            .sinkOnMain { [weak self] result in
                guard let self = self else { return }
                let text = result?.data?.about ?? ""
                let convertedString = text.htmlToAttributedString
                contentTextView.attributedText = convertedString
            }
            .store(in: &cancellables)
        
        error(viewModel.errorPublisher)
    }
}
