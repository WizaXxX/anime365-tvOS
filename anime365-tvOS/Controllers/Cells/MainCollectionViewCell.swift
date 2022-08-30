//
//  MainViewCell.swift
//  anime365-tvOS
//
//  Created by Илья Козырев on 18.08.2022.
//

import Foundation
import ParallaxView

class MainCollectionViewCell: ParallaxCollectionViewCell {
    
    let scale = 0.9
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
                
        parallaxViewActions.setupUnfocusedState = { [weak self] (view) in
            guard let _self = self else { return }
            view.transform = CGAffineTransform(scaleX: _self.scale, y: _self.scale)
            
            view.layer.shadowOffset = CGSize(width: 0, height: _self.bounds.height * 0.015)
            view.layer.shadowRadius = 5
        }

        parallaxViewActions.setupFocusedState = { [weak self] (view) in
            guard let _self = self else { return }
            view.transform = .identity
            
            view.layer.shadowOffset = CGSize(width: 0, height: _self.bounds.height * 0.02)
            view.layer.shadowRadius = 15
        }
    }
        
    func configure() {
        transform = CGAffineTransform(scaleX: scale, y: scale)
        
        layer.cornerRadius = 15
        clipsToBounds = true
    }    
}
