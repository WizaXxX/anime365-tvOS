//
//  Session.swift
//  anime365-tvOS
//
//  Created by Илья Козырев on 12.08.2022.
//

import Foundation
import SwiftKeychainWrapper

class Session {
    private init() {
        self.settings = SessionSettings()
    }
    
    static let instance = Session()
    
    var sessionId: String = ""
    var userId: String = ""
    var settings: SessionSettings
    
    func getKeyChainWrapper() -> KeychainWrapper {
        return KeychainWrapper(
            serviceName: "anime365",
            accessGroup: "T485BBUDS7.wizaxxx.anime365-tvOS")
    }
    
}
