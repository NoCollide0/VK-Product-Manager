//
//  MainScreenModel.swift
//  Менеджер товаров ВК
//
//  Created by Федор Шашков on 26.03.2024.
//

import Foundation


struct Album {
    let id: Int
    let title: String
}


struct Product {
    let id: Int
    let title: String
    let price: String
    let currency: String
    let imageUrl: URL
    let availability: Int
}
