//
//  CalendarBrain.swift
//  KoalaCalendar
//
//  Created by Adrian Pearl on 9/20/15.
//  Copyright © 2015 Adrian Pearl. All rights reserved.
//

import UIKit

public let window = UIWindow(frame: UIScreen.mainScreen().bounds)

public class koalaExercise { // base class
    
    // static let calendar = NSCalendar.currentCalendar()
    // static let formatter = NSDateFormatter()
    var startTime: NSDate
    var endTime: NSDate? = nil
    
    public var exerciseName: String
    public var timeIntervals = [Float]() // intervals (in seconds) between either revolutions (for a cardio machine) or reps (weight machine)
    public var timeStatistics = [Int]() // incline of each revolution (treadmill), weight of each rep (weight machine), or nothing (stairmaster)
    private var data = String()
    
    var duration: Double {
        get {
            return endTime != nil ? Double((endTime!.timeIntervalSinceDate(startTime))) : 0
        }
    }
    
    public func printStats() {
        print("[DEBUG] exercise: \(exerciseName)")
        print("[DEBUG] start time: \(startTime)")
        print("[DEBUG] duration: \(duration)")
        print("[DEBUG] end time: \(endTime)")
        print("[DEBUG] \(self.timeIntervals)")
        print("[DEBUG] \(self.timeStatistics)")
    }
    
    public init(name: String, start: NSDate) {
        exerciseName = name
        startTime = start
    }
    
    public init(name: String, start: NSDate, duration: Int, intervals: [Float], stats: [Int]) {
        startTime = start
        exerciseName = name
        endTime = NSCalendar.currentCalendar().dateByAddingUnit([.Minute], value: duration, toDate: start, options: [])!
        timeIntervals = intervals
        timeStatistics = stats
    }
    
    public convenience init(name: String, start: NSDate, end: NSDate, intervals: [Float], stats: [Int]) {
        self.init(name: name, start: start)
        endTime = end
        timeIntervals = intervals
        timeStatistics = stats
    }
    
    public static func classify(name: String, time: NSDate, data: [Int8]) -> koalaExercise {
        let type = koalaWorkout.knownExercises[name]!
        var ints = [Float]()
        var stats = [Int]()
        for byte in data {
            let timeInt = Float(byte >> 2) / 10.0
            let weightCode = byte & 0b00000011
            let timeStat: Int = (Int(weightCode) + 1)*10
            ints.append(timeInt)
            stats.append(timeStat)
        }
        let dur = Int(ints.reduce(0, combine: +) - ints[0])
        let start = NSDate(timeInterval: -Double(dur), sinceDate: time)
        
        switch type {
        case .Cardio:
            return TreadmillExercise(start: start, duration: dur, revDistance: 12.0, intervals: ints, stats: stats)
        default:
            return StackweightExercise(name: name, start: start, duration: dur, intervals: ints, stats: stats)
        }
        
    }
    
    func exerciseDescription() -> String {
        return ""
    }
    
    func addData(newData: String) {
        data += newData
    }
}



public class TreadmillExercise: koalaExercise {
    
    private var distancePerRevolution: Float = 0 // in feet
    
    var speeds: [Float] { // in mph
        get {
            var diffs = [Float]()
            diffs.append(timeIntervals[0])
            for index in 1...(timeIntervals.count - 1) {
                diffs.append(timeIntervals[index] - timeIntervals[index - 1])
            }
            return diffs
        }
    }
    
    var elevation: Float { // in same units as distancePerRevolution
        get {
            let radians = timeStatistics.map { Float($0) * Float(M_PI) / 180 }
            let unrounded = radians.reduce(0) { sin($0) + sin($1) }
            return (unrounded*distancePerRevolution).roundDouble(2)
        }
    }
    
    var totalDistance: Float { // in same units as distancePerRevolution
        get {
            let unrounded = distancePerRevolution*Float(timeIntervals.count) / 5280.0
            return unrounded.roundDouble(2)
        }
    }
    
    public init(start: NSDate, duration: Int, revDistance: Float, intervals: [Float], stats: [Int]) {
        super.init(name: "Treadmill", start: start, duration: duration, intervals: intervals, stats: stats)
    }
    
    public init(timeOfExercise: NSDate) {
        super.init(name: "Treadmill", start: timeOfExercise)
    }
    
    override func exerciseDescription() -> String {
        return ("\(stringFromTimeInterval(duration)), \(totalDistance) miles, \(elevation) feet climbed")
    }
    
}

public class StackweightExercise: koalaExercise {
    
    private let weightVoltages: [Int] = [512, 465, 426, 393, 365, 341, 320, 301, 284, 269, 256, 243, 232, 222, 213, 204, 196, 189, 182, 176, 170]
    
    public init(nameOfExercise: String, timeOfExercise: NSDate, repInts: [Float], machineWeights: [Int], exerciseVoltages: [Int]) {
        super.init(name: nameOfExercise, start: timeOfExercise)
        timeIntervals = repInts
        for voltage in exerciseVoltages {
            let differences = weightVoltages.map { abs($0 - voltage) }
            timeStatistics.append(machineWeights[differences.findIndex { $0 == differences.minElement()! }!])
            // timeStatistics[i] is now the weight of the ith rep in units of machineWeights
        }
        
    }
    
    public override init(name: String, start: NSDate, duration: Int, intervals: [Float], stats: [Int]) {
        super.init(name: name, start: start, duration: duration, intervals: intervals, stats: stats)
    }
    
    
    public init(nameOfExercise: String, timeOfExercise: NSDate, end: NSDate, repInts: [Float], repWeights: [Int]) {
        super.init(name: nameOfExercise, start: timeOfExercise)
        endTime = end
        timeIntervals = repInts
        timeStatistics = repWeights
    }
    
