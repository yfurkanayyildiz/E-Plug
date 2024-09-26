//
//  TestVC.swift
//  ePlug
//
//  Created by Yusuf Furkan Ayyıldız on 19.06.2024.
//

import UIKit
import FirebaseFirestore

class TestVC: UIViewController {
    var uploadPastMonthDataButton: UIButton!
    let db = Firestore.firestore()
    var MainMenuVCButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        uploadPastMonthDataButton = UIButton(type: .system)
        uploadPastMonthDataButton.setTitle("Geçmiş Veriyi Yükle", for: .normal)
        uploadPastMonthDataButton.addTarget(self, action: #selector(uploadPastMonthData), for: .touchUpInside)
        uploadPastMonthDataButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(uploadPastMonthDataButton)
        
        MainMenuVCButton = UIButton(type: .system)
        MainMenuVCButton.setTitle("Main Menu'ye Git", for: .normal)
        MainMenuVCButton.addTarget(self, action: #selector(openMainMenuVC), for: .touchUpInside)
        MainMenuVCButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(MainMenuVCButton)
        
        NSLayoutConstraint.activate([
            uploadPastMonthDataButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            uploadPastMonthDataButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            MainMenuVCButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            MainMenuVCButton.bottomAnchor.constraint(equalTo: uploadPastMonthDataButton.topAnchor, constant: -20)
        ])
    }
    
    @objc func uploadPastMonthData() {
        createAndUploadPastYearsData()
    }
    
    func createAndUploadPastYearsData() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let currentDate = Date()
        let calendar = Calendar.current
        
        for i in 0..<(5 * 365) {
            if let pastDate = calendar.date(byAdding: .day, value: -i, to: currentDate) {
                let dateString = dateFormatter.string(from: pastDate)
                let totalAmper = Int.random(in: 100...500)

                saveDailyTotalToFirestore(deviceId: "device0", date: dateString, totalAmper: totalAmper)
            }
        }
    }
    
    @objc func openMainMenuVC(){
        let vc = MainMenuVC()
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    func saveDailyTotalToFirestore(deviceId: String, date: String, totalAmper: Int) {
        let data: [String: Any] = ["totalAmper": totalAmper, "date": date]
        db.collection("devices").document(deviceId).collection("dailyAmperData").document(date).setData(data) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written for \(date)!")
            }
        }
    }
}

