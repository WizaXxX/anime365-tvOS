//
//  Session.swift
//  anime365-tvOS
//
//  Created by Илья Козырев on 12.08.2022.
//

import Foundation
import SwiftKeychainWrapper

class Session {
    private init() {}
    
    static let instance = Session()
    
    var sessionId: String = ""
    var userId: String = ""
    
    func getKeyChainWrapper() -> KeychainWrapper {
        return KeychainWrapper(
            serviceName: "anime365",
            accessGroup: "wizaxxx.anime365-tvOS.keychain")
    }
    
}
