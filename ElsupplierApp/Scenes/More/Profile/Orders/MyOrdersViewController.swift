//
//  MyOrdersViewController.swift
//  ElsupplierApp
//
//  Created by Ahmed Madeh on 04/06/2022.
//

import UIKit

class MyOrdersViewController: BaseViewController {

    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var selectedFilter: UILabel!
    
    // MARK: - Variables
    let viewModel = ProfileViewModel()
    var model = PagedObject<OrderModel>()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Functions
    override func setupView() {
        super.setupView()
        title = "_my_orders".localized
        tableView.registerCell(ofType: OrderTableViewCell.self)
        viewModel.listOrders(page: model.nextPage)
    }
    
    override func bindViewModelToViews() {
        viewModel.isLoading.bind {
            if $0 {
                Hud.show()
            } else {
                Hud.hide()
            }
        }.disposed(by: disposeBag)
    }
    
    override func setupCallbacks() {
        viewModel.orders.bind { [weak self] in
            guard let self = self else { return }
            self.model.items.append(contentsOf: $0.items)
            self.model.totalCount = $0.totalCount
            self.model.pageSize = $0.pageSize
            self.tableView.reloadData()
        }.disposed(by: disposeBag)
    }
    
    // MARK: - Actions
    @IBAction func filterClicked(_ sender: UIButton) {
    }
    
}

extension MyOrdersViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        model.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: OrderTableViewCell = tableView.dequeueReusableCell()!
        let order = model.items[indexPath.row]
        cell.orderNo.text = "order_no:".localized + order.id.string()
        cell.dateLabel.text = order.datePlaced
        cell.stateLabel.text = order.orderStatus
        cell.supplierName.text = "_supplier:".localized + order.supplierName
        cell.totalLabel.text = "total:".localized + order.totalAmount.string() + " LE".localized
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        push(controller: OrderDetailsViewController(order: model.items[indexPath.row]))
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 120 }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if model.hasNext(indexPath) {
            viewModel.listOrders(page: model.nextPage)
        }
    }
    
}
