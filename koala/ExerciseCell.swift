//
//  ExerciseCell.swift
//  KoalaCalendar
//
//  Created by Adrian Pearl on 9/20/15.
//  Copyright © 2015 Adrian Pearl. All rights reserved.
//

import UIKit

public class ExerciseCell: UITableViewCell {
    
//    @IBOutlet weak var exerciseName: UILabel! {
//        didSet {
//        }
//    }
//    
//    @IBOutlet weak var exerciseDescription: UILabel! {
//        didSet {
//        }
//    }
    
    weak var exerciseName: UILabel!
    weak var exerciseDescription: UILabel!
    
    public var cellColor = UIColor() {
        didSet {
            setNeedsDisplay()
        }
    }
    // public var identifier: String = "Exercise Cell"
    
    var exercise: koalaExercise? {
        didSet {
            // print("[DEBUG] cell exercise: \(exercise)")
            textLabel?.text = exercise?.exerciseName ?? ""
            detailTextLabel?.text = exercise?.exerciseDescription() ?? ""
//          exerciseName.text = exercise!.exerciseName
//          exerciseDescription.text = exercise!.description()
        }
    }
//    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCellStyle.Subtitle, reuseIdentifier: reuseIdentifier)
        textLabel?.font = UIFont(name: "Lato-Light", size: 36)
        textLabel?.textColor = UIColor(red: 52 / 255, green: 59 / 255, blue: 74 / 255, alpha: 1.0)
        detailTextLabel?.font = UIFont(name: "Lato-Medium", size: 16)
        detailTextLabel?.textColor = UIColor.grayColor()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
//        exerciseName = UILabel(frame: CGRect(origin: CGPoint(x: self.bounds.size.width / 10.0, y: self.bounds.size.height * 0.2), size: CGSizeMake(self.bounds.size.width * 0.85, self.bounds.size.height * 0.4)))
//        exerciseDescription = UILabel(frame: CGRect(origin: CGPoint(x: self.bounds.size.width / 10.0, y: self.bounds.size.height * 0.7), size: CGSizeMake(self.bounds.size.width * 0.85, self.bounds.size.height * 0.2)))
//        
//        self.addSubview(exerciseName)
//        self.addSubview(exerciseDescription)
        // Initialization code
    }

    override public func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func markerBezierPath() -> UIBezierPath {
        let path = UIBezierPath()
        path.moveToPoint(self.bounds.origin)
        path.addLineToPoint(CGPoint(x: self.bounds.origin.x, y: self.bounds.size.height))
        path.addLineToPoint(CGPoint(x: self.bounds.size.width/50, y: self.bounds.size.height))
        path.addLineToPoint(CGPoint(x: self.bounds.size.width/50, y: self.bounds.origin.y))
        path.closePath()
        return path
    }
    
    public override func drawRect(rect: CGRect) {
        let markerPath = markerBezierPath()
        markerPath.lineWidth = 1
        cellColor.setFill()
        markerPath.fill()
    }

}
