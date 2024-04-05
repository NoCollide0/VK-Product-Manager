//
//  ProductScreenModel.swift
//  Менеджер товаров ВК
//
//  Created by Федор Шашков on 02.04.2024.
//

import Foundation


struct ProductById {
    let id: Int
    let title: String
    let price: String
    let currency: String
    let imageUrl: URL
    let availability: Int
    let description: String
    let date: Date
}
