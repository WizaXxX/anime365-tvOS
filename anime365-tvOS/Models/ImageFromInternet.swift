//
//  ImageFromInternet.swift
//  anime365-tvOS
//
//  Created by Илья Козырев on 14.08.2022.
//

import Foundation
import UIKit
import CryptoKit

struct ImageFromInternet {
    
    init(url: String) {
        self.url = url
        
        let computed = Insecure.MD5.hash(data: url.data(using: .utf8)!)
        self.md5 = computed.map { String(format: "%02hhx", $0) }.joined()
    }
    
    let url: String
    private let md5: String
    
    
    func getImage() -> UIImage {
        
        if let savedImage = getSavedImage() {
            return savedImage
        }
        
        guard let urlImage = URL(string: url) else { return UIImage() }
        guard let imageData = try? Data(contentsOf: urlImage) else { return UIImage() }
        guard let currentImage = UIImage(data: imageData) else { return UIImage() }
        
        saveImage(imageData)
        return currentImage
    }
    
    func getLocalUrl() -> URL? {
        
        getImage()
        guard let dir = try? FileManager.default.url(
            for: .cachesDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false)
        else { return nil }

        return URL(fileURLWithPath: dir.absoluteString).appendingPathComponent(md5)
        
    }
    
    private func getSavedImage() -> UIImage? {

        guard let dir = try? FileManager.default.url(
            for: .cachesDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false)
        else { return nil }
        
        let pathToFile = URL(fileURLWithPath: dir.absoluteString).appendingPathComponent(md5).path
        return UIImage(contentsOfFile: pathToFile)
    }
    
    private func saveImage(_ imageData: Data) {
        guard let dir = try? FileManager.default.url(
            for: .cachesDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false)
        else { return }
        try? imageData.write(to: dir.appendingPathComponent(md5))
    }
    
}
