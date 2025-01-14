//
//  EditProfileViewController.swift
//  ElsupplierApp
//
//  Created by Ahmed Madeh on 15/04/2022.
//

import UIKit

class EditProfileViewController: BaseViewController {

    // MARK: - Outlets
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var cityTF: UITextField!
    @IBOutlet weak var mobileNoTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var activityTypeTF: UITextField!
    @IBOutlet weak var companyNameTF: UITextField!
    @IBOutlet weak var profilePic: UIImageView!
    
    // MARK: - Variables
    let viewModel = ProfileViewModel()

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Functions
    override func setupView() {
        super.setupView()
        title = "_personal_info".localized
        viewModel.showProfile()
    }
    
    override func bindViewsToViewModel() {
        nameTF.rx.text
            .orEmpty
            .bind(to: viewModel.name)
            .disposed(by: disposeBag)
        
        mobileNoTF.rx.text
            .orEmpty
            .bind(to: viewModel.mobileNo)
            .disposed(by: disposeBag)
        
        emailTF.rx.text
            .orEmpty
            .bind(to: viewModel.email)
            .disposed(by: disposeBag)
        
        companyNameTF.rx.text
            .orEmpty
            .bind(to: viewModel.companyName)
            .disposed(by: disposeBag)
        
        activityTypeTF.rx.text
            .orEmpty
            .bind(to: viewModel.companyType)
            .disposed(by: disposeBag)
    }
    
    override func bindViewModelToViews() {
        viewModel.isLoading.bind {
            Hud.showDismiss($0)
        }.disposed(by: disposeBag)
    }
    
    override func setupCallbacks() {
        viewModel.user.bind { [weak self] data in
            guard let self = self else { return }
            self.setupUI(data: data)
        }.disposed(by: disposeBag)
        
        viewModel.updatedSuccessfully.bind { [weak self] _ in
            guard let self = self else { return }
            Alert.show(title: nil, message: "Updated successfully", cancelTitle: "Ok", otherTitles: []) { index in
                self.pop()
            }
        }.disposed(by: disposeBag)
        
        viewModel.error.bind {
            Alert.show(message: $0.localizedDescription)
        }.disposed(by: disposeBag)
        
        viewModel.areas.bind { [weak self] areas in
            guard let self = self else { return }
            self.showAreas(areas: areas)
        }.disposed(by: disposeBag)
        
        viewModel.activities.bind { [weak self] activities in
            guard let self = self else { return }
            self.showActivities(activities: activities)
        }.disposed(by: disposeBag)
    }
    
    func setupUI(data: UserModel) {
        profilePic.setImageWith(stringUrl: data.image, placeholder: R.image.appLogo())
        nameTF.text = data.name
        mobileNoTF.text = data.phone
        emailTF.text = data.email
        cityTF.text = data.area.name
        activityTypeTF.text = data.userType.name
        companyNameTF.text = data.companyName
        viewModel.areaId.accept(data.area.id)
        bindViewsToViewModel()
    }
    
    func showActivities(activities: [UserTypeModel]) {
        ActionSheet.show(title: "Select Activity", cancelTitle: "Cancel", otherTitles: activities.map({ $0.name }), sender: activityTypeTF) { [weak self] index in
            guard let self = self else { return }
            if index != 0 {
                self.activityTypeTF.text = activities[index - 1].name
                self.viewModel.companyType.accept(activities[index - 1].name)
                self.viewModel.activityTypeSelected.accept(activities[index - 1].id)
            }
        }
    }
    
    func showAreas(areas: [PickerModel]) {
        ActionSheet.show(title: "_select_area", cancelTitle: "Cancel", otherTitles: areas.map({ $0.name }), sender: cityTF) { [weak self] index in
            guard let self = self else { return }
            if index != 0 {
                self.cityTF.text = areas[index - 1].name
                self.viewModel.areaId.accept(areas[index - 1].id)
            }
        }
    }
    
    // MARK: - Actions
    @IBAction func saveChangesClicked(_ sender: UIButton) {
        viewModel.updateProfile()
    }
    
    @IBAction func changeUserImage(_ sender: UIButton) {
        ImagePicker.pickImage(sender: profilePic) { [weak self] image in
            guard let self = self, let image = image else { return }
            self.viewModel.image.accept(image)
            self.profilePic.image = image
        }
    }
    
}

extension EditProfileViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == cityTF {
            viewModel.loadAreas()
        } else if textField == activityTypeTF {
            viewModel.loadActivityTypes()
        }
        return false
    }
}
