//
//  PieChartView.swift
//  
//
//  Created by Adrian Pearl on 8/4/15.
//
//

import UIKit

public class PieChartView: UICollectionViewCell {
    
    var workout: koalaWorkout! {
        didSet {
            updateUI()
        }
    }
    
    private struct Constants {
        static let noWorkoutGrey = koalaWorkout.exerciseColors[koalaWorkout.typeOfExercise.None]
    }
    
    override public var selected: Bool {
        didSet {
            if selected == true {
                // print("[DEBUG] just got selected :)")
                UIView.animateWithDuration(100, delay: 0, options: .CurveLinear, animations: {
                    self.backgroundColor = Constants.noWorkoutGrey
                    self.label.backgroundColor = Constants.noWorkoutGrey
                }, completion: nil)
            } else {
                self.backgroundColor = UIColor(red: 0.94, green: 0.94, blue: 0.94, alpha: 1.0)
                self.label.backgroundColor = UIColor(red: 0.94, green: 0.94, blue: 0.94, alpha: 1.0)
            }
        }
    }
    
    private var currentAngle: CGFloat = 0
    private var scale: CGFloat {
        get {
            return 0.65
        }
    }
    private let formatter = NSDateFormatter()
    private let label = UILabel()
    
    var chartRadius: CGFloat {
        get {
            return min(bounds.size.width, bounds.size.height) / 2 * scale
        }
    }
    
    var chartCenter: CGPoint {
        get {
            let viewCenter = convertPoint(center, fromView: superview)
            return CGPoint(x: viewCenter.x, y: bounds.size.height - chartRadius * 1.2)
        }
    }
    
    private func exerciseColor (exercise: koalaExercise) -> UIColor {
        return koalaWorkout.exerciseColors[koalaWorkout.knownExercises[exercise.exerciseName]!]!
    }
    
    func updateUI() {
        formatter.dateFormat = "E dd"
        label.frame = CGRect(x: 0, y: self.contentView.bounds.size.height / 15, width: self.contentView.bounds.size.width, height: self.contentView.bounds.size.height / 5)
        label.textAlignment = .Center
        label.font = UIFont(name: "Lato-Light", size: 14)
        label.text = formatter.stringFromDate(workout.dateOfWorkout).lowercaseString
        label.backgroundColor = UIColor(red: 0.94, green: 0.94, blue: 0.94, alpha: 1.0)
        self.contentView.addSubview(label)
        currentAngle = 0
        setNeedsDisplay()
    }
    
    private func noWorkoutBezierPath() -> UIBezierPath {
        let path = UIBezierPath()
        path.addArcWithCenter(chartCenter, radius: chartRadius, startAngle: 0, endAngle: CGFloat(2*M_PI), clockwise: true)
        path.closePath()
        return path
    }
    
    // sorts through the exercises in a workout and calculates the total duration of each exercise type (arms, legs, cardio, etc...)
    // this is necessary to make ensure that a pie chart cell has at most one slice for each color
    private func exerciseTypeDurations (aWorkout: koalaWorkout) -> [UIColor:Double] {
        var returnDict = [UIColor:Double]()
        for exercise in aWorkout.exercises {
            let color = exerciseColor(exercise)
            if returnDict[color] != nil {
                returnDict[color]! += exercise.duration
            } else { returnDict[color] = exercise.duration }
        }
        return returnDict
    }
    
    private func bezierPathForSlice (sliceDuration: Double) -> UIBezierPath {
        let arcAngle = CGFloat(2 * M_PI * sliceDuration / workout.duration)
        let path = UIBezierPath()
        path.addArcWithCenter(chartCenter, radius: chartRadius, startAngle: currentAngle, endAngle: currentAngle + arcAngle, clockwise: true)
        path.addLineToPoint(chartCenter)
        path.closePath()
        currentAngle += arcAngle
        return path
    }
    
    override public func drawRect(rect: CGRect) {
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .ShortStyle
        // let dateString = formatter.stringFromDate(workout!.dateOfWorkout)
        Constants.noWorkoutGrey!.setFill()
        noWorkoutBezierPath().fill()
        for (color, minutes) in exerciseTypeDurations(workout) {
            let smilePath = bezierPathForSlice(minutes)
            smilePath.lineWidth = 2
            color.setFill()
            smilePath.fill()
        }
    }
    
}

public class DashboardPieChart: PieChartView {
    
    override func noWorkoutBezierPath() -> UIBezierPath {
        let path = UIBezierPath()
        path.addArcWithCenter(chartCenter, radius: chartRadius, startAngle: 0, endAngle: CGFloat(2*M_PI), clockwise: true)
        path.addArcWithCenter(chartCenter, radius: chartRadius * 0.58, startAngle: 0, endAngle: CGFloat(2*M_PI), clockwise: true)
        path.closePath()
        path.addClip()
        path.usesEvenOddFillRule = true;
        return path
    }
    
    override func bezierPathForSlice(sliceDuration: Double) -> UIBezierPath {
        let arcAngle = CGFloat(2 * M_PI * sliceDuration / workout.duration)
        let path = UIBezierPath()
        path.addArcWithCenter(chartCenter, radius: chartRadius * 0.93, startAngle: currentAngle, endAngle: currentAngle + arcAngle, clockwise: true)
        path.addLineToPoint(chartCenter.radialPoint(chartRadius * 0.65, angle: currentAngle + arcAngle - CGFloat(M_PI / 2)))
        path.addArcWithCenter(chartCenter, radius: chartRadius * 0.65, startAngle: currentAngle + arcAngle, endAngle: currentAngle, clockwise: false)
        path.closePath()
        currentAngle += arcAngle
        return path
    }
    
    override var scale: CGFloat {
        get {
            return 0.85
        }
    }
    
    override var chartCenter: CGPoint {
        get {
            let viewCenter = convertPoint(center, fromView: superview)
            return CGPoint(x: viewCenter.x, y: viewCenter.y)
        }
    }
    
    
}

extension CGPoint {
    
    // angle in radians!!!
    func radialPoint(radius: CGFloat, angle: CGFloat) -> CGPoint {
        let deltax = radius*sin(angle)
        let deltay = radius*cos(angle)
        return CGPoint(x: self.x + deltax, y: self.y + deltay)
        
    }
}
