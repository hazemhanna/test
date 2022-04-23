//
//  HomeViewController.swift
//  ElsupplierApp
//
//  Created by Ahmed Madeh on 16/04/2022.
//

import UIKit

class HomeViewController: BaseTabBarViewController {

    // MARK: - Outlets
    @IBOutlet weak var userView: UserSectionView!
    @IBOutlet weak var offersCollectionView: UICollectionView!
    @IBOutlet weak var deptCollectionView: UICollectionView!
    @IBOutlet weak var deptCollectionViewHeight: NSLayoutConstraint!
    
    // MARK: - Variables
    let viewModel = HomeViewModel()
    var homeModel = HomeModel()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Functions
    override func setupView() {
        super.setupView()
        offersCollectionView.registerCell(ofType: HomeOfferCollectionViewCell.self)
        deptCollectionView.registerCell(ofType: HomeDeptCollectionViewCell.self)
        userView.delegate = self
        deptCollectionViewHeight.constant = ((10.0 / 3.0).rounded(.up) * 180.0)
        viewModel.loadHome()
        if let user = UserModel.current {
            userView.userPic.setImageWith(stringUrl: user.image, placeholder: R.image.screenShot20220412At95108PM())
        }
    }
    
    override func shouldShowNavigation() -> Bool {
        false
    }
    
    override func shouldShowTopView() -> Bool {
        false
    }
    
    override func tabBarItemTitle() -> String? {
        "Home".localized
    }
    
    override func tabBarItemImage() -> UIImage? {
        R.image.home()
    }
    
    override func tabBarItemSelectedImage() -> UIImage? {
        R.image.homeActive()
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
        viewModel.homeModel
            .bind(onNext: {
                self.homeModel = $0
                self.offersCollectionView.reloadData()
                self.deptCollectionView.reloadData()
//                self.deptCollectionViewHeight.constant = $0.
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Actions

}

extension HomeViewController: UserSectionViewDelegate {
    func didTapNotifications() {
        push(controller: NotificationsViewController())
    }
    
    func didTapProfile() {
        push(controller: ProfileViewController())
    }
    
    func didTapSearch() {
        #warning("implement search")
    }
}

extension HomeViewController: UICollectionViewDelegate,
                              UICollectionViewDataSource,
                              UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView == offersCollectionView ? homeModel.sliders.count : homeModel.trendingProducts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case offersCollectionView:
            let cell: HomeOfferCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)!
            cell.slider = homeModel.sliders[indexPath.row]
            return cell
        default:
            let cell: HomeDeptCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)!
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case offersCollectionView:
            break
        default:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView {
        case offersCollectionView:
            return collectionView.frame.size
        default:
            return CGSize(width: (collectionView.frame.width / 3) - 18, height: 180)
        }
    }
    
}
