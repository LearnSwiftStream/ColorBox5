//
//  ViewController.swift
//  ColorBox
//
//  Created by Matt Dias on 10/20/14.
//  Copyright (c) 2014 mattdias. All rights reserved.
//

//http://www.raywenderlich.com/76147/uikit-dynamics-tutorial-swift
//http://www.bignerdranch.com/blog/uidynamics-in-swift/

import UIKit
import CoreMotion

class ViewController: UIViewController {
    var box : UIView?
    var animator : UIDynamicAnimator!
    var gravity : UIGravityBehavior!
    var collision : UICollisionBehavior!
    var itemBehaviour: UIDynamicItemBehavior!
    
    // For getting device motion updates
    let motionQueue = NSOperationQueue()
    let motionManager = CMMotionManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let square = UIView(frame: CGRect(x: 100, y: 100, width: 100, height: 100))
        square.backgroundColor = UIColor.grayColor()
        view.addSubview(square)
        
        animator = UIDynamicAnimator(referenceView: view)
        gravity = UIGravityBehavior(items: [square])
        animator.addBehavior(gravity)
        
//        itemBehaviour = UIDynamicItemBehavior(items: [square])
//        itemBehaviour.elasticity = 0.05
//        animator.addBehavior(itemBehaviour)
        
        collision = UICollisionBehavior(items: [square])
        collision.translatesReferenceBoundsIntoBoundary = true
        animator.addBehavior(collision)
        
        box = square
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        NSLog("Starting gravity")
        motionManager.startDeviceMotionUpdatesToQueue(motionQueue, withHandler: gravityUpdated)
    }
    
    override func viewDidDisappear(animated: Bool)  {
        super.viewDidDisappear(animated)
        NSLog("Stopping gravity")
        motionManager.stopDeviceMotionUpdates()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //----------------- Core Motion
    func gravityUpdated(motion: CMDeviceMotion!, error: NSError!) {
        detectCollisions()
        let grav : CMAcceleration = motion.gravity;
        
        let x = CGFloat(grav.x);
        let y = CGFloat(grav.y);
        var p = CGPointMake(x,y)
        
        if (error != nil) {
            NSLog("\(error)")
        }
        
        // Have to correct for orientation.
        var orientation = UIApplication.sharedApplication().statusBarOrientation;
        
        if(orientation == UIInterfaceOrientation.LandscapeLeft) {
            var t = p.x
            p.x = 0 - p.y
            p.y = t
        } else if (orientation == UIInterfaceOrientation.LandscapeRight) {
            var t = p.x
            p.x = p.y
            p.y = 0 - t
        } else if (orientation == UIInterfaceOrientation.PortraitUpsideDown) {
            p.x *= -1
            p.y *= -1
        }
        
        var v = CGVectorMake(p.x, 0 - p.y);
        gravity.gravityDirection = v;
    }
    
    func detectCollisions() {
// TODO: more robust
        var maxX = 0.0 as CGFloat
        var maxY = 0.0 as CGFloat
        var boxBottom = CGPointMake(0.0, 0.0)
        var padding = 0.0 as CGFloat
        
        if let window = view as UIView? {
            maxX = window.frame.size.width
            maxY = window.frame.size.height
        }
        
        if let square = box {
            boxBottom = CGPointMake(square.frame.origin.x + square.frame.size.width, square.frame.origin.y + square.frame.size.height)
        }
        
        if (box?.frame.origin.x == (0.0 + padding)) {       //box at the left
            box?.backgroundColor = UIColor.redColor()
        } else if (box?.frame.origin.y == (0.0 + padding)) {        //box at the top
            box?.backgroundColor = UIColor.greenColor()
        } else if (boxBottom.x == (maxX - padding)) {       //box at the right
            box?.backgroundColor = UIColor.yellowColor()
        } else if (boxBottom.y == (maxY - padding)) {
            box?.backgroundColor = UIColor.cyanColor()
        }
    }

}

