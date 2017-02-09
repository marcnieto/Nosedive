//
//  ActionTile.swift
//  Nosedive
//
//  Created by Marc Nieto on 10/25/16.
//  Copyright © 2016 KandidProductions. All rights reserved.
//

import UIKit
import AVFoundation

protocol ActionTileDelegate {
    func actionTileDismissed()
}

class ActionTile: UIView {
    
    /* outlets */
    @IBOutlet var profilePictureBorderView: UIView!
    @IBOutlet var profilePictureImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var scoreLabel: UILabel!
    @IBOutlet var postLabel: UILabel!
    @IBOutlet var postPictureBGView: UIView!
    @IBOutlet var postPictureImageView: UIImageView!
    
    /* constants */
    let kRawWidth = 321.0
    let kRawHeight = 467.0
    let systemSoundIDUnlock: SystemSoundID = 1003
    
    /* vars */
    var view: UIView!
    var delegate: ActionTileDelegate?
    var originalCenter : CGPoint = CGPoint()
    var panGesture : UIPanGestureRecognizer = UIPanGestureRecognizer()

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
        let nib = UINib(nibName: "ActionTile", bundle: bundle) // get xib name correctly!
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
    }
    
    func setupPanGesture() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture))
        self.addGestureRecognizer(panGesture)
    }

    func setupLayout() {
        profilePictureBorderView.frame = makeLayoutFrameFromRawFrame(frame: profilePictureBorderView.frame)
        profilePictureImageView.frame = makeLayoutFrameFromRawFrame(frame: profilePictureImageView.frame)
        nameLabel.frame = makeLayoutFrameFromRawFrame(frame: nameLabel.frame)
        scoreLabel.frame = makeLayoutFrameFromRawFrame(frame: scoreLabel.frame)
        postLabel.frame = makeLayoutFrameFromRawFrame(frame: postLabel.frame)
        postPictureBGView.frame = makeLayoutFrameFromRawFrame(frame: postPictureBGView.frame)
        postPictureImageView.frame = makeLayoutFrameFromRawFrame(frame: postPictureImageView.frame)
        
        /* profile picture */
        profilePictureBorderView.frame = CGRect(x: profilePictureBorderView.frame.origin.x, y: profilePictureBorderView.frame.origin.y, width: profilePictureBorderView.frame.size.width, height: profilePictureBorderView.frame.size.width)
        profilePictureImageView.frame = CGRect(x: 0.0, y: 0.0, width: profilePictureBorderView.frame.size.width, height: profilePictureBorderView.frame.size.width)
        
        profilePictureBorderView.layer.masksToBounds = false
        profilePictureBorderView.layer.cornerRadius = profilePictureBorderView.frame.size.width / 2
        
        profilePictureImageView.layer.masksToBounds = true
        profilePictureImageView.layer.cornerRadius = profilePictureImageView.frame.size.width / 2
        
        /* post picture */
        postPictureBGView.frame = CGRect(x: postPictureBGView.frame.origin.x, y: postPictureBGView.frame.origin.y, width: postPictureBGView.frame.size.width, height: postPictureBGView.frame.size.width)
        postPictureImageView.frame = CGRect(x: 2, y: 2, width: postPictureBGView.frame.size.width - 4, height: postPictureBGView.frame.size.width - 4)
        postPictureBGView.layer.cornerRadius = 2.0
        
        originalCenter = self.center
    }
    
    func makeLayoutFrameFromRawFrame(frame: CGRect) -> CGRect {
        var widthOfView, heightOfView, layoutWidth, layoutHeight: Double
        var x, y, width, height: Double
        var newX, newY, newWidth, newHeight: Double
        
        widthOfView = Double(self.frame.size.width)
        heightOfView = Double(self.frame.size.height)
        layoutWidth = kRawWidth
        layoutHeight = kRawHeight
        
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
        layoutWidth = kRawWidth
        layoutHeight = kRawHeight
        
        x = Double(point.x)
        y = Double(point.y)
        
        newX = (x/layoutWidth) * widthOfView
        newY = (y/layoutHeight) * heightOfView
        
        return CGPoint(x: newX, y: newY)
    }
    
    func setupTile(firstName: String, lastName: String, score: String, profilePicture: String, post: String, postPicture: String) {
        nameLabel.text = "\(firstName) \(lastName)"
        scoreLabel.text = score
        profilePictureImageView.image = UIImage(named: profilePicture)
        postLabel.text = post
        postPictureImageView.image = UIImage(named: postPicture)
        
        nameLabel.sizeToFit()
        scoreLabel.sizeToFit()
        
        postLabel.adjustsFontSizeToFitWidth = true
    }
    
    /* gesture handler */
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
            if translation.y < (-0.25 * self.frame.size.height) {
                AudioServicesPlaySystemSound (systemSoundIDUnlock)
                
                UIView.animate(withDuration: 0.2, animations: {() -> Void in
                    self.center = CGPoint(x: self.originalCenter.x, y: self.originalCenter.y - UIScreen.main.bounds.height)
                    }, completion: {(complete: Bool) -> Void in
                        // call delegate here
                        self.delegate?.actionTileDismissed()
                        
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
}
