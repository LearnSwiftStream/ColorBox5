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
    var box : UIView!
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
        
        box = UIView(frame: CGRect(x: 100, y: 100, width: 100, height: 100))
        box.backgroundColor = UIColor.gray
        view.addSubview(box)
        
        animator = UIDynamicAnimator(referenceView: view)
        gravity = UIGravityBehavior(items: [box])
        animator.addBehavior(gravity)
        
        collision = UICollisionBehavior(items: [box])
        collision.translatesReferenceBoundsIntoBoundary = true
        animator.addBehavior(collision)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("Starting gravity")
        motionManager.startDeviceMotionUpdates(to: motionQueue, withHandler: gravityUpdated)
    }
    
    override func viewDidDisappear(_ animated: Bool)  {
        super.viewDidDisappear(animated)
        
        print("Stopping gravity")
        motionManager.stopDeviceMotionUpdates()
    }
    
    //----------------- Core Motion
    @objc func gravityUpdated(motion: CMDeviceMotion?, error: Error?) {
        DispatchQueue.main.async {
            self.detectCollisions()
        }
        
        guard let motion = motion, error == nil else {
            print("got error: \(error!.localizedDescription)")
            return
        }
        
        DispatchQueue.main.async {
            self.updateGravityDirection(motion: motion)
            self.detectCollisions()
        }
    }
    
    func updateGravityDirection(motion: CMDeviceMotion) {
        let gravity: CMAcceleration = motion.gravity
        
        let x = CGFloat(gravity.x)
        let y = CGFloat(gravity.y)
        var p = CGPoint(x: x, y: y)
        let orientation = UIApplication.shared.statusBarOrientation
        let originalX = p.x
        
        switch orientation {
        case .landscapeLeft:
            p.x = 0 - p.y
            p.y = originalX
        case .landscapeRight:
            p.x = p.y
            p.y = 0 - originalX
        case .portrait:
            break // gravity works
        case .portraitUpsideDown:
            p.x *= -1
            p.y *= -1
        case .unknown:
            print("unexpected device orientation: Unknown")
        @unknown default:
            fatalError("super unknown device orientation")
        }
        
        let vector = CGVector(dx: p.x, dy: 0 - p.y)
        self.gravity.gravityDirection = vector
    }
    
    func detectCollisions() {
        
        if box.frame.minX == view.bounds.minX {       //box at the left
            box.backgroundColor = UIColor.red
        }
        else if box.frame.minY == view.bounds.minY {        //box at the top
            box.backgroundColor = UIColor.green
        }
        else if box.frame.maxX == view.bounds.maxX {       //box at the right
            box.backgroundColor = UIColor.yellow
        }
        else if box.frame.maxY == view.bounds.maxY {
            box.backgroundColor = UIColor.cyan
        }
    }

}

