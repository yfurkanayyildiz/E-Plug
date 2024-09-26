//
//  ProfilessVC.swift
//  ePlug
//
//  Created by Yusuf Furkan Ayyıldız on 31.08.2024.
//

import UIKit
import FirebaseFirestore
import FirebaseDatabase

class ProfilesVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var profileNameTextField: UITextField!
    var addProfileButton: UIButton!
    var scrollView: UIScrollView!
    var verticalStackView: UIStackView!
    var selectedDevices: Set<String> = []
    var devicesTableView: UITableView?
    var devices: [String] = []
    var menuView: UIView?
    var mainMenuVC = MainMenuVC()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupScrollView()
        setupProfileCreationFields()
        getDeviceCount { [weak self] count, error in
            if let count = count {
                self?.generateDeviceNames(count: count)
                self?.devicesTableView?.reloadData()
            } else {
                print("Error fetching device count: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
        
        
        loadProfilesFromFirestore()
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
    
    func generateDeviceNames(count: Int) {
        devices = (0..<count).map { "device\($0)" }
    }
    
    func setupScrollView() {
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        view.addSubview(scrollView)
        
        verticalStackView = UIStackView()
        verticalStackView.axis = .vertical
        verticalStackView.spacing = 20
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(verticalStackView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -200),
            verticalStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            verticalStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            verticalStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            verticalStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    func setupProfileCreationFields() {
        profileNameTextField = UITextField()
        profileNameTextField.placeholder = "Profil İsmini Girin"
        profileNameTextField.borderStyle = .roundedRect
        profileNameTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(profileNameTextField)
        
        let selectDevicesButton = UIButton(type: .system)
        selectDevicesButton.setTitle("Cihaz Seç", for: .normal)
        selectDevicesButton.addTarget(self, action: #selector(showDevicesMenu), for: .touchUpInside)
        selectDevicesButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(selectDevicesButton)
        
        addProfileButton = UIButton(type: .system)
        addProfileButton.setTitle("Profil Ekle", for: .normal)
        addProfileButton.backgroundColor = .systemBlue
        addProfileButton.setTitleColor(.white, for: .normal)
        addProfileButton.layer.cornerRadius = 10
        addProfileButton.addTarget(self, action: #selector(addProfileTapped), for: .touchUpInside)
        addProfileButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(addProfileButton)
        
        NSLayoutConstraint.activate([
            profileNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            profileNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            profileNameTextField.bottomAnchor.constraint(equalTo: selectDevicesButton.topAnchor, constant: -20),
            profileNameTextField.heightAnchor.constraint(equalToConstant: 40),
            
            selectDevicesButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            selectDevicesButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            selectDevicesButton.bottomAnchor.constraint(equalTo: addProfileButton.topAnchor, constant: -20),
            
            addProfileButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addProfileButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addProfileButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            addProfileButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc func showDevicesMenu() {
        if menuView != nil {
            return
        }
        
        menuView = UIView()
        menuView?.backgroundColor = .white
        menuView?.layer.cornerRadius = 10
        menuView?.layer.borderWidth = 1
        menuView?.layer.borderColor = UIColor.lightGray.cgColor
        menuView?.translatesAutoresizingMaskIntoConstraints = false
        
        guard let menuView = menuView else { return }
        
        devicesTableView = UITableView()
        devicesTableView?.delegate = self
        devicesTableView?.dataSource = self
        devicesTableView?.allowsMultipleSelection = true
        devicesTableView?.translatesAutoresizingMaskIntoConstraints = false
        
        menuView.addSubview(devicesTableView!)
        view.addSubview(menuView)
        
        let confirmButton = UIButton(type: .system)
        confirmButton.setTitle("Onayla", for: .normal)
        confirmButton.addTarget(self, action: #selector(hideDevicesMenu), for: .touchUpInside)
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        menuView.addSubview(confirmButton)
        
        NSLayoutConstraint.activate([
            menuView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            menuView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            menuView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            menuView.heightAnchor.constraint(equalToConstant: 300),
            
            devicesTableView!.topAnchor.constraint(equalTo: menuView.topAnchor, constant: 20),
            devicesTableView!.leadingAnchor.constraint(equalTo: menuView.leadingAnchor, constant: 10),
            devicesTableView!.trailingAnchor.constraint(equalTo: menuView.trailingAnchor, constant: -10),
            devicesTableView!.bottomAnchor.constraint(equalTo: confirmButton.topAnchor, constant: -10),
            
            confirmButton.bottomAnchor.constraint(equalTo: menuView.bottomAnchor, constant: -10),
            confirmButton.centerXAnchor.constraint(equalTo: menuView.centerXAnchor)
        ])
    }
    
    @objc func hideDevicesMenu() {
        menuView?.removeFromSuperview()
        menuView = nil
        devicesTableView = nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = devices[indexPath.row]
        
        if selectedDevices.contains(devices[indexPath.row]) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedDevice = devices[indexPath.row]
        
        if selectedDevices.contains(selectedDevice) {
            selectedDevices.remove(selectedDevice)
        } else {
            selectedDevices.insert(selectedDevice)
        }
        
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let deselectedDevice = devices[indexPath.row]
        selectedDevices.remove(deselectedDevice)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    @objc func addProfileTapped() {
        guard let profileName = profileNameTextField.text, !profileName.isEmpty else {
            let alert = UIAlertController(title: "Hata", message: "Profil ismi girmelisiniz.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        let profileButton = UIButton(type: .system)
        profileButton.setTitle("\(profileName)", for: .normal)
        profileButton.backgroundColor = .lightGray
        profileButton.setTitleColor(.black, for: .normal)
        profileButton.layer.cornerRadius = 10
        profileButton.addTarget(self, action: #selector(profileButtonTapped(_:)), for: .touchUpInside)
        
        //firebase e ekleme
        saveProfileToFirestore(profileName: profileName, allDevices: devices, selectedDevices: selectedDevices) { error in
            if let error = error {
                print("Profil Firestore'a kaydedilemedi: \(error.localizedDescription)")
            } else {
                print("Profil başarıyla Firestore'a kaydedildi!")
            }
        }
        
        
        verticalStackView.addArrangedSubview(profileButton)
        profileNameTextField.text = ""
        selectedDevices.removeAll()
    }
    
    /*@objc func profileButtonTapped(_ sender: UIButton) {
     print("Profil butonuna basıldı: \(sender.title(for: .normal) ?? "")")
     }*/
    
    func saveProfileToFirestore(profileName: String, allDevices: [String], selectedDevices: Set<String>, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        
        let profilesCollection = db.collection("Profiles")
        
        profilesCollection.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(error)
                return
            }
            
            let profileCount = querySnapshot?.documents.count ?? 0
            let profileId = "profile\(profileCount)"
            
            var devicesData: [String: Any] = [:]
            
            for device in allDevices {
                let status = selectedDevices.contains(device) ? 1 : 0
                devicesData[device] = ["status": status]
            }
            
            let profileData: [String: Any] = [
                "name": profileName,
                "devices": devicesData
            ]
            
            profilesCollection.document(profileId).setData(profileData) { error in
                completion(error)
            }
        }
    }
    
    func loadProfilesFromFirestore() {
        let db = Firestore.firestore()
        
        // Profiles koleksiyonundan tüm profilleri çekiyoruz
        db.collection("Profiles").getDocuments { [weak self] (querySnapshot, error) in
            if let error = error {
                print("Profil verileri alınamadı: \(error.localizedDescription)")
                return
            }
            
            // ScrollView içindeki mevcut profilleri temizle
            self?.verticalStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            
            // Tüm belgeleri döngü ile alıp profilleri ekliyoruz
            for document in querySnapshot!.documents {
                let profileData = document.data()
                if let profileName = profileData["name"] as? String {
                    // Profil butonunu oluştur
                    let profileButton = UIButton(type: .system)
                    profileButton.setTitle(profileName, for: .normal)
                    profileButton.backgroundColor = .lightGray
                    profileButton.setTitleColor(.black, for: .normal)
                    profileButton.layer.cornerRadius = 10
                    profileButton.addTarget(self, action: #selector(self?.profileButtonTapped(_:)), for: .touchUpInside)
                    
                    // StackView'a profil butonunu ekle
                    self?.verticalStackView.addArrangedSubview(profileButton)
                }
            }
        }
    }
    
    
    @objc func profileButtonTapped(_ sender: UIButton) {
        guard let profileName = sender.title(for: .normal) else { return }
        
        let db = Firestore.firestore()
        
        db.collection("Profiles").whereField("name", isEqualTo: profileName).getDocuments { [weak self] (querySnapshot, error) in
            if let error = error {
                print("Profil verisi alınamadı: \(error.localizedDescription)")
                return
            }
            
            guard let document = querySnapshot?.documents.first else {
                print("Profil bulunamadı")
                return
            }
            
            let profileData = document.data()
            if let devicesData = profileData["devices"] as? [String: [String: Int]] {
                // Cihazların durumlarını Firebase Realtime Database'e yazıyoruz
                self?.updateDevicesInRealtimeDatabase(devicesData: devicesData)
            }
        }
        
        /*DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            print("mainMenuVC.checkAllDevices çalışıyor")
            
        }*/
    }
    
    
    func updateDevicesInRealtimeDatabase(devicesData: [String: [String: Int]]) {
        let ref = Database.database().reference().child("devices")
        
        // Cihazların durumu güncelleniyor
        for (deviceId, deviceInfo) in devicesData {
            if let status = deviceInfo["status"] {
                ref.child(deviceId).child("status").setValue(status) { (error, _) in
                    if let error = error {
                        print("Cihaz durumu güncellenemedi: \(error.localizedDescription)")
                    } else {
                    }
                }
            }
        }
    }
}
