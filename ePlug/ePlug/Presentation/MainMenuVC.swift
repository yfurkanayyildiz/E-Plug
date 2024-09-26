//
//  MainMenuVC.swift
//  ePlug
//
//  Created by Yusuf Furkan Ayyıldız on 16.04.2024.
//

import UIKit
import Firebase
import FirebaseFirestore
import CoreLocation

class MainMenuVC: UIViewController, CLLocationManagerDelegate {
    var mainMenuLabel: UILabel!
    var plugStatusLabels: [UILabel] = []
    var amperLabels: [UILabel] = []
    var dailyTotalAmperLabels: [UILabel] = []
    var endOfMonthEstimateLabels: [UILabel] = []
    var dailyTotalAmperValues: [Int] = []
    var switchButtons: [UISwitch] = []
    var lightStatus: [Int] = []
    var addSwitchButton: UIButton!
    var logoutButton: UIButton!
    var manualUploadButton: UIButton!
    var verticalStackView: UIStackView!
    var ref: DatabaseReference!
    var switchCounter: Int = 0
    var deviceCounterss = 0
    var amperTracker = AmperTracker()
    var proximityCheckTimer: Timer?
    var wattTimers: [Int: Timer] = [:]
    var timer: Timer?
    var checkAllDevicesTimer: Timer?
    var testVCButton: UIButton!
    var locationManager: CLLocationManager!
    var isFeatureEnabled: Bool = false
    var savedLocation: CLLocation?
    var shouldAddToFirestore = true

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        view.backgroundColor = .white
        
