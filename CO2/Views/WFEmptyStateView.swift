//
//  WFFavoritesEmptyStateView.swift
//  WaitersFriend
//
//  Created by Simon Italia on 3/2/20.
//  Copyright © 2020 SDI Group Inc. All rights reserved.
//

import UIKit

class WFEmptyStateView: UIView {

    //UI elements contained within UIView
    let label = UILabel()
    let imageView = UIImageView()
    
    
    //MARK: - UIView object initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLabel()
        configureImageView()
    }
    
    //required init
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Custom initializer and customizations
    init(labelText: String) {
        super.init(frame: .zero)
        label.text = labelText
        configureLabel()
        configureImageView()
    }
    
    
    private func configureLabel() {
        addSubview(label)
        label.numberOfLines = 0
        label.textColor = .white
        label.font = UIFont.preferredFont(forTextStyle: .title2)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -175),
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 40),
            label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -40),
            label.heightAnchor.constraint(equalToConstant: 200),
        ])
    }
    
    
    private func configureImageView() {
        addSubview(imageView)
        imageView.image = UIImage(named: "KamikazeCocktail")
        imageView.alpha = 0.25
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1.3),
            imageView.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1.3),
            imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 170),
            imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 40),
        ])
    }
}
