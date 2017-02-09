//
//  RateTile.swift
//  Nosedive
//
//  Created by Marc Nieto on 10/23/16.
//  Copyright © 2016 KandidProductions. All rights reserved.
//

import UIKit
import AVFoundation

struct Constants {
    static let kRawWidth = 375.0
    static let kRawHeight = 667.0
}

protocol RateTileDelegate {
    func tileDismissed(rate: Int)
}

class RateTile: UIView, ActionTileDelegate, UIGestureRecognizerDelegate {
    
    /* outlets */
    @IBOutlet var star1: UIImageView!
    @IBOutlet var star2: UIImageView!
    @IBOutlet var star3: UIImageView!
    @IBOutlet var star4: UIImageView!
    @IBOutlet var star5: UIImageView!
    
    /* vars */
    var delegate: RateTileDelegate?
    let starWhite : UIImage = UIImage(named:"star-white")!
    let starGold : UIImage = UIImage(named:"star-gold")!
    
    var spacing : CGFloat = 0.0
    
    var star1toggled : Bool = false
    var star2toggled : Bool = false
    var star3toggled : Bool = false
    var star4toggled : Bool = false
    var star5toggled : Bool = false
    var rating : Int = 0
    
    var ratingInitialized : Bool = false
    var dismissInitialized : Bool = false
    var translationInitialized : Bool = false
    var verticalInitialized : Bool = false
    var translationOrigin : CGPoint = CGPoint()
    var originalCenter : CGPoint = CGPoint()
    var originalActionCenter : CGPoint = CGPoint()
    
    let systemSoundIDTonk: SystemSoundID = 1306
    let systemSoundIDUnlock: SystemSoundID = 1004
    var view: UIView!
    
    var actionTile: ActionTile!
    var confirmationTile: ConfirmationTile!
    var firstName : String = String()
    var profilePicture : String = String()
    
