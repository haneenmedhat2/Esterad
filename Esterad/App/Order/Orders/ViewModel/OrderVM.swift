//
//  OrderVM.swift
//  Esterad
//
//  Created by Haneen on 30/11/2025.
//

import Foundation
import Combine

protocol OrderVMProtocol {
    var orderTypes : [OrderType] { get }
}

final class OrderVM: BaseViewModel,OrderVMProtocol {
    var orderTypes : [OrderType] = OrderType.allCases
}
