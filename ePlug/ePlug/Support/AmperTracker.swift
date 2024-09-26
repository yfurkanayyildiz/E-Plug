//
//  AmperTracker.swift
//  ePlug
//
//  Created by Yusuf Furkan Ayyıldız on 12.06.2024.
//

import Foundation
import FirebaseFirestore

class AmperTracker {
    var dailyTotalAmper: Int = 0
    let db = Firestore.firestore()

    func addAmperValue(value: Int) {
        print("value = \(value)")
        dailyTotalAmper += value
        print("dailyTotalAmper = \(dailyTotalAmper)")
    }

    func resetDailyTotal() {
        dailyTotalAmper = 0
    }

    func saveDailyTotalToFirestore(deviceId: String, date: String, devicesamper: Int) {
        let data: [String: Any] = ["totalAmper": devicesamper, "date": date]
        db.collection("devices").document(deviceId).collection("dailyAmperData").document(date).setData(data) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
}
