//
//  CloudHelper.swift
//  anime365-tvOS
//
//  Created by Илья Козырев on 05.09.2022.
//

import Foundation
import FirebaseFirestoreSwift
import FirebaseFirestore

class CloudHelper {
    private init(){}
    
    static let shared = CloudHelper()
    
    let db = Firestore.firestore()
    let userCollectionName = "users"
    
    func saveInitData() {
        let data = CloudUserData(
            id: Session.instance.userId,
            settings: CloudUserSettings(comfortTypeOfTranslation: "", showNewEpisodesOnlyWithComfortTypeOfTranslation: false))
        try? db
            .collection(userCollectionName)
            .document(Session.instance.userId)
            .setData(from: data, merge: true)
    }
    
    func getUserData(completion: @escaping ()->()) {
       let ref = db
            .collection(userCollectionName)
            .document(Session.instance.userId)
        ref.getDocument(as: CloudUserData.self) { result in
            switch result {
            case .success(let userData):
                Session.instance.settings = SessionSettings(from: userData)
                completion()
            case.failure(let err):
                print(err)
            }
        }
    }
    
    func saveSettings() {
        let userData = CloudUserData()
        try? db
            .collection(userCollectionName)
            .document(Session.instance.userId)
            .setData(from: userData, merge: true)
    }
    
}
