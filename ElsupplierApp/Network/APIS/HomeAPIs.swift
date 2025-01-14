//
//  HomeAPIs.swift
//  ElsupplierApp
//
//  Created by Ahmed Madeh on 22/04/2022.
//

import ESNetworkManager
import RxSwift

class HomeAPIs {
    func loadHome() -> Single<HomeModel> {
        let request = ESNetworkRequest("home")
        request.selections = [.key("data")]
        return NetworkManager.execute(request: request)
    }
    
    func filterSuppliers
    (
        isPromotion: Int,
        page: Int,
        keyword: String? = nil,
        parentCategoryId: String? = nil,
        categoryId: String? = nil,
        areaId: Int? = nil,
        priceFrom: Int? = nil,
        priceTo: Int? = nil
    ) -> Single<PagedObject<SupplierModel>> {
        var path = "filter?searchType=Supplier&isPromotion=\(isPromotion)&page=\(page)"
        if let keyword = keyword {
            path += "&keyword=\(keyword)"
        }
        if let parentCategoryId = parentCategoryId {
            path += "&parentCategoryId=\(parentCategoryId)"
        }
        if let categoryId = categoryId {
            path += "&CategoryId=\(categoryId)"
        }
        if let areaId = areaId {
            path += "&areaId=\(areaId)"
        }
        if let priceFrom = priceFrom {
            path += "&price_from=\(priceFrom)"
        }
        if let priceTo = priceTo {
            path += "&price_to=\(priceTo)"
        }
        let request = ESNetworkRequest(path)
        request.selections = [.key("data")]
        return NetworkManager.execute(request: request)
    }
    
    func filterProducts
    (
        isPromotion: Int,
        page: Int,
        keyword: String? = nil,
        parentCategoryId: String? = nil,
        categoryId: String? = nil,
        areaId: Int? = nil,
        priceFrom: Int? = nil,
        priceTo: Int? = nil
    ) -> Single<PagedObject<ProductModel>> {
        var path = "filter?searchType=Product&isPromotion=\(isPromotion)&page=\(page)"
        if let keyword = keyword {
            path += "&keyword=\(keyword)"
        }
        if let parentCategoryId = parentCategoryId {
            path += "&parentCategoryId=\(parentCategoryId)"
        }
        if let categoryId = categoryId {
            path += "&CategoryId=\(categoryId)"
        }
        if let areaId = areaId {
            path += "&areaId=\(areaId)"
        }
        if let priceFrom = priceFrom {
            path += "&price_from=\(priceFrom)"
        }
        if let priceTo = priceTo {
            path += "&price_to=\(priceTo)"
        }
        let request = ESNetworkRequest(path)
        request.selections = [.key("data")]
        return NetworkManager.execute(request: request)
    }
}
