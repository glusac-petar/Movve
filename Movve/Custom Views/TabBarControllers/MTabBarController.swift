//
//  MTabBarController.swift
//  Movve
//
//  Created by Petar Glusac on 23.3.21..
//

import UIKit

class MTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UITabBar.appearance().tintColor = .mRed
        viewControllers = [createHomeNavigationController(), createSearchNavigationController(), createFavoritesNavigationController()]
    }
    
    private func createHomeNavigationController() -> UINavigationController {
        let homeVC = MHomeViewController()
        homeVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house.fill"), tag: 0)
        
        return UINavigationController(rootViewController: homeVC)
    }
    
    private func createSearchNavigationController() -> UINavigationController {
        let searchVC = MSearchViewController()
        searchVC.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 1)
        
        return UINavigationController(rootViewController: searchVC)
    }
    
    private func createFavoritesNavigationController() -> UINavigationController {
        let favoritesVC = MFavoritesViewController()
        favoritesVC.title = "Favorites"
        favoritesVC.tabBarItem = UITabBarItem(title: "Favorites", image: UIImage(systemName: "heart.fill"), tag: 2)
        
        return UINavigationController(rootViewController: favoritesVC)
    }

}