    var sets: [[Int]] {
        get {
            var array = [[Int]]()
            var subArray: [Int] = [timeStatistics[0]]
            for i in 1...(timeStatistics.count - 1) {
                if timeStatistics[i] != timeStatistics[i-1] {
                    array.append(subArray)
                    subArray = []
                }
                subArray.append(timeStatistics[i])
            }
            array.append(subArray)
            return array
        }
    }
    
    override func exerciseDescription() -> String {
        var returnString = "\(sets.count) sets: "
        for i in 0...(sets.count - 1) {
            let x = sets[i]
            returnString.appendContentsOf("\(x.count) × \(x[0]) lbs, ")
        }
        return returnString
    }
    
}


public class koalaWorkout: NSObject {
    
    public var name: String = ""
    
    private struct colors {
        static let blue: UIColor = UIColor(red: 77 / 255, green: 194 / 255, blue: 228 / 255, alpha: 1.0)
        static let purple: UIColor = UIColor(red: 118 / 255, green: 87 / 255, blue: 249 / 255, alpha: 1.0)
        static let yellow: UIColor = UIColor(red: 235 / 255, green: 194 / 255, blue: 77 / 255, alpha: 1.0)
        static let green: UIColor = UIColor(red: 101 / 255, green: 217 / 255, blue: 152 / 255, alpha: 1.0)
        static let red: UIColor = UIColor(red: 229 / 255, green: 86 / 255, blue: 123 / 255, alpha: 1.0)
        static let pink: UIColor = UIColor(red: 203 / 255, green: 102 / 255, blue: 215 / 255, alpha: 1.0)
        static let noWorkoutGrey: UIColor = UIColor(red: 190 / 255, green: 203 / 255, blue: 219 / 255, alpha: 1.0)
    }
    
    public enum typeOfExercise {
        case Cardio
        case Arms
        case Legs
        case Chest
        case Back
        case None
    }
    
    public let dateOfWorkout: NSDate
    public var exercises = [koalaExercise]()
    public static var knownExercises = [String:typeOfExercise]()
    public static var exerciseColors = [typeOfExercise:UIColor]()
    
    // a computed (not stored) property that is obtained by summing the duration of all the exercises in the workout
    public var duration: Double {
        get {
            let durations = exercises.map { $0.duration }
            return durations.reduce(0, combine: +)
        }
    }
    
    init(date: NSDate) {
        koalaWorkout.knownExercises["Treadmill"] = typeOfExercise.Cardio
        koalaWorkout.knownExercises["Leg Press"] = typeOfExercise.Legs
        koalaWorkout.knownExercises["Chest Press"] = typeOfExercise.Chest
        koalaWorkout.knownExercises["Bicep Curl"] = typeOfExercise.Arms
        koalaWorkout.knownExercises["Upright Row"] = typeOfExercise.Back
        koalaWorkout.knownExercises["No workouts today"] = typeOfExercise.None
        
        koalaWorkout.exerciseColors[typeOfExercise.Cardio] = colors.purple
        koalaWorkout.exerciseColors[typeOfExercise.Arms] = colors.pink
        koalaWorkout.exerciseColors[typeOfExercise.Legs] = colors.green
        koalaWorkout.exerciseColors[typeOfExercise.Chest] = colors.blue
        koalaWorkout.exerciseColors[typeOfExercise.Back] = colors.yellow
        koalaWorkout.exerciseColors[typeOfExercise.None] = colors.noWorkoutGrey
        
        dateOfWorkout = date
    }
    
}

public class noWorkout: koalaWorkout {
    override init(date: NSDate) {
        super.init(date: date)
        let noExercise = koalaExercise(name: "No workouts today", start: date)
        self.exercises.append(noExercise)
    }
}

public class koalaUser {
    
    static public var exerciseInProgress: koalaExercise? = nil
    
    static public var exercises = [koalaExercise]()
    static public var dateJoined = NSDate()
        
    struct PropertyKeys {
        static let nameKey = "name"
        static let joinDateKey = "date"
    }
    
    static public var username: String = ""
    
    private let workoutDateType: NSCalendarUnit = [.Year, .Month, .Day]
    
    
}

// some extensions to make data formatting and other stuff easier


// rounds a double to some integer number of decimal places
extension Float {
    func roundDouble(roundTo: Int) -> Float {
        let converter = NSNumberFormatter()
        let formatter = NSNumberFormatter()
        formatter.numberStyle = NSNumberFormatterStyle.NoStyle
        formatter.minimumFractionDigits = roundTo
        formatter.roundingMode = .RoundDown
        formatter.maximumFractionDigits = roundTo
        if let stringFromDouble =  formatter.stringFromNumber(self) {
            if let doubleFromString = converter.numberFromString( stringFromDouble ) as? Float {
                return doubleFromString
            }
        }
        return 0.0
    }
}


extension SequenceType where Generator.Element : protocol<IntegerArithmeticType> {
    
    func findIndex(predicate: (Generator.Element) -> Bool) -> Int? {
        for (index, element) in enumerate() {
            if predicate(element) {
                return index
            }
        }
        return nil
    }
}


func stringFromTimeInterval(interval: NSTimeInterval) -> String {
    let interval = Int(interval)
    let seconds = interval % 60
    let minutes = (interval / 60) % 60
    let hours = (interval / 3600)
    if (interval < 3600) {
        return String(format: "%02d:%02d", minutes, seconds)
    } else {
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

public extension UIViewController {
    func updateUI() {
        
    }
}