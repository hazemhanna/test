//
//  HomeViewModel.swift
//  ElsupplierApp
//
//  Created by Ahmed Madeh on 23/04/2022.
//

import RxSwift
import RxCocoa

final class HomeViewModel: BaseViewModel {
    
    var homeModel = PublishRelay<HomeModel>()
    let homeApis = HomeAPIs()
    let supplierApis = SupplierAPIs()
    var supplierDetails = PublishRelay<SupplierDetailsModel>()
    var suppliers = PublishRelay<PagedObject<SupplierModel>>()

    func loadHome() {
        isLoading.accept(true)
        homeApis.loadHome().subscribe { [weak self] homeModel in
            guard let self = self else { return }
            self.isLoading.accept(false)
            self.homeModel.accept(homeModel)
        } onError: {[weak self] error in
            guard let self = self else { return }
            self.isLoading.accept(false)
            self.error.accept(error)
        }.disposed(by: disposeBag)
    }
    
    func getSupplierDetails(with supplierId: Int) {
        isLoading.accept(true)
        supplierApis.showSupplier(with: supplierId).subscribe { [weak self] supplier in
            self?.isLoading.accept(false)
            self?.supplierDetails.accept(supplier)
        } onError: { [weak self] in
            self?.isLoading.accept(false)
            self?.error.accept($0)
        }.disposed(by: disposeBag)
    }
    
    func loadCategorySuppliers(categoryId: String, page: Int) {
        isLoading.accept(true)
        homeApis.filterSuppliers(
            isPromotion: 0,
            page: page,
            categoryId: categoryId
        ).subscribe { [weak self] response in
            self?.isLoading.accept(false)
            self?.suppliers.accept(response)
        } onError: { [weak self] in
            self?.isLoading.accept(false)
            self?.error.accept($0)
        }.disposed(by: disposeBag)
    }
}
