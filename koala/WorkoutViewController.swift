//
//  WorkoutViewController.swift
//  koala
//
//  Created by Adrian on 8/23/16.
//  Copyright © 2016 Adrian Pearl. All rights reserved.
//

import UIKit

class WorkoutViewController: UITableViewController {
    
    
    @IBOutlet weak var wktMode: UISwitch!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var gradView: StatusView!
    @IBOutlet weak var minutesLabel: UILabel!
    
    var layers: Layers!
    
    func weekWorkoutMins() -> Int {
        var i = koalaUser.exercises.count - 1
        var val = 0.0
        let today = NSDate()
        while today.timeIntervalSinceDate(koalaUser.exercises[i].startTime) / 86400 < 7 {
            val += koalaUser.exercises[i].duration
            if i == 0 { break; }
            i -= 1
        }
        return Int(val / 60)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.scrollEnabled = false
        self.tableView.estimatedRowHeight = view.bounds.height / 8
        wktMode.addTarget(self, action: #selector(self.stateChange), forControlEvents: UIControlEvents.ValueChanged)
        
        gradView.textView.text = "Welcome to Koala"

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        minutesLabel.text = "\(weekWorkoutMins())"
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        layers = Layers(viewForGradient: statusView, viewForReplicator: gradView)
        
        statusView.layer.insertSublayer(layers.gl, atIndex: 0)
        statusView.layer.addSublayer(layers.rl)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func stateChange(switchState: UISwitch) {
        if (BLEManager.sharedInstance.stateChange(switchState.on)) {
            if (switchState.on) {
                layers.animateRotation()
                gradView.textView.text = "Tracking your workout..."
            } else {
                layers.deAnimateRotation()
                gradView.textView.text = "Welcome to Koala"
            }
        } else {
            wktMode.on = false
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
