//
//  FAQVM.swift
//  Esterad
//
//  Created by Haneen on 10/11/2025.
//

import Foundation
import Combine

protocol FAQVMProtocol {

    var faqPublisher: Published<BaseResponse<FAQResponse>?>.Publisher { get }

    var isLoadingPublisher: Published<Bool>.Publisher { get }
    var errorPublisher: Published<Error?>.Publisher { get }
        
    var faqList : [ExpandableItem] { get set }
    
    func faqRequest()
    func convertFAQsToExpandableItems(faqs: [FAQModel]) -> [ExpandableItem]

}

final class FAQVM: BaseViewModel,FAQVMProtocol {
    
    @Published var faq: BaseResponse<FAQResponse>?
    
    var faqPublisher: Published<BaseResponse<FAQResponse>?>.Publisher { $faq }
    
    var faqList : [ExpandableItem] = []

    var isLoadingPublisher: Published<Bool>.Publisher { $isLoading }
    var errorPublisher: Published<Error?>.Publisher { $error }
    
    func faqRequest(){
        isLoading = true
        Task {
            do {
                let result = try await getAllRequest(MoreEndpoints.getFaq())
                faqList = convertFAQsToExpandableItems(faqs: result.data?.fqs ?? [])
                print(faqList.count)
                faq = result

                isLoading = false
                
            } catch {
                isLoading = false
                self.error = error
            }
        }
    }
    
    func convertFAQsToExpandableItems(faqs: [FAQModel]) -> [ExpandableItem] {
        return faqs.map { ExpandableItem(faq: $0) }
    }
}
