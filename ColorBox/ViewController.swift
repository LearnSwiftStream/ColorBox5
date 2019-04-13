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
    let motionQueue = OperationQueue()
    let motionManager = CMMotionManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let square = UIView(frame: CGRect(x: 100, y: 100, width: 100, height: 100))
        square.backgroundColor = UIColor.gray
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NSLog("Starting gravity")
        motionManager.startDeviceMotionUpdates(to: motionQueue) { (motion, error) in
            DispatchQueue.main.async {
                self.detectCollisions()
            }
            let grav: CMAcceleration = motion!.gravity
            
            let x = CGFloat(grav.x)
            let y = CGFloat(grav.y)
            var p = CGPoint(x: x, y: y)
            
            if let error = error {
                print("got error: \(error.localizedDescription)")
            }
            
            // Have to correct for orientation.
            DispatchQueue.main.async {
                let orientation = UIApplication.shared.statusBarOrientation
                
                if(orientation == UIInterfaceOrientation.landscapeLeft) {
                    let t = p.x
                    p.x = 0 - p.y
                    p.y = t
                } else if (orientation == UIInterfaceOrientation.landscapeRight) {
                    let t = p.x
                    p.x = p.y
                    p.y = 0 - t
                } else if (orientation == UIInterfaceOrientation.portraitUpsideDown) {
                    p.x *= -1
                    p.y *= -1
                }
                
                let v = CGVector(dx: p.x, dy: 0 - p.y)
                self.gravity.gravityDirection = v
            }
            
        }

    }
    
    override func viewDidDisappear(_ animated: Bool)  {
        super.viewDidDisappear(animated)
        NSLog("Stopping gravity")
        motionManager.stopDeviceMotionUpdates()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //----------------- Core Motion
    func gravityUpdated(motion: CMDeviceMotion?, error: NSError?) {
        
    }
    
    func detectCollisions() {
// TODO: more robust
        var maxX = 0.0 as CGFloat
        var maxY = 0.0 as CGFloat
        var boxBottom = CGPoint(x: 0.0, y: 0.0)
        let padding = 0.0 as CGFloat
        
        if let window = view as UIView? {
            maxX = window.frame.size.width
            maxY = window.frame.size.height
        }
        
        if let square = box {
            DispatchQueue.main.async {
                boxBottom = CGPoint(x: square.frame.origin.x + square.frame.size.width, y: square.frame.origin.y + square.frame.size.height)
            }
        }
        
        if (box?.frame.origin.x == (0.0 + padding)) {       //box at the left
            box?.backgroundColor = UIColor.red
        } else if (box?.frame.origin.y == (0.0 + padding)) {        //box at the top
            box?.backgroundColor = UIColor.green
        } else if (boxBottom.x == (maxX - padding)) {       //box at the right
            box?.backgroundColor = UIColor.yellow
        } else if (boxBottom.y == (maxY - padding)) {
            box?.backgroundColor = UIColor.cyan
        }
    }

}