        mainMenuLabel = UILabel()
        mainMenuLabel.text = "Main Menu"
        mainMenuLabel.textAlignment = .center
        mainMenuLabel.font = UIFont.boldSystemFont(ofSize: 20)
        mainMenuLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainMenuLabel)
        
        verticalStackView = UIStackView()
        verticalStackView.axis = .vertical
        verticalStackView.spacing = 40
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(verticalStackView)
        view.addSubview(scrollView)
        
        addSwitchButton = UIButton(type: .system)
        addSwitchButton.setTitle("Cihaz Ekle", for: .normal)
        addSwitchButton.addTarget(self, action: #selector(addSwitchButtonTapped), for: .touchUpInside)
        addSwitchButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(addSwitchButton)
        
        logoutButton = UIButton(type: .system)
        logoutButton.setTitle("Çıkış Yap", for: .normal)
        logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoutButton)
        
        testVCButton = UIButton(type: .system)
        testVCButton.setTitle("TestVC'ye Git", for: .normal)
        testVCButton.addTarget(self, action: #selector(openTestVC), for: .touchUpInside)
        testVCButton.translatesAutoresizingMaskIntoConstraints = false
        testVCButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        view.addSubview(testVCButton)
        
        manualUploadButton = UIButton(type: .system)
        manualUploadButton.setTitle("Manuel Yükleme", for: .normal)
        manualUploadButton.addTarget(self, action: #selector(manualDailyTask), for: .touchUpInside)
        manualUploadButton.translatesAutoresizingMaskIntoConstraints = false
        manualUploadButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        view.addSubview(manualUploadButton)
        
        let locationButton = UIButton(type: .system)
        locationButton.setTitle("Konumu Kaydet", for: .normal)
        locationButton.addTarget(self, action: #selector(saveLocation), for: .touchUpInside)
        locationButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(locationButton)
        
        let featureSwitch = UISwitch()
        featureSwitch.addTarget(self, action: #selector(toggleFeature(_:)), for: .valueChanged)
        featureSwitch.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(featureSwitch)
        
        NSLayoutConstraint.activate([
            mainMenuLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            mainMenuLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            scrollView.topAnchor.constraint(equalTo: mainMenuLabel.bottomAnchor, constant: 20),
            scrollView.bottomAnchor.constraint(equalTo: locationButton.topAnchor, constant: -30),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            verticalStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            verticalStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            verticalStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            verticalStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            verticalStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            addSwitchButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addSwitchButton.topAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 20),
            
            logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),
            
            testVCButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            testVCButton.bottomAnchor.constraint(equalTo: logoutButton.topAnchor, constant: -10),
            testVCButton.widthAnchor.constraint(equalToConstant: 100),
            testVCButton.heightAnchor.constraint(equalToConstant: 30),
            
            manualUploadButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            manualUploadButton.bottomAnchor.constraint(equalTo: logoutButton.topAnchor, constant: -10),
            manualUploadButton.widthAnchor.constraint(equalToConstant: 100),
            manualUploadButton.heightAnchor.constraint(equalToConstant: 30),
            
            locationButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            locationButton.bottomAnchor.constraint(equalTo: testVCButton.topAnchor, constant: -10),
            locationButton.widthAnchor.constraint(equalToConstant: 120),
            locationButton.heightAnchor.constraint(equalToConstant: 30),
            
            featureSwitch.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            featureSwitch.bottomAnchor.constraint(equalTo: manualUploadButton.topAnchor, constant: -10)
        ])
        
        startDailyTimer()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        checkTooMuchWatt()
        
        getDeviceCount { (count, error) in
            if let error = error {
                print("Error fetching device count: \(error)")
            } else {
                print("Number of devices: \(count ?? 0)")
            }
        }
        
        startCheckAllDevicesTimer()
        triggerAddSwitchButtonBasedOnDeviceCount()
    }
    
    @objc func addSwitchButtonTapped() {
        let currentIndex = switchCounter
        
        let plugStatusLabel = UILabel()
        plugStatusLabel.text = "Yeni Cihaz"
        plugStatusLabel.textAlignment = .left
        plugStatusLabel.font = UIFont.systemFont(ofSize: 14)
        plugStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        plugStatusLabels.append(plugStatusLabel)
        
        let amperLabel = UILabel()
        amperLabel.text = "Anlık 0"
        amperLabel.textAlignment = .right
        amperLabel.font = UIFont.systemFont(ofSize: 14)
        amperLabel.translatesAutoresizingMaskIntoConstraints = false
        amperLabels.append(amperLabel)
        
        let dailyTotalAmperLabel = UILabel()
        dailyTotalAmperLabel.text = "Günlük Toplam"
        dailyTotalAmperLabel.textAlignment = .left
        dailyTotalAmperLabel.font = UIFont.systemFont(ofSize: 14)
        dailyTotalAmperLabel.translatesAutoresizingMaskIntoConstraints = false
        dailyTotalAmperLabels.append(dailyTotalAmperLabel)
        dailyTotalAmperValues.append(0)
        
        let endOfMonthEstimateLabel = UILabel()
        endOfMonthEstimateLabel.text = "Tahmini kullanım: "
        endOfMonthEstimateLabel.textAlignment = .center
        endOfMonthEstimateLabel.font = UIFont.systemFont(ofSize: 14)
        endOfMonthEstimateLabel.translatesAutoresizingMaskIntoConstraints = false
        endOfMonthEstimateLabels.append(endOfMonthEstimateLabel)
        
        let switchButton = UISwitch()
        switchButton.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
        switchButton.translatesAutoresizingMaskIntoConstraints = false
        switchButtons.append(switchButton)
        
        let lightStatusValue = lightStatus.count > 0 ? lightStatus.last! + 1 : 1
        lightStatus.append(lightStatusValue)
        
        let horizontalStackView1 = UIStackView(arrangedSubviews: [switchButton, plugStatusLabel, amperLabel])
        horizontalStackView1.axis = .horizontal
        horizontalStackView1.spacing = 5
        horizontalStackView1.distribution = .fill
        horizontalStackView1.translatesAutoresizingMaskIntoConstraints = false
        
        switchButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        plugStatusLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        amperLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        let horizontalStackView2 = UIStackView(arrangedSubviews: [dailyTotalAmperLabel, endOfMonthEstimateLabel])
        horizontalStackView2.axis = .horizontal
        horizontalStackView2.spacing = 10
        horizontalStackView2.distribution = .fillEqually
        horizontalStackView2.translatesAutoresizingMaskIntoConstraints = false
        
        let verticalStackView = UIStackView(arrangedSubviews: [horizontalStackView1, horizontalStackView2])
        verticalStackView.axis = .vertical
        verticalStackView.spacing = 10
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(verticalStackView)
        
        verticalStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10).isActive = true
        verticalStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10).isActive = true
        verticalStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10).isActive = true
        verticalStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10).isActive = true
        
        let separatorView = UIView()
        separatorView.backgroundColor = .lightGray
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorView)
        
        separatorView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        separatorView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        separatorView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        self.verticalStackView.addArrangedSubview(containerView)
        
        observeAmperValue(for: currentIndex)

        let deviceName = "device\(currentIndex)"

        if shouldAddToFirestore {
            addDeviceNameToFirestore(deviceName: deviceName)
            }

        let ref = Database.database().reference().child("devices/\(deviceName)/status")
        ref.observeSingleEvent(of: .value) { snapshot in
            if let status = snapshot.value as? Int {
                print("Firebase'den alınan status: \(status)") 
                if status == 1{
                    switchButton.isOn = true
                    plugStatusLabel.text="Cihaz Açık"
                }else{
                    switchButton.isOn = false
                    plugStatusLabel.text="Cihaz Kapalı"
                }

            } else {
                print("Firebase'den alınan status geçerli değil")
            }
        }
        
        firebaseStatusCheck(deviceName: deviceName, switchButton: switchButton, plugStatusLabel: plugStatusLabel, index: currentIndex)
        
        fetchEndOfMonthEstimate(for: "device\(currentIndex)") { estimate in
            endOfMonthEstimateLabel.text = "Tahmini kullanım: \(estimate)"
        }
        
        switchCounter += 1
    }

    func firebaseStatusCheck(deviceName: String, switchButton: UISwitch, plugStatusLabel: UILabel, index: Int) {
        let ref = Database.database().reference().child("devices/\(deviceName)/status")
        ref.observeSingleEvent(of: .value) { snapshot in
            if let status = snapshot.value as? Int {
                if status == 1 {
                    switchButton.isOn = true
                    plugStatusLabel.text = "Cihaz Açık"
                    self.writeRandomWattData(index: index, lightstatus: 0)
                } else {
                    switchButton.isOn = false
                    plugStatusLabel.text = "Cihaz Kapalı"
                    self.stopWattTimer(index: index)
                }
            } else {
                print("Firebase'den alınan status geçerli değil")
            }
        }
    }

    
    func checkAllDevices(count: Int) {
        for index in 0..<count {
            let deviceName = "device\(index)"
            let switchButton = self.switchButtons[index]
            let plugStatusLabel = self.plugStatusLabels[index]
            
            self.firebaseStatusCheck(deviceName: deviceName, switchButton: switchButton, plugStatusLabel: plugStatusLabel, index: index)
        }
    }
    

    func addDeviceNameToFirestore(deviceName: String) {
        let firestore = Firestore.firestore()
        
        let deviceNameData: [String: Any] = [
            "deviceName": deviceName
        ]
        
        firestore.collection("deviceNames").document(deviceName).setData(deviceNameData) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Document added with ID: \(deviceName)")
            }
        }
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
    
    func observeAmperValue(for index: Int) {
        ref.child("devices/device\(index)/amper").observe(.value, with: { snapshot in
            if let data = snapshot.value as? Int {
                print("Received data for amper\(index): \(data)")
                self.amperTracker.addAmperValue(value: data)
                self.amperLabels[index].text = "Anlık \(data)"
                self.dailyTotalAmperValues[index] += data
                self.updateDailyTotalAmperLabel(for: index)
            } else {
                print("Snapshot does not contain a valid int value for amper\(index)")
            }
        }) { error in
            print("Failed to observe amper\(index): \(error.localizedDescription)")
        }
    }
    
    @objc func switchValueChanged(_ sender: UISwitch) {
        guard let index = switchButtons.firstIndex(of: sender) else { return }
        let lightStatusLabel = plugStatusLabels[index]
        let lightStatusValue = sender.isOn ? 1 : 0
        lightStatus[index] = lightStatusValue
        lightStatusLabel.text = lightStatusValue == 0 ? "Cihaz Kapalı" : "Cihaz Açık"
        
        writeLightStatusToFirebase(index: index, value: lightStatusValue)
        if lightStatusValue == 1 {
            writeRandomWattData(index: index, lightstatus: lightStatusValue)
        }else{
            let value = 0
            stopWattTimer(index: index)
            self.ref.child("devices/device\(index)/amper").setValue(value)
        }
    }
    
    func writeLightStatusToFirebase(index: Int, value: Int) {
        ref.child("devices/device\(index)/status").setValue(value)
    }
    
    func writeRandomWattData(index: Int, lightstatus: Int) {
            stopWattTimer2(index: index)
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            let value = Int.random(in: 8...11)
            self?.ref.child("devices/device\(index)/amper").setValue(value)
        }
        
        wattTimers[index] = timer
    }

    
    func updateDailyTotalAmperLabel(for index: Int) {
        dailyTotalAmperLabels[index].text = "Günlük Toplam \(dailyTotalAmperValues[index]) "
    }
    
    func fetchEndOfMonthEstimate(for deviceId: String, completion: @escaping (Int) -> Void) {
        let db = Firestore.firestore()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM"
        let monthString = dateFormatter.string(from: Date())
        
        db.collection("devices").document(deviceId).collection("monthlyEstimates").document(monthString).getDocument { document, error in
            if let document = document, document.exists {
                if let estimate = document.data()?["estimate"] as? Int {
                    completion(estimate)
                } else {
                    completion(0)
                }
            } else {
                print("Document does not exist")
                completion(0)
            }
        }
    }
    
    func fetchPastDataForMonth(deviceId: String, month: Int, completion: @escaping ([Int]) -> Void) {
        let db = Firestore.firestore()
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        var dataPoints: [Int] = []
        let group = DispatchGroup()
        
        for year in (currentYear - 5)..<currentYear {
            let startDate = "\(year)-\(month < 10 ? "0" : "")\(month)-01"
            let endDate = "\(year)-\(month < 10 ? "0" : "")\(month)-31"
            
            group.enter()
            db.collection("devices").document(deviceId).collection("dailyAmperData")
                .whereField("date", isGreaterThanOrEqualTo: startDate)
                .whereField("date", isLessThanOrEqualTo: endDate)
                .getDocuments { (querySnapshot, error) in
                    if let error = error {
                        print("Error getting documents: \(error)")
                    } else {
                        for document in querySnapshot!.documents {
                            if let totalAmper = document.data()["totalAmper"] as? Int {
                                dataPoints.append(totalAmper)
                            }
                        }
                    }
                    group.leave()
                }
        }
        
        group.notify(queue: .main) {
            print("Fetched data points for month \(month): \(dataPoints)")
            completion(dataPoints)
        }
    }
    
    func calculateEndOfMonthEstimate(deviceId: String, month: Int, completion: @escaping (Int) -> Void) {
        fetchPastDataForMonth(deviceId: deviceId, month: month) { dataPoints in
            let totalAmper = dataPoints.reduce(0, +)
            let estimate = totalAmper / max(dataPoints.count, 1)
            print("Calculated end of month estimate for \(deviceId) for month \(month): \(estimate)")
            completion(estimate)
        }
    }
    
    func saveEndOfMonthEstimate(deviceId: String, month: Int, estimate: Int) {
        let db = Firestore.firestore()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM"
        let monthString = dateFormatter.string(from: Date())
        
        let data: [String: Any] = ["month": monthString, "estimate": estimate]
        db.collection("devices").document(deviceId).collection("monthlyEstimates").document(monthString).setData(data) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Monthly estimate successfully written for \(deviceId) for \(monthString) with estimate: \(estimate)")
            }
        }
    }
    
    @objc func calculateAndSaveEndOfMonthEstimates() {
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: Date())
        
        for deviceId in 0..<switchCounter {
            calculateEndOfMonthEstimate(deviceId: "device\(deviceId)", month: currentMonth) { estimate in
                self.saveEndOfMonthEstimate(deviceId: "device\(deviceId)", month: currentMonth, estimate: estimate)
            }
        }
    }
    
    func startDailyTimer() {
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.hour, .minute, .second], from: Date())
        dateComponents.hour = 0
        dateComponents.minute = 0
        dateComponents.second = 0
        
        if let midnight = calendar.nextDate(after: Date(), matching: dateComponents, matchingPolicy: .nextTime) {
            timer = Timer(fireAt: midnight, interval: 86400, target: self, selector: #selector(dailyTask), userInfo: nil, repeats: true)
            RunLoop.main.add(timer!, forMode: .common)
        }
    }
    
    @objc func dailyTask() {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let today = dateFormatter.string(from: Date())
        
        for (index, totalAmper) in dailyTotalAmperValues.enumerated() {
            amperTracker.saveDailyTotalToFirestore(deviceId: "device\(index)", date: today, devicesamper: dailyTotalAmperValues[index])
            dailyTotalAmperValues[index] = 0
            updateDailyTotalAmperLabel(for: index)
        }
        
        calculateAndSaveEndOfMonthEstimates()
    }
    
    @objc func manualDailyTask() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let today = dateFormatter.string(from: Date())
        
        for (index, totalAmper) in dailyTotalAmperValues.enumerated() {
            amperTracker.saveDailyTotalToFirestore(deviceId: "device\(index)", date: today, devicesamper: dailyTotalAmperValues[index])
            dailyTotalAmperValues[index] = 0
            updateDailyTotalAmperLabel(for: index)
            disableAllDevices()
        }
        
        calculateAndSaveEndOfMonthEstimates()
        print("Manual daily task completed for date: \(today)")
    }
    
    @objc func openTestVC() {
        let testVC = TestVC()
        navigationController?.pushViewController(testVC, animated: true)
        testVC.modalPresentationStyle = .fullScreen
        present(testVC, animated: true, completion: nil)
    }
    
    @objc func logoutButtonTapped() {
        do {
            try Auth.auth().signOut()
            let loginVC = LoginVC()
            loginVC.modalPresentationStyle = .fullScreen
            present(loginVC, animated: true, completion: nil)
        } catch let signOutError as NSError {
            print("Auth sign out hatası: \(signOutError.localizedDescription)")
        }
    }
    
    @objc func saveLocation() {
        locationManager.requestLocation()
        
        //checkAllDevices(count: 5)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                guard let self = self else { return }

                if let currentLocation = self.locationManager.location {
                    self.saveLocationToFirestore(location: currentLocation)
                } else {
                    print("Konum alınamadı.")
                }
            }
    }
    
    @objc func toggleFeature(_ sender: UISwitch) {
        print("toggleFeature first line")
        isFeatureEnabled = sender.isOn
        if isFeatureEnabled{
            startProximityCheckTimer()
        }else{
            stopProximityCheckTimer()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            savedLocation = location
            print("Location updated: \(location)")        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error)")
    }
    
    func saveLocationToFirestore(location: CLLocation) {
        let db = Firestore.firestore()
        let data: [String: Any] = [
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude,
            "timestamp": Timestamp(date: Date())
        ]
        db.collection("locations").document("Location").setData(data) { error in
            if let error = error {
                print("Error saving location: \(error)")
            } else {
                print("Location successfully saved")
            }
        }
    }

    
    func checkTooMuchWatt() {
        getDeviceCount { (count, error) in
            if let error = error {
                print("Error fetching device count: \(error)")
                return
            }
            
            guard let devicesCount = count else {
                print("Device count is nil.")
                return
            }
            let calendar = Calendar.current
            let month = calendar.component(.month, from: Date())
            print("month = \(month)")

            let devicesCollection = Firestore.firestore().collection("devices")
            let deviceDocument = devicesCollection.document("deviceID")
            
            if devicesCount == 0 {
                print("totalAmperSum = 0")
            } else {
                let dispatchGroup = DispatchGroup()
                var allWatt = 0

                for i in 0..<devicesCount {
                    let deviceId = "device\(i)"

                    dispatchGroup.enter()
                    self.fetchTotalAmperForMonth(month: month, deviceId: deviceId) { totalAmperSum in
                        allWatt += totalAmperSum
                        dispatchGroup.leave()
                    }
                }

                dispatchGroup.notify(queue: .main) {
                    print("\(month). ay için toplam amper: \(allWatt)")
                    
                    let threshold = 1000
                    
                    if allWatt > threshold {
                        self.showAlert()
                    }
                }
            }
        }
    }


    
    func showAlert() {
        let alertController = UIAlertController(title: "Uyarı", message: "Toplam watt belirlenen eşiği aştı. Ne yapmak istersiniz?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Yoksay", style: .cancel, handler: nil)
        
        let closeAllDevicesAction = UIAlertAction(title: "Tüm Cihazları Kapat", style: .destructive) { _ in
            self.disableAllDevices()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(closeAllDevicesAction)
        
        present(alertController, animated: true, completion: nil)
    }

    
    func fetchTotalAmperForMonth(month: Int, deviceId: String, completion: @escaping (Int) -> Void) {
        let db = Firestore.firestore()
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        var totalAmperSum = 0
        let group = DispatchGroup()
        
        let year = currentYear
        let startDate = "\(year)-\(month < 10 ? "0" : "")\(month)-01"
        let endDate = "\(year)-\(month < 10 ? "0" : "")\(month)-31"
        
        group.enter()
        db.collection("devices").document(deviceId).collection("dailyAmperData")
            .whereField("date", isGreaterThanOrEqualTo: startDate)
            .whereField("date", isLessThanOrEqualTo: endDate)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    for document in querySnapshot!.documents {
                        if let totalAmper = document.data()["totalAmper"] as? Int {
                            totalAmperSum += totalAmper
                        }
                    }
                }
                group.leave()
            }
        
        group.notify(queue: .main) {
            print("Toplam amper değeri: \(totalAmperSum)")
            completion(totalAmperSum)
        }
    }
    
    func fetchSavedLocation(completion: @escaping (CLLocation?) -> Void) {
        print("fetchSavedLocation first line")
        let db = Firestore.firestore()
        let docRef = db.collection("locations").document("Location")
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if let data = document.data(),
                   let latitude = data["latitude"] as? CLLocationDegrees,
                   let longitude = data["longitude"] as? CLLocationDegrees {
                    let savedLocation = CLLocation(latitude: latitude, longitude: longitude)
                    print("Fetched saved location: \(savedLocation)")
                    completion(savedLocation)
                } else {
                    print("Failed to parse location data")
                    completion(nil)
                }
            } else {
                print("Document does not exist")
                completion(nil)
            }
        }
    }
    
    
    
    func checkProximityAndDisableDevices() {
        fetchSavedLocation { savedLocation in
            guard let savedLocation = savedLocation else {
                print("No saved location found")
                return
            }
            
            self.locationManager.requestLocation()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [self] in
                if let currentLocation = self.locationManager.location {
                    let distance = currentLocation.distance(from: savedLocation)
                    print("Current location: \(currentLocation), Saved location: \(savedLocation), Distance: \(distance)")
                    if distance > 50 {
                        print("Distance is greater than 50 meters. Disabling all devices.")
                        for index in 0..<switchCounter{
                            self.stopWattTimer(index: index)
                        }
                        
                        self.disableAllDevices()
                    } else {
                        print("Distance is within 50 meters.")
                    }
                } else {
                    print("Current location not available")
                }
            }
        }
    }
    
    func disableAllDevices() {
        print("disableAllDevices Working")
        for switchButton in switchButtons {
            switchButton.isOn = false
        }
        let db = Firestore.firestore()
        for i in 0..<switchCounter {
            writeLightStatusToFirebase(index: i, value: 0)
        }
    }
    
    

        func startProximityCheckTimer() {
            print("startProximityCheckTimer first line")
            stopProximityCheckTimer()

            proximityCheckTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
                self?.checkProximityAndDisableDevices()
            }
        }

        func stopProximityCheckTimer() {
            print("stopProximityCheckTimer first line")
            proximityCheckTimer?.invalidate()
            proximityCheckTimer = nil
        }
    
    func stopWattTimer2(index: Int) {
        if let timer = wattTimers[index] {
            timer.invalidate()
            wattTimers.removeValue(forKey: index)
        }
    }
        
    func stopWattTimer(index: Int) {
        if let timer = wattTimers[index] {
            timer.invalidate()
            wattTimers.removeValue(forKey: index)
            self.amperLabels[index].text = "Anlık 0"
        }
    }
    
    func startCheckAllDevicesTimer() {
        checkAllDevicesTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
    }
    
    @objc func timerFired() {
        getDeviceCount { [weak self] count, error in
            if let error = error {
                print("Error fetching device count: \(error.localizedDescription)")
            } else if let count = count {
                // count değerini kullanarak checkAllDevices fonksiyonunu çağır
                self?.checkAllDevices(count: count)
            }
        }
    }

    
    func triggerAddSwitchButtonBasedOnDeviceCount() {
        shouldAddToFirestore = false
        
        getDeviceCount { [weak self] (count, error) in
            if let error = error {
                print("Error fetching device count: \(error)")
                return
            }
            
            guard let count = count else {
                print("Device count is nil.")
                return
            }
            
            for _ in 0..<count {
                self?.addSwitchButtonTapped()
            }
            
            self?.shouldAddToFirestore = true
        }
    }

}
