//
//  CalendarViewController.swift
//  KoalaCalendar
//
//  Created by Adrian Pearl on 9/20/15.
//  Copyright © 2015 Adrian Pearl. All rights reserved.
//

import UIKit

class CalendarViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var parent = UIViewController()
    var numberOfDays: Int {
        get {
            return koalaUser.dateJoined.timeBetween(userCalendar, dateType: workoutDateType, otherDate: NSDate()).day + 1
        }
    }
    var future: Bool = false
    
    // var user = koalaUser(name: "apearl3", workoutCalendar: [NSDate : koalaWorkout](), date: NSDate())
    var workoutCalendar = [NSDate:koalaWorkout]()
    var workout = koalaWorkout(date: NSDate()) {
        didSet {
            let entryDirection = future ? UITableViewRowAnimation.Left : UITableViewRowAnimation.Right
            exerciseTable.reloadSections(NSIndexSet(indexesInRange: NSMakeRange(0, exerciseTable.numberOfSections)), withRowAnimation: entryDirection)
        }
    }
    let workoutDateType: NSCalendarUnit = [.Year, .Month, .Day]
    let userCalendar = NSCalendar.currentCalendar()
    
    var workoutsCollection: UICollectionView! {
        didSet {
            workoutsCollection.dataSource = self
            workoutsCollection.delegate = self
            workoutsCollection.bounces = true
            workoutsCollection.allowsMultipleSelection = false
            workoutsCollection.backgroundColor = UIColor(red: 0.94, green: 0.94, blue: 0.94, alpha: 1.0)
            workoutsCollection.translatesAutoresizingMaskIntoConstraints = false
            workoutsCollection.registerClass(PieChartView.self, forCellWithReuseIdentifier: Storyboard.collectionCellResueIdentifier)
            workoutsCollection.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        }
    }
    
    var exerciseTable: UITableView! {
        didSet {
            exerciseTable.dataSource = self
            exerciseTable.delegate = self
            exerciseTable.translatesAutoresizingMaskIntoConstraints = false
            // exerciseTable.backgroundColor = UIColor.blueColor()
            exerciseTable.registerClass(ExerciseCell.self, forCellReuseIdentifier: Storyboard.tableCellReuseIdentifier)
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // print("[DEBUG] row #: \(indexPath.row) ")
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Storyboard.collectionCellResueIdentifier, forIndexPath: indexPath) as! PieChartView
        let dateOfWorkout = userCalendar.dateByAddingUnit([.Day], value: indexPath.row, toDate: koalaUser.dateJoined, options: [])!
        let dayOfWorkout = dateOfWorkout.getDateComponents(userCalendar, dateType: workoutDateType)
        cell.backgroundColor = UIColor(red: 0.94, green: 0.94, blue: 0.94, alpha: 1.0)
        cell.workout = workoutCalendar[dayOfWorkout] ?? noWorkout(date: dayOfWorkout)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // print("[DEBUG] number of rows: \(number)")
        return numberOfDays
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let paths: [NSIndexPath] = collectionView.indexPathsForSelectedItems()!
        for path in paths {
            collectionView.cellForItemAtIndexPath(path)?.selected = false
        }
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! PieChartView
        cell.selected = true
        let pastOrFuture = workout.dateOfWorkout.timeIntervalSinceDate(cell.workout.dateOfWorkout)
        future = (pastOrFuture > 0) ? false : true
        workout = cell.workout
        exerciseTable.reloadData()
        exerciseTable.setNeedsDisplay()
        print("[DEBUG] did select - exercises: \(workout.exercises.count)")

    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        // print("[DEBUG] collection view height: \(workoutsCollection.bounds.size.height)")
        return CGSize(width: self.view.bounds.size.width * 5.0 / 22.0, height: workoutsCollection.bounds.size.height)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0);
    }
    
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        if collectionView.indexPathsForSelectedItems()?.count > 0 {
            let selected = collectionView.indexPathsForSelectedItems()![0]
            return (indexPath == selected) ? false : true
        }
        return true
    }
        
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workout.exercises.count
    }
    
    private struct Storyboard {
        static let tableCellReuseIdentifier = "Exercise Cell"
        static let collectionCellResueIdentifier = "Pie Workout Cell"
        static let koalaMainNavColor = UIColor(red: 65 / 255, green: 131 / 255, blue: 215 / 255, alpha: 1.0)
        static let tableRowHeight: CGFloat = 80
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.tableCellReuseIdentifier, forIndexPath: indexPath) as! ExerciseCell
        // print("[DEBUG] exercises: \(workout.exercises.count)")
        if indexPath.row < workout.exercises.count {
            cell.exercise = workout.exercises[indexPath.row]
            let type = koalaWorkout.knownExercises[(cell.exercise?.exerciseName)!]!
            cell.cellColor = koalaWorkout.exerciseColors[type]!
            if type == .None {
                cell.selectionStyle = .None
            }
        }
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return Storyboard.tableRowHeight
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let e = workout.exercises[indexPath.row]
        print(e.startTime)
        print(e.endTime)
        print(e.timeStatistics)
        print(e.timeIntervals)
    }
    
    func sortExercises_WorkoutsByDate(exercises: [koalaExercise]) -> [NSDate:koalaWorkout] {
        var calendar = [NSDate:koalaWorkout]()
        for exercise in exercises {
            let exerciseDateComponents = userCalendar.components(workoutDateType, fromDate: exercise.startTime)
            let exerciseDate = userCalendar.dateFromComponents(exerciseDateComponents)
            if calendar[exerciseDate!] == nil {
                calendar[exerciseDate!] = koalaWorkout(date: exerciseDate!)
                
            }
            calendar[exerciseDate!]!.exercises.append(exercise)
        }
        return calendar
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = .None
        print("[DEBUG] calendar view did load")
        // let b = UIBarButtonItem(title: "Continue", style: .Plain, target: self, action:nil)
        // self.navigationItem.rightBarButtonItem = b
        // navBar!.titleTextAttributes = [NSFontAttributeName: UIFont(name: "CenturyGothic", size: 25)!, NSForegroundColorAttributeName: UIColor.whiteColor()]
        // navBar!.barStyle = UIBarStyle.Black;
        // navBar!.barTintColor = Storyboard.koalaMainNavColor
        self.navigationItem.title = "calendar"
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        
        // let tabBar = self.tabBarController?.tabBar
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        layout.itemSize = CGSize(width: layout.collectionView.frame.size.width*2/11, height: layout.collectionView.frame.size.height)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
//        workoutsCollection = UICollectionView(frame: CGRect(origin: CGPointZero, size: CGSize(width: 100, height: 100)), collectionViewLayout: layout)
        workoutsCollection = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        
        exerciseTable = UITableView(frame: CGRect(origin: CGPointZero, size: CGSize(width: 100, height: 100)))
        
        let topConstraint = NSLayoutConstraint(item: workoutsCollection, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.topLayoutGuide, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: workoutsCollection, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: exerciseTable, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
        let leftConstraint = NSLayoutConstraint(item: workoutsCollection, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: workoutsCollection, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0)
        
        let widthConstraint = NSLayoutConstraint(item: exerciseTable, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: workoutsCollection, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0)
        let centerConstraint = NSLayoutConstraint(item: exerciseTable, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: workoutsCollection, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        let tableBottomConstraint = NSLayoutConstraint(item: exerciseTable, attribute: NSLayoutAttribute.BottomMargin, relatedBy: NSLayoutRelation.Equal, toItem: self.bottomLayoutGuide, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
        let heightConstraint = NSLayoutConstraint(item: workoutsCollection, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: exerciseTable, attribute: NSLayoutAttribute.Height, multiplier: 0.18, constant: 0)
        
        
        let constraints = [topConstraint, bottomConstraint, leftConstraint, rightConstraint, widthConstraint, centerConstraint, tableBottomConstraint, heightConstraint]
        
        view.addSubview(workoutsCollection)
        view.addSubview(exerciseTable)
        
        NSLayoutConstraint.activateConstraints(constraints)
        // layout.invalidateLayout()
        

        // workoutsCollection.scrollToItemAtIndexPath(NSIndexPath(forRow: numberOfDays, inSection: 1), atScrollPosition: .None, animated: false)
        // ^^^ Can't do this before geometry is set
    }
    
    override func viewWillAppear(animated: Bool) {
        workoutCalendar = sortExercises_WorkoutsByDate(koalaUser.exercises)
        print("[DEBUG] exercises (calendar will appear): \(koalaUser.exercises.count)")
        workoutsCollection.reloadData()
        workoutsCollection.setNeedsDisplay()
    }
    
    override func viewDidAppear(animated: Bool) {
        workoutCalendar = sortExercises_WorkoutsByDate(koalaUser.exercises)
        // workoutsCollection.scrollToItemAtIndexPath(NSIndexPath(forRow: numberOfDays - 1, inSection: 0), atScrollPosition: .Right, animated: false)
        let path = NSIndexPath(forRow: numberOfDays - 1, inSection: 0)
        workoutsCollection.selectItemAtIndexPath(path, animated: false, scrollPosition: .Right)
        print("[DEBUG] view did appear")
        workout = workoutCalendar[NSDate().getDateComponents(userCalendar, dateType: workoutDateType)] ?? noWorkout(date: NSDate())
        // collectionView(workoutsCollection, didSelectItemAtIndexPath: path)
    }
    
//    override func viewWillDisappear(animated: Bool) {
//        self.parent.navigationItem.title = "koala"
//    }
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        self.parent.navigationItem.title = "koala"
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    func getDayFromNSDate(date: NSDate) -> NSDate {
//        let workoutDateComponents = userCalendar.components(workoutDateType, fromDate: date)
//        return userCalendar.dateFromComponents(workoutDateComponents)!
//    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension NSDate {
    
    func getDateComponents(calendar: NSCalendar, dateType: NSCalendarUnit) -> NSDate {
        let workoutDateComponents = calendar.components(dateType, fromDate: self)
        return calendar.dateFromComponents(workoutDateComponents)!
    }
    
    func timeBetween(calendar: NSCalendar, dateType: NSCalendarUnit, otherDate: NSDate) -> NSDateComponents {
        return calendar.components(dateType, fromDate: self, toDate: otherDate, options: [])
    }
    
}
