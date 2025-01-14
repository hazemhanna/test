//
//  MyPostsViewController.swift
//  ElsupplierApp
//
//  Created by MAC on 15/06/2022.
//

import UIKit
import DropDown
import AVKit
import AVFoundation

class MyPostsViewController: BaseTabBarViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var userView: UserSectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var arrowBtn : UIButton!
    @IBOutlet weak var titleLbl : UILabel!
    
    // MARK: - Variables
    let dropDown = DropDown()
    var TypesArr = ["_allPosts".localized, "_myPosts".localized]
    let viewModel = PostsViewModel()
    let supplierViewModel = SupplierViewModel()
    var selectedType = 0
    var posts = [PostModel](){
        didSet{
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let user = UserModel.current {
            userView.userPic.setImageWith(stringUrl: user.image, placeholder: R.image.appLogo())
        }
    }
    
    convenience init(selectedType: Int) {
        self.init()
        self.selectedType = selectedType
    }

    // MARK: - Functions
    override func setupView() {
        super.setupView()
        if selectedType == 0 {
            viewModel.loadAllPosts()
            titleLbl.text = "_allPosts".localized
        } else {
            viewModel.loadMyPosts()
            titleLbl.text = "_myPosts".localized
        }
        tableView.registerCell(ofType: MyPostsTableViewCell.self)
//        tableView.rowHeight = UITableView.automaticDimension
//        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.isRefreshControlEnabled = true
        userView.delegate = self
        navigationController?.navigationBar.isHidden = true
        tabBarController?.navigationController?.navigationBar.isHidden = true
        SetupDropDown()
    }
    
    @IBAction func StatusBtn(_ sender: Any) {
        dropDown.show()
    }
    
    func SetupDropDown() {
        dropDown.anchorView = arrowBtn
        dropDown.dataSource = TypesArr
        dropDown.selectionAction = {[weak self] (index, item) in
            self?.titleLbl.text =  item
            self?.selectedType = index
            if index == 0 {
                self?.viewModel.loadAllPosts()
            } else {
                self?.viewModel.loadMyPosts()
            }
        }
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.direction = .bottom
        dropDown.width = 277
    }
    
    override func shouldShowNavigation() -> Bool { false }

    override func tabBarItemTitle() -> String? { "Posts".localized }
    
    override func tabBarItemImage() -> UIImage? { R.image.posts() }
    
    override func tabBarItemSelectedImage() -> UIImage? { R.image.postsActive() }
    
    override func shouldShowTabBar() -> Bool { true }
    
    override func bindViewModelToViews() {
        viewModel.isLoading.bind {
            Hud.showDismiss($0)
        }.disposed(by: disposeBag)
        
        supplierViewModel.isLoading.bind {
            Hud.showDismiss($0)
        }.disposed(by: disposeBag)
    }
    
    override func setupCallbacks() {
        viewModel.posts.bind { post in
            self.posts = post
        }.disposed(by: disposeBag)
        
        viewModel.succeeded.bind { [weak self] message in
            if self?.selectedType == 0 {
                self?.viewModel.loadAllPosts()
            } else {
                self?.viewModel.loadMyPosts()
            }
            Alert.show(message: message)
        }.disposed(by: disposeBag)
                
        viewModel.error.bind {
            Alert.show(message: $0.localizedDescription)
        }.disposed(by: disposeBag)
        
        supplierViewModel.error.bind {
            Alert.show(message: $0.localizedDescription)
        }.disposed(by: disposeBag)
        
        supplierViewModel.callbackRequested.bind { _ in
            Alert.show(message: "_request_call_succeed")
        }.disposed(by: disposeBag)
    }
    
    // MARK: - Actions
    @IBAction func addPostClicked(_ sender: UIButton) {
        push(controller:
                AddPostsViewController() { [weak self] in
            self?.didRefresh(self?.tableView.refreshControl ?? UIRefreshControl())
        })
    }
    
}

extension MyPostsViewController: UITableViewDelegate, TableViewDataSource, UIRefreshControlDelegate {
    
    func viewForPlaceholder(in tableView: UITableView) -> UIView {
        Bundle.main.loadNibNamed("EmptyPostsView", owner: self, options: [:])?.first as? UIView ?? UIView()
    }
    
    func shouldShowPlaceholder(in tableView: UITableView) -> Bool { posts.isEmpty }
    
    func frameForPlaceholder(in tableView: UITableView) -> CGRect { tableView.bounds }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MyPostsTableViewCell = tableView.dequeueReusableCell()!
        cell.post = posts[indexPath.row]
        cell.userActionsStackView.isHidden = true
        cell.delegate = self
        return cell
    }
    
    func didRefresh(_ refreshControl: UIRefreshControl) {
        refreshControl.endRefreshing()
        if selectedType == 0 {
            viewModel.loadAllPosts()
        } else {
            viewModel.loadMyPosts()
        }
    }
}

extension MyPostsViewController: UserSectionViewDelegate {
    func didTapNotifications() {
        push(controller: NotificationsViewController())
    }
    
    func didTapProfile() {
        push(controller: ProfileViewController())
    }
    
    func didTapSearch() {
        push(controller: SearchFilterViewController())
    }
}

extension MyPostsViewController: MyPostsTableViewCellDelegate {
    func myPostsTableViewCell(_ cell: MyPostsTableViewCell, didLike item: PostModel) {
        viewModel.likePost(postId: item.id)
    }
    
    func myPostsTableViewCell(_ cell: MyPostsTableViewCell, didAddComent item: PostModel,comment : String) {
        viewModel.addComment(postId: item.id, comment: comment)
    }
    
    func myPostsTableViewCell(_ cell: MyPostsTableViewCell, sendMessage item: PostModel) {
        push(controller: SendMessageViewController(supplierId: item.ownerId))
    }
    
    func myPostsTableViewCell(_ cell: MyPostsTableViewCell, makeCall item: PostModel) {
        supplierViewModel.requestCallBack(supplierId: item.ownerId)
    }
    
    func myPostsTableViewCell(_ cell: MyPostsTableViewCell, selectMedia item: PostModel,index :Int){
        push(controller: PostsMediaViewController(list: item.media, index: index))
    }
    
    func myPostsTableViewCell(_ cell: MyPostsTableViewCell, playVideo item: String){
        guard let videoURL = URL(string:  item) else { return }
        let video = AVPlayer(url: videoURL)
        let videoPlayer = AVPlayerViewController()
        videoPlayer.player = video
        videoPlayer.modalPresentationStyle = .overFullScreen
        videoPlayer.modalTransitionStyle = .crossDissolve
        self.present(videoPlayer, animated: true, completion: {
            video.play()
        })
    }
}
