//
//  BlurTransitionSegue.swift
//  AuctionApp
//

import UIKit

@objc(InsetBlurModalSeque) class InsetBlurModalSeque: UIStoryboardSegue {
    
    override func perform() {
        let sourceViewController = self.source 
        let destinationViewController = self.destination 
        
        // Make sure the background is ransparent
        destinationViewController.view.backgroundColor = UIColor.clear
        
        // Take screenshot from source VC
        UIGraphicsBeginImageContext(sourceViewController.view.bounds.size)
        sourceViewController.view.drawHierarchy(in: sourceViewController.view.frame, afterScreenUpdates:true)
        let image:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // Blur screenshot
                
//        var blurredImage:UIImage = image.applyBlurWithRadius(5, tintColor: UIColor(white: 1.0, alpha: 0.0), saturationDeltaFactor: 1.3, maskImage: nil)
        
        let blurredImage:UIImage = image

        
        // Crop screenshot, add to view and send to back
        let blurredBackgroundImageView : UIImageView = UIImageView(image:blurredImage)
        blurredBackgroundImageView.clipsToBounds = true;
        blurredBackgroundImageView.contentMode = UIViewContentMode.center
        let insets:UIEdgeInsets = UIEdgeInsetsMake(20, 20, 20, 20);
        blurredBackgroundImageView.frame = UIEdgeInsetsInsetRect(blurredBackgroundImageView.frame, insets)
        
        destinationViewController.view.addSubview(blurredBackgroundImageView)
        destinationViewController.view.sendSubview(toBack: blurredBackgroundImageView)
        
        // Add original screenshot behind blurred image
        let backgroundImageView : UIImageView = UIImageView(image:image)
        destinationViewController.view.addSubview(backgroundImageView)
        destinationViewController.view.sendSubview(toBack: backgroundImageView)
        
        // Add the destination view as a subview, temporarily – we need this do to the animation
        sourceViewController.view.addSubview(destinationViewController.view)
        
        // Set initial state of animation
        destinationViewController.view.transform = CGAffineTransform.identity.scaledBy(x: 0.1, y: 0.1);
        blurredBackgroundImageView.alpha = 0.0;
        backgroundImageView.alpha = 0.0;
        
        // Animate
        UIView.animate(withDuration: 0.5,
            delay: 0.0,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 0.0,
            options: UIViewAnimationOptions.curveLinear,
            animations: {
                destinationViewController.view.transform = CGAffineTransform.identity
                blurredBackgroundImageView.alpha = 1.0
                backgroundImageView.alpha = 1.0;
                
            },
            completion: { (fininshed: Bool) -> () in
                // Remove from temp super view
                destinationViewController.view.removeFromSuperview()
                
                sourceViewController.present(destinationViewController, animated: false, completion: nil)
            }
        )
        
    }
    
}
