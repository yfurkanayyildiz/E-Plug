//
//  mainVC.swift
//  FirebaseAutentication
//
//  Created by Yusuf Furkan Ayyıldız on 2.05.2024.
//

import Foundation
import UIKit

class mainVC: UIViewController {
    
    var infoPanel: UILabel!
    var switchControl: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Arayüz öğelerini oluştur
        createInfoPanel()
        createSwitchControl()
    }
    
    func createInfoPanel() {
        infoPanel = UILabel(frame: CGRect(x: 50, y: 100, width: 300, height: 50))
        infoPanel.text = "Burada bilgi gösteriliyor."
        infoPanel.textAlignment = .center
        infoPanel.backgroundColor = .lightGray
        infoPanel.layer.cornerRadius = 10
        infoPanel.clipsToBounds = true
        self.view.addSubview(infoPanel)
    }
    
    func createSwitchControl() {
        switchControl = UISwitch(frame: CGRect(x: 150, y: 200, width: 0, height: 0))
        switchControl.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
        self.view.addSubview(switchControl)
    }
    
    @objc func switchValueChanged(_ sender: UISwitch) {
        if sender.isOn {
            infoPanel.isHidden = false
        } else {
            infoPanel.isHidden = true
        }
    }
}
