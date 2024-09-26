//
//  Amper Tracker.swift
//  FirebaseAutentication
//
//  Created by Yusuf Furkan Ayyıldız on 12.06.2024.
//

import Foundation
import FirebaseFirestore

class AmperTracker {
    var dailyTotalAmper: Int = 0
    let db = Firestore.firestore()

    func addAmperValue(value: Int) {
        dailyTotalAmper += value
    }

    func resetDailyTotal() {
        dailyTotalAmper = 0
    }

    func saveDailyTotalToFirestore(deviceId: String, date: String) {
        let data: [String: Any] = ["totalAmper": dailyTotalAmper, "date": date]
        db.collection("devices").document(deviceId).collection("dailyAmperData").document(date).setData(data) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
}
