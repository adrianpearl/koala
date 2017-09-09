//
//  KokoCollectionViewController.swift
//  UIStuff
//
//  Created by Adrian Pearl on 12/18/15.
//  Copyright © 2015 Adrian Pearl. All rights reserved.
//

import UIKit
import Bean_iOS_OSX_SDK

class StartWorkoutViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UIScrollViewDelegate, PTDBeanManagerDelegate, PTDBeanDelegate {
    
    private let reuseIdentifier = "cell"
    
    // var user = koalaUser()
    // var myBLE = BLE()
    // var koalas = [CBPeripheral]()
    
    var beanManager: PTDBeanManager?
    var beans = [PTDBean]()
    var currentBean: PTDBean?
    
    // var exerciseNames: [String] = ["Treadmill", "Leg Press", "Bicep Curl"]
    // let layout = KokoCollectionViewLayout()
    var collectionView: UICollectionView!
    var layers: Layers!
    var connectedKoala: Int = 0
    let workoutStatusLabel = StatusView()
    let button = KoalaButton()
    let pages = UIPageControl()
    private var status: workoutStatus = workoutStatus.NotInWorkoutMode { didSet { updateUI() } }
    
    // an enum that the user object updates whenever there is a change in the status of the bluetooth connection; the top view controller then reads this enum and responds accordingly
    private enum workoutStatus {
        case NotInWorkoutMode
        case Searching
        case Selection
        case Connecting
        case Tracking
        case Disconnected
        case ConnectionFailed
        case ConnectionLost
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        print("[DEBUG] exercises (workout view did load): \(koalaUser.exercises.count)")
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Horizontal
        
        // collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView = UICollectionView(frame: CGRect(center: self.view.center, size: CGSize(width: view.bounds.width, height: view.bounds.height + 0.5)), collectionViewLayout: layout)
        // collectionView.scrollEnabled = true
        collectionView.pagingEnabled = true
    
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.registerClass(KokoCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        workoutStatusLabel.frame = CGRect(center: self.view.center, size: CGSize(width: view.bounds.width * 0.8, height: view.bounds.width * 0.8))
        view.addSubview(workoutStatusLabel)
        // workoutStatusLabel.addSubview(workoutStatusLabel.textView)
        
        pages.pageIndicatorTintColor = workoutGreen
        pages.frame = CGRect(center: CGPoint(x: view.bounds.width * 0.5, y: view.bounds.height * 0.77), size: pages.sizeForNumberOfPages(8))
        self.view.addSubview(pages)
        
        button.frame = CGRect(center: CGPoint(x: view.bounds.width * 0.5, y: view.bounds.height * 0.83), size: CGSize(width: view.bounds.width * 0.6, height: view.bounds.width * 0.15))
        // button.configure(15.0, textColor: UIColor.blueColor(), borderColor: UIColor.blueColor())
        // button.setTitle("end workout", forState: .Normal)
        button.userInteractionEnabled = true
//        button.multipleTouchEnabled = true
//        button.showsTouchWhenHighlighted = true
//        button.setTitle("touched", forState: .Highlighted)
        button.addTarget(self, action: #selector(StartWorkoutViewController.tellUserEnd(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        self.view.addSubview(collectionView)
        self.view.addSubview(button)
        
        layers = Layers(viewForGradient: view, viewForReplicator: workoutStatusLabel)
        
        // view.layer.insertSublayer(layers.gl, atIndex: 0)
        view.backgroundColor = UIColor.whiteColor()
        
        //view.layer.addSublayer(layers.rl)
        workoutStatusLabel.layer.addSublayer(layers.rl)
        
        beanManager = PTDBeanManager()
        beanManager!.delegate = self
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        // self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        updateUI()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        startScanning()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startScanning() {
        var error: NSError?
        beanManager!.startScanningForBeans_error(&error)
        if let e = error {
            print(e)
        } else {
            status = .Searching
        }
    }
    
    func beanManager(beanManager: PTDBeanManager!, didDiscoverBean bean: PTDBean!, error: NSError!) {
        if let e = error {
            print(e)
        } else {
        
            print("Found a Bean: \(bean.name)")
            beans.append(bean)
            status = .Selection
        }
    }
    
    func connectToBean(bean: PTDBean) {
        var error: NSError?
        beanManager?.connectToBean(bean, error: &error)
        if let e = error {
            print(e)
        } else {
            print("Connecting to Bean: \(bean.name)")
            status = .Connecting
        }
    }
    
    func beanManager(beanManager: PTDBeanManager!, didConnectBean bean: PTDBean!, error: NSError!) {
        if let e = error {
            print(e)
        } else {
            
            currentBean = bean
            currentBean?.delegate = self
            status = .Tracking
            // koalaUser.exerciseInProgress = koalaExercise(name: bean.name, start: NSDate())
        }
    }
    
    func bean(bean: PTDBean!, serialDataReceived data: NSData!) {
        // the number of elements:
        if let count = data?.length {
            // create array of appropriate length:
            var array = [Int](count: count, repeatedValue: 0)
            // copy bytes into array
            data!.getBytes(&array, length:count * sizeof(UInt32))
            let newString = NSString(bytes: &array, length: data!.length, encoding: NSUTF8StringEncoding)
            let receivedString = String(newString!)
            print("[DEBUG] message: \(receivedString)")
            workoutStatusLabel.textView.text = receivedString
            // koalaUser.exerciseInProgress?.addData(receivedString)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        print("[DEBUG] CView # of items: \(beans.count)")
        pages.numberOfPages = beans.count ?? 0
        return beans.count ?? 0
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! KokoCollectionViewCell
        print("[DEBUG] \(beans[indexPath.row])")
        print("[DEBUG] \(cell.workoutStatusView.frame.width)")
        // pages.currentPage = indexPath.row
        // cell.backgroundColor = colors[indexPath.row]
        cell.workoutStatusView.text = beans[indexPath.row].name ?? "Uknown Device"
        return cell
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        updatePage()
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        updatePage()
    }
    
    func updatePage() {
        let visibleCells = collectionView.indexPathsForVisibleItems()
        if visibleCells.count == 1 {
            pages.currentPage = visibleCells[0].row
        }
    }
    
    // MARK: UICollectionViewDelegate
    
    
    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
//        return 0
//    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        connectToBean(beans[indexPath.row])
    }
    
    func tellUserEnd(sender: UIButton!) {
        print("[DEBUG] button pressed")
        switch status {
        case .NotInWorkoutMode:
            startScanning()
        case .Tracking:
            if let current = currentBean {
                beanManager?.disconnectBean(current, error: nil)
            }
            beans = []
        default:
            status = .NotInWorkoutMode
        }
    }
    
    override func updateUI() {
        print("[DEBUG] status (from workout vc): \(status)")
        switch status {
        case .NotInWorkoutMode:
            workoutStatusLabel.textView.text = "Welcome to koala"
            button.setTitle("start workout", forState: .Normal)
            layers.deAnimateRotation()
            collectionView.removeFromSuperview()
        case .Searching:
            layers.animateRotation()
            workoutStatusLabel.textView.text = "Searching for koalas..."
            button.setTitle("end workout", forState: .Normal)
        case .Selection:
            print("[DEBUG] koalas: \(beans.count)")
            layers.deAnimateRotation()
            workoutStatusLabel.textView.text = ""
            view.addSubview(collectionView)
            collectionView.reloadData()
        case .Connecting:
            layers.animateRotation()
            collectionView.removeFromSuperview()
            workoutStatusLabel.textView.text = "Connecting to koala..."
        case .Tracking:
            // layers.animateRotation()
            workoutStatusLabel.textView.text = "Tracking your workout..."
            pages.numberOfPages = 0
        default: break
        }
        view.setNeedsDisplay()
    }

}