    var panGesture : UIPanGestureRecognizer = UIPanGestureRecognizer()
    var longPressGesture : UILongPressGestureRecognizer = UILongPressGestureRecognizer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "RateTile", bundle: bundle) // get xib name correctly!
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    /* setup */
    
    func setupView() {
        view = loadViewFromNib()
        view.frame = bounds
        addSubview(view)
        
        setupLayout()
        setupPanGesture()
        setupLongPressGesture()
    }
    
    func setupPanGesture() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture))
        self.addGestureRecognizer(panGesture)
        panGesture.isEnabled = false
    }
    
    func setupLongPressGesture() {
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress))
        longPressGesture.minimumPressDuration = 0.0
        longPressGesture.delaysTouchesBegan = true
        self.addGestureRecognizer(longPressGesture)
    }
    
    func setupAction(firstName: String, lastName: String, score: String, profilePicture: String, post: String, postPicture: String) {
        /* add action view, raw frame */
        actionTile = ActionTile(frame: makeLayoutFrameFromRawFrame(frame: CGRect(x: 27.0, y: 79.0, width: 321.0, height: 467.0)))
        actionTile.setupTile(firstName: firstName, lastName: lastName, score: score, profilePicture: profilePicture, post: post, postPicture: postPicture)
        actionTile.delegate = self
        
        actionTile.layer.masksToBounds = true
        actionTile.layer.cornerRadius = 6.0
        
        originalActionCenter = actionTile.center
        
        self.addSubview(actionTile)
        
        self.firstName = firstName
        self.profilePicture = profilePicture
        longPressGesture.isEnabled = true
    }
    
    func setupConfirm(firstName: String, score: Int, profilePicture: String) {
        /* add action view, raw frame */
        confirmationTile = ConfirmationTile(frame: makeLayoutFrameFromRawFrame(frame: CGRect(x: 27.0, y: 79.0, width: 321.0, height: 467.0)))
        confirmationTile.setupTile(firstName: firstName, score: score, profilePicture: profilePicture)
        confirmationTile.layer.masksToBounds = true
        confirmationTile.layer.cornerRadius = 6.0
        
        self.addSubview(confirmationTile)
        
        longPressGesture.isEnabled = false
        panGesture.isEnabled = true
        
        /* animate the stars */
        let array = [star1, star2, star3, star4, star5]
        for i in 0...(score-1) {
            animateStar(star: array[i]!)
        }
        
    }
    
    func setupLayout() {
        star1.center = makeLayoutPointFromRawPoint(point: star1.center)
        star2.center = makeLayoutPointFromRawPoint(point: star2.center)
        star3.center = makeLayoutPointFromRawPoint(point: star3.center)
        star4.center = makeLayoutPointFromRawPoint(point: star4.center)
        star5.center = makeLayoutPointFromRawPoint(point: star5.center)
        
        star1.image = starWhite
        star2.image = starWhite
        star3.image = starWhite
        star4.image = starWhite
        star5.image = starWhite
        
        spacing = star2.center.x - star1.center.x
        
        originalCenter = self.center
    }
    
    func makeLayoutFrameFromRawFrame(frame: CGRect) -> CGRect {
        var widthOfView, heightOfView, layoutWidth, layoutHeight: Double
        var x, y, width, height: Double
        var newX, newY, newWidth, newHeight: Double
        
        widthOfView = Double(self.frame.size.width)
        heightOfView = Double(self.frame.size.height)
        layoutWidth = Constants.kRawWidth
        layoutHeight = Constants.kRawHeight
    
        x = Double(frame.origin.x)
        y = Double(frame.origin.y)
        width = Double(frame.size.width)
        height = Double(frame.size.height)
    
        newX = (x/layoutWidth) * widthOfView
        newY = (y/layoutHeight) * heightOfView
        newWidth = (width/layoutWidth) * widthOfView
        newHeight = (height/layoutHeight) * heightOfView
        
        return CGRect(x: newX, y: newY, width: newWidth, height: newHeight)
    }
    
    func makeLayoutPointFromRawPoint(point: CGPoint) -> CGPoint {
        var widthOfView, heightOfView, layoutWidth, layoutHeight: Double
        var x, y: Double
        var newX, newY: Double
        
        widthOfView = Double(self.frame.size.width)
        heightOfView = Double(self.frame.size.height)
        layoutWidth = Constants.kRawWidth
        layoutHeight = Constants.kRawHeight
        
        x = Double(point.x)
        y = Double(point.y)
        
        newX = (x/layoutWidth) * widthOfView
        newY = (y/layoutHeight) * heightOfView
        
        return CGPoint(x: newX, y: newY)
    }
    
    /* helper functions */    
    func animateStar(star: UIImageView) {

        UIView.animate(withDuration: 0.3, animations: {() -> Void in
            star.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            }, completion: {(complete: Bool) -> Void in
                
                UIView.animate(withDuration: 0.3, animations: {() -> Void in
                    star.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    }, completion: {(complete: Bool) -> Void in


                        
                })
                
        })
    }

    /* gesture handling */
    func handlePanGesture(panGesture: UIPanGestureRecognizer) {
        let translation = panGesture.translation(in: self)
        
        if panGesture.state == UIGestureRecognizerState.began {
            panGesture.setTranslation(CGPoint(x:0,y:0), in: self)
        }
        
        if panGesture.state == UIGestureRecognizerState.changed {
            if translation.y < 0 {
                self.center = CGPoint(x: originalCenter.x, y: originalCenter.y + translation.y)
            }
        }
        
        if panGesture.state == UIGestureRecognizerState.ended {
            if translation.y < (-0.15 * self.frame.size.height) {
                AudioServicesPlaySystemSound (systemSoundIDUnlock)
                
                UIView.animate(withDuration: 0.2, animations: {() -> Void in
                    self.center = CGPoint(x: self.originalCenter.x, y: self.originalCenter.y - UIScreen.main.bounds.height)
                    }, completion: {(complete: Bool) -> Void in
                        // call delegate here
                        self.delegate?.tileDismissed(rate: self.rating)
                        
                })
                
                
            }
            else {
                UIView.animate(withDuration: 0.2, animations: {() -> Void in
                    self.center = CGPoint(x: self.originalCenter.x, y: self.originalCenter.y)
                    }, completion: {(complete: Bool) -> Void in
                })
            }
        }
    }
    
    func handleLongPress(longPressGesture: UILongPressGestureRecognizer) {
        let location = longPressGesture.location(in: self)
        
        let initialCondition = location.x >= star1.frame.origin.x && location.x <= (star1.frame.origin.x + star1.frame.size.width) &&
            location.y >= star1.frame.origin.y && location.y <= (star1.frame.origin.y + star1.frame.size.height)
        let dismissCondition = location.x >= actionTile.frame.origin.x && location.x <= (actionTile.frame.origin.x + actionTile.frame.size.width) &&
            location.y >= actionTile.frame.origin.y && location.y <= (actionTile.frame.origin.y + actionTile.frame.size.height)
        
        if(initialCondition || ratingInitialized){
            
            ratingInitialized = true
            
            if !translationInitialized {
                translationOrigin = location
                translationInitialized = true
            }
            
            let translation = CGPoint(x: location.x - translationOrigin.x, y: location.y - translationOrigin.y)
            
            if longPressGesture.state == UIGestureRecognizerState.ended {
                if translation.y < (-0.25 * self.frame.size.height) {
                    AudioServicesPlaySystemSound (systemSoundIDUnlock)
                    
                    UIView.animate(withDuration: 0.2, animations: {() -> Void in
                        self.actionTile.center = CGPoint(x: self.originalActionCenter.x, y: self.originalActionCenter.y - self.frame.size.height)
                    }, completion: {(complete: Bool) -> Void in
                        self.setupConfirm(firstName: self.firstName, score: self.rating, profilePicture: self.profilePicture)
                    })
                    
                    
                }
                else {
                    star1toggled = false
                    star2toggled = false
                    star3toggled = false
                    star4toggled = false
                    star5toggled = false
                    
                    star1.image = starWhite
                    star2.image = starWhite
                    star3.image = starWhite
                    star4.image = starWhite
                    star5.image = starWhite
                    
                    verticalInitialized = false
                    translationInitialized = false
                    
                    UIView.animate(withDuration: 0.2, animations: {() -> Void in
                        self.actionTile.center = CGPoint(x: self.originalActionCenter.x, y: self.originalActionCenter.y)
                        self.actionTile.alpha = 1.0
                    }, completion: {(complete: Bool) -> Void in
                    })
                }
                
                star1.alpha = 1.0
                star2.alpha = 1.0
                star3.alpha = 1.0
                star4.alpha = 1.0
                star5.alpha = 1.0
                
                ratingInitialized = false
                
                return
            }
            
            if translation.y < (-0.025 * self.frame.size.height) {
                self.actionTile.center = CGPoint(x: originalActionCenter.x, y: originalActionCenter.y + translation.y)
                self.actionTile.alpha = max(0.4, 0.9 - (fabs(translation.y) / (self.actionTile.frame.size.height)))
                
                if(!verticalInitialized) {
                    star1.alpha = 0.8
                    star2.alpha = 0.8
                    star3.alpha = 0.8
                    star4.alpha = 0.8
                    star5.alpha = 0.8
                    
                    AudioServicesPlaySystemSound (systemSoundIDTonk)
                    verticalInitialized = true
                }
            }
            else {
                if verticalInitialized {
                    self.actionTile.center = CGPoint(x: originalActionCenter.x, y: originalActionCenter.y)
                    self.actionTile.alpha = 1.0
                    verticalInitialized = false
                    
                    star1.alpha = 1.0
                    star2.alpha = 1.0
                    star3.alpha = 1.0
                    star4.alpha = 1.0
                    star5.alpha = 1.0
                    
                    AudioServicesPlaySystemSound (systemSoundIDTonk)
                }
                
                if location.x < star2.frame.origin.x && !star1toggled {
                    star1.image = starGold
                    star2.image = starWhite
                    star3.image = starWhite
                    star4.image = starWhite
                    star5.image = starWhite
                    
                    star1toggled = true
                    star2toggled = false
                    star3toggled = false
                    star4toggled = false
                    star5toggled = false
                    
                    rating = 1
                    
                    AudioServicesPlaySystemSound (systemSoundIDTonk)
                }
                else if location.x >= star2.frame.origin.x && location.x < star3.frame.origin.x && !star2toggled {
                    star1.image = starGold
                    star2.image = starGold
                    star3.image = starWhite
                    star4.image = starWhite
                    star5.image = starWhite
                    
                    star1toggled = false
                    star2toggled = true
                    star3toggled = false
                    star4toggled = false
                    star5toggled = false
                    
                    rating = 2
                    
                    AudioServicesPlaySystemSound (systemSoundIDTonk)
                }
                else if location.x >= star3.frame.origin.x && location.x < star4.frame.origin.x && !star3toggled {
                    star1.image = starGold
                    star2.image = starGold
                    star3.image = starGold
                    star4.image = starWhite
                    star5.image = starWhite
                    
                    star1toggled = false
                    star2toggled = false
                    star3toggled = true
                    star4toggled = false
                    star5toggled = false
                    
                    rating = 3
                    
                    AudioServicesPlaySystemSound (systemSoundIDTonk)
                }
                else if location.x >= star4.frame.origin.x && location.x < star5.frame.origin.x && !star4toggled {
                    star1.image = starGold
                    star2.image = starGold
                    star3.image = starGold
                    star4.image = starGold
                    star5.image = starWhite
                    
                    star1toggled = false
                    star2toggled = false
                    star3toggled = false
                    star4toggled = true
                    star5toggled = false
                    
                    rating = 4
                    
                    AudioServicesPlaySystemSound (systemSoundIDTonk)
                }
                else if location.x >= star5.frame.origin.x && !star5toggled {
                    star1.image = starGold
                    star2.image = starGold
                    star3.image = starGold
                    star4.image = starGold
                    star5.image = starGold
                    
                    star1toggled = false
                    star2toggled = false
                    star3toggled = false
                    star4toggled = false
                    star5toggled = true
                    
                    rating = 5
                    
                    AudioServicesPlaySystemSound (systemSoundIDTonk)
                }
            }
        }
        else if(dismissCondition || dismissInitialized) {
            
            dismissInitialized = true
            
            if !translationInitialized {
                translationOrigin = location
                translationInitialized = true
            }
            
            let translation = CGPoint(x: location.x - translationOrigin.x, y: location.y - translationOrigin.y)
            
            if longPressGesture.state == UIGestureRecognizerState.ended {
                if translation.y < (-0.25 * self.frame.size.height) {
                    AudioServicesPlaySystemSound (systemSoundIDUnlock)
                    
                    UIView.animate(withDuration: 0.2, animations: {() -> Void in
                        self.actionTile.center = CGPoint(x: self.originalActionCenter.x, y: self.originalActionCenter.y - self.frame.size.height)
                    }, completion: {(complete: Bool) -> Void in
                        self.delegate?.tileDismissed(rate: self.rating)
                    })
                    
                    
                }
                else {
                    star1toggled = false
                    star2toggled = false
                    star3toggled = false
                    star4toggled = false
                    star5toggled = false
                    
                    star1.image = starWhite
                    star2.image = starWhite
                    star3.image = starWhite
                    star4.image = starWhite
                    star5.image = starWhite
                    
                    verticalInitialized = false
                    translationInitialized = false
                    
                    UIView.animate(withDuration: 0.2, animations: {() -> Void in
                        self.actionTile.center = CGPoint(x: self.originalActionCenter.x, y: self.originalActionCenter.y)
                        self.actionTile.alpha = 1.0
                    }, completion: {(complete: Bool) -> Void in
                    })
                }
                
                star1.alpha = 1.0
                star2.alpha = 1.0
                star3.alpha = 1.0
                star4.alpha = 1.0
                star5.alpha = 1.0
                
                dismissInitialized = false
                
                return
            }
            
            
            if translation.y < (-0.025 * self.frame.size.height) {
                self.actionTile.center = CGPoint(x: originalActionCenter.x, y: originalActionCenter.y + translation.y)
                self.actionTile.alpha = max(0.4, 0.9 - (fabs(translation.y) / (self.actionTile.frame.size.height)))
                
                if(!verticalInitialized) {
                    star1.alpha = 0.1
                    star2.alpha = 0.1
                    star3.alpha = 0.1
                    star4.alpha = 0.1
                    star5.alpha = 0.1
                    
                    AudioServicesPlaySystemSound (systemSoundIDTonk)
                    verticalInitialized = true
                }
            }
            else {
                if verticalInitialized {
                    //                self.center = CGPoint(x: self.originalCenter.x, y: self.originalCenter.y)
                    self.actionTile.center = CGPoint(x: originalActionCenter.x, y: originalActionCenter.y)
                    self.actionTile.alpha = 1.0
                    verticalInitialized = false
                    
                    star1.alpha = 1.0
                    star2.alpha = 1.0
                    star3.alpha = 1.0
                    star4.alpha = 1.0
                    star5.alpha = 1.0
                    
                    AudioServicesPlaySystemSound (systemSoundIDTonk)
                }
            }
        }
    }
    
    /* delegate */
    func actionTileDismissed() {
        if(rating == 0){
            self.delegate?.tileDismissed(rate: self.rating)
        }
        else {
            self.setupConfirm(firstName: self.firstName, score: self.rating, profilePicture: self.profilePicture)
        }
    }
    
    func confirmationTileDismissed() {
        self.delegate?.tileDismissed(rate: self.rating)
    }
}
