//
//  ViewController.swift
//  Nosedive
//
//  Created by Marc Nieto on 10/23/16.
//  Copyright © 2016 KandidProductions. All rights reserved.
//

import UIKit

class ViewController: UIViewController, RateTileDelegate {
    /* vars */
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
    let backgroundImage = UIImage(named: "blue-background")
    var imageView: UIImageView!
    
    var mySubview: RateTile!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        /* bg image */
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = backgroundImage
        imageView.center = view.center
        view.addSubview(imageView)
        self.view.sendSubview(toBack: imageView)
        
        /* add rate tile view */
        mySubview = RateTile(frame: CGRect(x: 0.0, y: 0.0, width: screenWidth, height: screenHeight))
        mySubview.delegate = self
        mySubview.setupAction(firstName: "Jon", lastName: "Kim", score: "4.7", profilePicture: "jonkim", post: "Pho in a burrito... is this real life? One of the best things I have ever tried. Solid 9/10.", postPicture: "phorrito")
        self.view.insertSubview(mySubview, aboveSubview: imageView)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tileDismissed(rate: Int) {
        mySubview.removeFromSuperview()
        /* add rate tile view */
        mySubview = RateTile(frame: CGRect(x: 0.0, y: 0.0, width: screenWidth, height: screenHeight))
        mySubview.delegate = self
        mySubview.setupAction(firstName: "Mitchel", lastName: "Dumlao", score: "4.9", profilePicture: "mitcheldumlao", post: "At the World Choreography Awards 🎥 2 Vids I shot and edited are nominated, wish me luck 😁 #doomzday", postPicture: "choreographyawards")
        self.view.insertSubview(mySubview, aboveSubview: imageView)
        
        self.mySubview.frame = CGRect(x: 0.0, y: screenHeight, width: screenWidth, height: screenHeight)
        
        UIView.animate(withDuration: 0.2, animations: {() -> Void in
            self.mySubview.frame = CGRect(x: 0.0, y: 0.0, width: self.screenWidth, height: self.screenHeight)
            }, completion: {(complete: Bool) -> Void in

        })
    }


}

