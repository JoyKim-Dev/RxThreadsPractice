//
//  UserDefaultManager.swift
//  SeSACRxThreads
//
//  Created by Joy Kim on 8/8/24.
//

import Foundation

class UserDefaultManager {
    static let shared = UserDefaultManager()

    private init() {}
    
    func isItemChecked(_ itemName: String) -> Bool {
            return UserDefaults.standard.bool(forKey: "\(itemName)_checked")
        }
        
        func setItemChecked(_ itemName: String, checked: Bool) {
            UserDefaults.standard.set(checked, forKey: "\(itemName)_checked")
        }
        
        func isItemFavorite(_ itemName: String) -> Bool {
            return UserDefaults.standard.bool(forKey: "\(itemName)_favorite")
        }
        
        func setItemFavorite(_ itemName: String, favorite: Bool) {
            UserDefaults.standard.set(favorite, forKey: "\(itemName)_favorite")
        }
}
