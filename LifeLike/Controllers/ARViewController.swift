//
//  ViewController.swift
//  LifeLike
//
//  Created by Devin Fan on 10/29/18.
//  Copyright © 2018 Devin Fan. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Foundation

class ARViewController: UIViewController {
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let whaleImage = ARReferenceImage((UIImage(named: "Whale")?.cgImage)!, orientation: .up, physicalWidth: 0.1)
        let referenceImages: Set<ARReferenceImage> = [whaleImage]
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.detectionImages = referenceImages
        sceneView?.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        view.addSubview(sceneView!)
    }
}

extension ARViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        let referenceImage = imageAnchor.referenceImage
        DispatchQueue.global(qos: .userInteractive).async {
            // Create a plane to visualize the initial position of the detected image.
            let plane = SCNPlane(width: referenceImage.physicalSize.width,
                                 height: referenceImage.physicalSize.height)
            let planeNode = SCNNode(geometry: plane)
            planeNode.opacity = 0.25
            
            /*
             `SCNPlane` is vertically oriented in its local coordinate space, but
             `ARImageAnchor` assumes the image is horizontal in its local space, so
             rotate the plane to match.
             */
            planeNode.eulerAngles.x = -.pi / 2
            
            /*
             Image anchors are not tracked after initial detection, so create an
             animation that limits the duration for which the plane visualization appears.
             */
            let highlightAction = SCNAction.sequence([.wait(duration: 0.25),
                                                      .fadeOpacity(to: 0.85, duration: 1.50),
                                                      .fadeOpacity(to: 0.15, duration: 1.50),
                                                      .fadeOpacity(to: 0.85, duration: 1.50),
                                                      .fadeOut(duration: 0.75),
                                                      .removeFromParentNode()])
            planeNode.runAction(highlightAction)
            
            // Add the plane visualization to the scene.
            node.addChildNode(planeNode)
        }
    }
}
