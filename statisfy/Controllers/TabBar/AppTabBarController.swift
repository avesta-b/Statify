//
//  AppDestinationController.swift
//  statisfy-spotify-ios
//
//  Created by Avesta Barzegar on 2021-03-26.
//

import UIKit

class AppTabBarController: UITabBarController {
    
    // MARK: - Init Views
    
    private lazy var tabBars: [UITabBarItem] = {
        var arr = [UITabBarItem]()
        
        let tabBarInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
        
        let trackItem = UITabBarItem(title: "Tracks", image: UIImage(systemName: "music.note.house"), selectedImage: UIImage(systemName: "music.note.house.fill"))
        
        let artistItem = UITabBarItem(title: "Artists", image: UIImage(systemName: "person.3"), selectedImage: UIImage(systemName: "person.3.fill"))
        
        let recentItem = UITabBarItem(title: "Recent", image: UIImage(systemName: "clock"), selectedImage: UIImage(systemName: "clock.fill"))
        
        let settingsItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gearshape"), selectedImage: UIImage(systemName: "gearshape.fill"))
        
        arr.append(trackItem)
        arr.append(artistItem)
        arr.append(recentItem)
        arr.append(settingsItem)
        return arr
        
    }()
    
    private lazy var tabViewControllers: [UIViewController] = {
        var arr = [UIViewController]()
        
        let firstVC = TrackViewController()
        firstVC.tabBarItem = tabBars[0]
        
        let secondVC = ArtistViewController()
        secondVC.tabBarItem = tabBars[1]
        
        let thirdVC = RecentViewController()
        thirdVC.tabBarItem = tabBars[2]
        
        let fourthVC = SettingsViewController()
        fourthVC.tabBarItem = tabBars[3]
        
        arr.append(firstVC)
        arr.append(secondVC)
        arr.append(thirdVC)
        arr.append(fourthVC)
        return arr
    }()
    
    // MARK: - Layout Views
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    private func setupUI() {
        self.viewControllers = tabViewControllers
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshAuth()
        
    }
    
    
    deinit {
        print("deinit App TabBar")
    }
    
    func refreshAuth() {
        TokenManager.shared.refreshToken(completion: { [weak self] _ in
            print("refreshed token")
            DispatchQueue.main.async {
                self?.setupUI()
            }
        })
    }
}
