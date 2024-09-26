//
//  MainTabBarController.swift
//  ePlug
//
//  Created by Yusuf Furkan Ayyıldız on 31.08.2024.
//

import Foundation
import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let mainMenuVC = MainMenuVC()
        mainMenuVC.tabBarItem = UITabBarItem(title: "Main Menu", image: UIImage(systemName: "house"), tag: 0)

        let testVC = TestVC()
        testVC.tabBarItem = UITabBarItem(title: "Test", image: UIImage(systemName: "pencil"), tag: 1)

        let profilesVC = ProfilesVC()
        profilesVC.tabBarItem = UITabBarItem(title: "Profiles", image: UIImage(systemName: "person.circle"), tag: 2)

        viewControllers = [mainMenuVC, testVC, profilesVC]
    }
}


