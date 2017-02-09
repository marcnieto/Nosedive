//
//  ConfirmationTile.swift
//  Nosedive
//
//  Created by Marc Nieto on 10/25/16.
//  Copyright © 2016 KandidProductions. All rights reserved.
//

import UIKit
import AVFoundation

protocol ConfirmationTileDelegate {
    func confirmationTileDismissed()
}

class ConfirmationTile: UIView {
    
    /* outlets */
    @IBOutlet var profilePictureBorderView: UIView!
    @IBOutlet var profilePictureImageView: UIImageView!
    @IBOutlet var confirmationLabel: UILabel!
    
    /* constants */
    let kRawWidth = 321.0
    let kRawHeight = 467.0
    let systemSoundIDUnlock: SystemSoundID = 1003

    /* vars */
    var delegate: ConfirmationTileDelegate?
    var view: UIView!
    var panGesture : UIPanGestureRecognizer = UIPanGestureRecognizer()
    
    var originalCenter : CGPoint = CGPoint()
    
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
        let nib = UINib(nibName: "ConfirmationTile", bundle: bundle) // get xib name correctly!
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    /* setup */
    func setupView() {
        view = loadViewFromNib()
        view.frame = bounds
        addSubview(view)
        
        setupLayout()
    }
    
    func setupPanGesture() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture))
        self.addGestureRecognizer(panGesture)
    }
    
    func setupLayout() {
        
        profilePictureBorderView.frame = makeLayoutFrameFromRawFrame(frame: profilePictureBorderView.frame)
        profilePictureImageView.frame = makeLayoutFrameFromRawFrame(frame: profilePictureImageView.frame)
        confirmationLabel.frame = makeLayoutFrameFromRawFrame(frame: confirmationLabel.frame)
        
        /* profile picture */
        profilePictureBorderView.frame = CGRect(x: profilePictureBorderView.frame.origin.x, y: profilePictureBorderView.frame.origin.y, width: profilePictureBorderView.frame.size.width, height: profilePictureBorderView.frame.size.width)
        profilePictureBorderView.center = CGPoint(x: self.frame.size.width / 2, y: profilePictureBorderView.center.y)
        profilePictureImageView.frame = CGRect(x: 0.0, y: 0.0, width: profilePictureBorderView.frame.size.width, height: profilePictureBorderView.frame.size.width)
        
        profilePictureBorderView.layer.masksToBounds = false
        profilePictureBorderView.layer.cornerRadius = profilePictureBorderView.frame.size.width / 2
        
        profilePictureImageView.layer.masksToBounds = true
        profilePictureImageView.layer.cornerRadius = profilePictureImageView.frame.size.width / 2
        
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
    
    func setupTile(firstName: String, score: Int, profilePicture: String) {
        if score == 1 {
            confirmationLabel.text = "Rated\n\(firstName) \(score) star"
        }
        else {
            confirmationLabel.text = "Rated\n\(firstName) \(score) stars"
        }
        
        confirmationLabel.center = CGPoint(x: self.frame.size.width / 2, y: confirmationLabel.center.y)
        profilePictureImageView.image = UIImage(named: profilePicture)
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
                        self.delegate?.confirmationTileDismissed()

                })
                
                
            }
            else {
                UIView.animate(withDuration: 0.2, animations: {() -> Void in
                    //                    self.center = CGPoint(x: self.originalCenter.x, y: self.originalCenter.y)
                    self.center = CGPoint(x: self.originalCenter.x, y: self.originalCenter.y)
                    }, completion: {(complete: Bool) -> Void in
                })
            }
        }

    }


}
