//
//  ProfilessVC.swift
//  FirebaseAutentication
//
//  Created by Yusuf Furkan Ayyıldız on 31.08.2024.
//
/*
 //
 //  ProfilessVC.swift
 //  FirebaseAutentication
 //
 //  Created by Yusuf Furkan Ayyıldız on 31.08.2024.
 //

 import Foundation
 import UIKit
 import Firebase

 class ProfilesVC: UIViewController {
     var verticalStackView: UIStackView!
     var scrollView: UIScrollView!
     var addProfileButton: UIButton!
     var profileNameTextField: UITextField!

     override func viewDidLoad() {
         super.viewDidLoad()
         view.backgroundColor = .systemBackground
         setupScrollView()
         setupVerticalStackView()
         setupProfileNameTextFieldAndButton()
     }

     func setupScrollView() {
         scrollView = UIScrollView()
         scrollView.translatesAutoresizingMaskIntoConstraints = false
         scrollView.showsVerticalScrollIndicator = true
         view.addSubview(scrollView)

         NSLayoutConstraint.activate([
             scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
             scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
             scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
             scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100)  // Alt kısmı daha açık bırakıldı
         ])
     }

     func setupVerticalStackView() {
         verticalStackView = UIStackView()
         verticalStackView.axis = .vertical
         verticalStackView.spacing = 20
         verticalStackView.translatesAutoresizingMaskIntoConstraints = false
         scrollView.addSubview(verticalStackView)

         NSLayoutConstraint.activate([
             verticalStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
             verticalStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
             verticalStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
             verticalStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
             verticalStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
         ])
     }

     func setupProfileNameTextFieldAndButton() {
         let container = UIStackView()
         container.axis = .horizontal
         container.distribution = .fillProportionally
         container.alignment = .center
         container.spacing = 10
         container.translatesAutoresizingMaskIntoConstraints = false
         view.addSubview(container)

         NSLayoutConstraint.activate([
             container.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
             container.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
             container.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
             container.heightAnchor.constraint(equalToConstant: 50)
         ])

         profileNameTextField = UITextField()
         profileNameTextField.placeholder = "Enter profile name"
         profileNameTextField.borderStyle = .roundedRect
         container.addArrangedSubview(profileNameTextField)

         addProfileButton = UIButton(type: .system)
         addProfileButton.setTitle("Add Profile", for: .normal)
         container.addArrangedSubview(addProfileButton)
         addProfileButton.addTarget(self, action: #selector(addProfile), for: .touchUpInside)
     }

     @objc func addProfile() {
         guard let profileName = profileNameTextField.text, !profileName.isEmpty else {
             print("Profile name is required")
             return
         }
         let newProfileView = createProfileView(profileName: profileName)
         verticalStackView.addArrangedSubview(newProfileView)
         profileNameTextField.text = ""
     }

     func createProfileView(profileName: String) -> UIView {
         let horizontalScrollView = UIScrollView()
         horizontalScrollView.translatesAutoresizingMaskIntoConstraints = false
         horizontalScrollView.showsHorizontalScrollIndicator = true

         let profileView = UIStackView()
         profileView.axis = .horizontal
         profileView.distribution = .fillProportionally
         profileView.spacing = 10
         profileView.translatesAutoresizingMaskIntoConstraints = false
         profileView.heightAnchor.constraint(equalToConstant: 50).isActive = true

         let nameButton = UIButton(type: .system)
         nameButton.setTitle(profileName, for: .normal)
         nameButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
         nameButton.addTarget(self, action: #selector(profileButtonTapped(_:)), for: .touchUpInside)
         profileView.addArrangedSubview(nameButton)

         getDeviceCount { (count, error) in
             if let error = error {
                 print("Error fetching device count: \(error)")
                 return
             }
             
             guard let count = count else { return }
             
             for i in 0..<count {
                 let checkboxContainer = UIStackView()
                 checkboxContainer.axis = .horizontal
                 checkboxContainer.alignment = .center
                 checkboxContainer.spacing = 2

                 let numberLabel = UILabel()
                 numberLabel.text = "\(i + 1)"
                 numberLabel.font = UIFont.systemFont(ofSize: 12)
                 numberLabel.widthAnchor.constraint(equalToConstant: 15).isActive = true

                 let checkboxButton = UIButton(type: .custom)
                 checkboxButton.setImage(UIImage(systemName: "square"), for: .normal)
                 checkboxButton.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
                 checkboxButton.addTarget(self, action: #selector(self.toggleCheckbox(_:)), for: .touchUpInside)
                 checkboxButton.accessibilityLabel = "device\(i)"
                 checkboxButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
                 checkboxButton.heightAnchor.constraint(equalToConstant: 30).isActive = true

                 checkboxContainer.addArrangedSubview(numberLabel)
                 checkboxContainer.addArrangedSubview(checkboxButton)

                 profileView.addArrangedSubview(checkboxContainer)
             }
         }

         horizontalScrollView.addSubview(profileView)

         NSLayoutConstraint.activate([
             profileView.topAnchor.constraint(equalTo: horizontalScrollView.topAnchor),
             profileView.leadingAnchor.constraint(equalTo: horizontalScrollView.leadingAnchor),
             profileView.trailingAnchor.constraint(equalTo: horizontalScrollView.trailingAnchor),
             profileView.bottomAnchor.constraint(equalTo: horizontalScrollView.bottomAnchor),
             profileView.heightAnchor.constraint(equalTo: horizontalScrollView.heightAnchor)
         ])

         return horizontalScrollView
     }

     @objc func profileButtonTapped(_ sender: UIButton) {
         guard let profileView = sender.superview as? UIStackView else { return }

         for (index, view) in profileView.arrangedSubviews.enumerated() {
             if let checkboxContainer = view as? UIStackView, let checkboxButton = checkboxContainer.arrangedSubviews.last as? UIButton {
                 let status = checkboxButton.isSelected ? 1 : 0
                 let devicePath = "devices/device\(index)/status"
                 updateDeviceStatusInFirebase(devicePath: devicePath, status: status)
             }
         }

         print("Profil butonuna basıldı")
     }

     func updateDeviceStatusInFirebase(devicePath: String, status: Int) {
         let ref = Database.database().reference()
         ref.child(devicePath).setValue(status) { error, _ in
             if let error = error {
                 print("Error updating \(devicePath): \(error.localizedDescription)")
             } else {
                 print("\(devicePath) successfully updated to \(status)")
             }
         }
     }

     @objc func toggleCheckbox(_ sender: UIButton) {
         sender.isSelected.toggle()
     }
     
     func getDeviceCount(completion: @escaping (Int?, Error?) -> Void) {
         let firestore = Firestore.firestore()
         
         firestore.collection("deviceNames").getDocuments { (querySnapshot, error) in
             if let error = error {
                 completion(nil, error)
             } else {
                 let count = querySnapshot?.documents.count ?? 0
                 completion(count, nil)
             }
         }
     }
 }

*/
