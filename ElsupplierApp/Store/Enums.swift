//
//  Enums.swift
//
//  Created by Ahmed Madeh.
//

enum ServerType: String {
    case staging = "https://portal.elsupplier.com/stage/public/api"
    case live = ""
}

enum UserType: Int {
    case normal = 1
    case user = 2
    case agent = 3
}

enum SearchType: String {
    case supplier = "Supplier"
    case product = "Product"
}

enum FilterType {
    case areas
    case departments
}

enum OrderStatues : Int{
    case cancelled
    case pending
    case preparing
    case onRoute
    case delivered
}

