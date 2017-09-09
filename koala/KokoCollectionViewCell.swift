//
//  KokoCollectionViewCell.swift
//  UIStuff
//
//  Created by Adrian Pearl on 12/18/15.
//  Copyright © 2015 Adrian Pearl. All rights reserved.
//

import UIKit

class KokoCollectionViewCell: UICollectionViewCell {
    
    let workoutStatusView = StatusLabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
        self.backgroundColor = UIColor.clearColor()
        workoutStatusView.frame = CGRect(origin: CGPointZero, size: self.frame.size)
        // self.contentView.addSubview(workoutStatusView)
    }
    
    override func drawRect(rect: CGRect) {
        self.contentView.addSubview(workoutStatusView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
