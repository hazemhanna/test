//
//  AddTenderViewController.swift
//  ElsupplierApp
//
//  Created by Ahmed Madeh on 08/06/2022.
//

import UIKit

class AddTenderViewController: BaseTabBarViewController {

    // MARK: - Outlets
    @IBOutlet weak var selectedCategoryLabel: UILabel!
    @IBOutlet weak var selectedProductLabel: UILabel!
    @IBOutlet weak var tenderDetailsTV: UITextView!
    
    // MARK: - Variables
    let viewModel = ProfileViewModel()
    let searchFilterViewModel = SearchFilterViewModel()
    var selectedCategory: CategoryModel? = nil
    var isFromTabbar = false

    // MARK: - Life Cycle
    convenience init(isFromTabbar: Bool) {
        self.init()
        self.isFromTabbar = isFromTabbar
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "_new_tender".localized
        tabBarController?.navigationController?.isNavigationBarHidden = !isFromTabbar
    }
    
    override func shouldShowNavigation() -> Bool { true }
    
    // MARK: - Functions
    override func setupView() {
        super.setupView()
    }
    
    override func tabBarItemTitle() -> String? { "Tender".localized }
    
    override func tabBarItemImage() -> UIImage? { R.image.tender() }
    
    override func tabBarItemSelectedImage() -> UIImage? { R.image.tenderActive() }
    
    override func shouldShowTabBar() -> Bool { isFromTabbar }
    
    override func bindViewModelToViews() {
        viewModel.isLoading.bind {
            Hud.showDismiss($0)
        }.disposed(by: disposeBag)
        
        searchFilterViewModel.isLoading.bind {
            Hud.showDismiss($0)
        }.disposed(by: disposeBag)
    }
    
    override func bindViewsToViewModel() {
        tenderDetailsTV.rx.text
            .orEmpty
            .bind(to: viewModel.tenderDetails)
            .disposed(by: disposeBag)
    }
    
    override func setupCallbacks() {
        viewModel.tenderAdded.bind { [weak self] _ in
            Alert.show(title: nil, message: "_tender_added", cancelTitle: "ok", otherTitles: []) { _ in
                guard let self = self else { return }
                if self.isFromTabbar {
                    self.selectedCategoryLabel.text = "_choose_category"
                    self.selectedCategory = nil
                    self.viewModel.selectedCategory.accept(nil)
                    self.selectedProductLabel.text = "_choose_product"
                    self.viewModel.selectedProduct.accept(nil)
                    self.tenderDetailsTV.text = ""
                } else {
                    self.pop()
                }
            }
        }.disposed(by: disposeBag)
        
        viewModel.error.bind {
            Alert.show(message: $0.localizedDescription)
        }.disposed(by: disposeBag)
        
        searchFilterViewModel.categories.bind { [weak self] in
            self?.showCategories($0)
        }.disposed(by: disposeBag)
        
        searchFilterViewModel.categoryProducts.bind { [weak self] in
            self?.showProducts($0)
        }.disposed(by: disposeBag)
        
        searchFilterViewModel.error.bind {
            Alert.show(message: $0.localizedDescription)
        }.disposed(by: disposeBag)
    }
    
    func showCategories(_ categories: [CategoryModel]) {
        ActionSheet.show(title: "_choose_category", cancelTitle: "Cancel", otherTitles: categories.map({ $0.name }), sender: view) { [weak self] index in
            guard let self = self, index != 0 else { return }
            self.selectedCategoryLabel.text = categories[index - 1].name
            self.selectedCategory = categories[index - 1]
            self.viewModel.selectedCategory.accept(categories[index - 1].id)
        }
    }
    
    func showProducts(_ products: [ProductModel]) {
        ActionSheet.show(title: "_choose_product", cancelTitle: "Cancel", otherTitles: products.map { $0.name }, sender: view) { [weak self] index in
            guard let self = self, index != 0 else { return }
            self.selectedProductLabel.text = products[index - 1].name
            self.viewModel.selectedProduct.accept(products[index - 1].id)
        }
    }
    
    // MARK: - Actions
    @IBAction func selectCategoryClicked(_ sender: UIButton) {
        searchFilterViewModel.listCategories()
    }
    
    @IBAction func selectProductClicked(_ sender: UIButton) {
        searchFilterViewModel.listCategoryProducts(categoryId: selectedCategory?.id ?? 0)
    }
    
    @IBAction func sendClicked(_ sender: UIButton) {
        viewModel.storeTender()
    }
}
