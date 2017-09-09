//
//  CollectDataViewController.swift
//  UIStuff
//
//  Created by Adrian Pearl on 12/18/15.
//  Copyright © 2015 Adrian Pearl. All rights reserved.
//

import UIKit
//import Bean_iOS_OSX_SDK

class CollectDataViewController: UIViewController, UIScrollViewDelegate, PTDBeanManagerDelegate, PTDBeanDelegate {
    
    // var user = koalaUser()
    // var myBLE = BLE()
    // var koalas = [CBPeripheral]()
    
    var beanManager: PTDBeanManager?
    var beans = [PTDBean]()
    var strengths = [NSNumber]()
    var currentBean: PTDBean?
    
    // var exerciseNames: [String] = ["Treadmill", "Leg Press", "Bicep Curl"]
    // let layout = KokoCollectionViewLayout()
    var layers: Layers!
    var connectedKoala: Int = 0
    let workoutStatusLabel = StatusView()
    let button = KoalaButton()
    private var status: workoutStatus = .Disconnected { didSet { updateUI() } }
    
    private enum workoutStatus {
        case Searching
        case Found
        case Connecting
        case Collecting
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
        
        workoutStatusLabel.frame = CGRect(center: self.view.center, size: CGSize(width: view.bounds.width * 0.8, height: view.bounds.width * 0.8))
        view.addSubview(workoutStatusLabel)
        // workoutStatusLabel.addSubview(workoutStatusLabel.textView)
        
        button.frame = CGRect(center: CGPoint(x: view.bounds.width * 0.5, y: view.bounds.height * 0.83), size: CGSize(width: view.bounds.width * 0.6, height: view.bounds.width * 0.15))
        // button.configure(15.0, textColor: UIColor.blueColor(), borderColor: UIColor.blueColor())
        // button.setTitle("end workout", forState: .Normal)
        button.userInteractionEnabled = true
        //        button.multipleTouchEnabled = true
        //        button.showsTouchWhenHighlighted = true
        //        button.setTitle("touched", forState: .Highlighted)
        // button.addTarget(self, action: #selector(StartWorkoutViewController.tellUserEnd(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        // self.view.addSubview(button)
        
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
            print("[DEBUG] started scanning")
            status = .Searching
        }
    }
    
    func beanManager(beanManager: PTDBeanManager!, didDiscoverBean bean: PTDBean!, error: NSError!, strength: NSNumber) {
        if let e = error {
            print(e)
        } else {
            print("Found a Bean: \(bean.name)")
            beans.append(bean)
            strengths.append(strength)
            status = .Found
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
            status = .Collecting
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
    
    override func updateUI() {
        print("[DEBUG] status (from workout vc): \(status)")
        switch status {
        case .Searching:
            layers.animateRotation()
            workoutStatusLabel.textView.text = "Searching for koalas..."
        case .Found:
            if beans.count == 1 {
                workoutStatusLabel.textView.text = beans[0].name + String(strengths[0])
            } else {
                var text: String = workoutStatusLabel.textView.text!
                text += beans.last!.name + String(strengths[beans.count - 1])
                workoutStatusLabel.textView.text = text
            }
            // button.setTitle("end workout", forState: .Normal)
        case .Connecting:
            layers.animateRotation()
            workoutStatusLabel.textView.text = "Connecting to koala..."
        case .Collecting:
            // layers.animateRotation()
            workoutStatusLabel.textView.text = "Collecting data..."
        default: break
        }
        view.setNeedsDisplay()
    }
    
}
