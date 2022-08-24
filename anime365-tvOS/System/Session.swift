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
    var sessionDataName: String = ""
    var sessionDataValue: String = ""
    var settings: SessionSettings
    
    private static let sessionIdKeyName = "sessionId"
    private static let userIdKeyName = "userId"
    private static let sessionDataNameName = "sessionDataName"
    private static let sessionDataValueName = "sessionDataValue"
    
    private static func getKeyChainWrapper() -> KeychainWrapper {
        return KeychainWrapper(
            serviceName: "anime365",
            accessGroup: "T485BBUDS7.wizaxxx.anime365-tvOS")
    }
    
    static func getSessionData() -> SessionData? {
        let wrapper = getKeyChainWrapper()
        
        guard let sessionId = wrapper.string(forKey: sessionIdKeyName) else { return nil }
        if sessionId.isEmpty { return nil }
        
        guard let sessionDataName = wrapper.string(forKey: sessionDataNameName) else { return nil }
        if sessionDataName.isEmpty { return nil }
        
        guard let sessionDataValue = wrapper.string(forKey: sessionDataValueName) else { return nil }
        if sessionDataValue.isEmpty { return nil }
        
        guard let userId = wrapper.string(forKey: userIdKeyName) else { return nil }
        
        return SessionData(
            sessionId: sessionId,
            userId: userId,
            sessionDataName: sessionDataName,
            sessionDataValue: sessionDataValue)
    }
    
    static func setSessionData(sessionData: SessionData) {
        Session.instance.sessionId = sessionData.sessionId
        Session.instance.userId = sessionData.userId
        Session.instance.sessionDataName = sessionData.sessionDataName
        Session.instance.sessionDataValue = sessionData.sessionDataValue
    }
    
    static func saveSessionData(sessionData: SessionData) {
        let wrapper = getKeyChainWrapper()
        wrapper.set(sessionData.sessionId, forKey: sessionIdKeyName)
        wrapper.set(sessionData.userId, forKey: userIdKeyName)
        wrapper.set(sessionData.sessionDataName, forKey: sessionDataNameName)
        wrapper.set(sessionData.sessionDataValue, forKey: sessionDataValueName)
    }
    
}
