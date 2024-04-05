//
//  ExelScreenModel.swift
//  Менеджер товаров ВК
//
//  Created by Федор Шашков on 04.04.2024.
//

import Foundation

struct ExelAlbum {
    let id: Int
    let title: String
}

struct ExelProduct {
    let id: Int
    let title: String
    let price: String
    let currency: String
    let imageUrl: URL
    let availability: Int
    let description: String
    let date: Date
    let albumTitle: String
}
