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
    var currentNode: SCNNode?
    var currentAngle = Float(0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController!.navigationBar.isHidden = true;
        
        // Do any additional setup after loading the view, typically from a nib.
        
        let whaleImage = ARReferenceImage((UIImage(named: "Whale")?.cgImage)!, orientation: .up, physicalWidth: 0.5)
        let referenceImages: Set<ARReferenceImage> = [whaleImage]
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.detectionImages = referenceImages
        configuration.maximumNumberOfTrackedImages = 1
        configuration.isLightEstimationEnabled = true
        
        sceneView?.delegate = self
        sceneView?.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGesture(sender:)))
        sceneView.addGestureRecognizer(panRecognizer)
        
        view.addSubview(sceneView!)
    }
    
    @objc func panGesture(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: sender.view!)
        var newAngle = (Float)(translation.x)*(Float.pi)/180.0
        newAngle += currentAngle
        
        currentNode?.transform = SCNMatrix4MakeRotation(newAngle, 0, 1, 0)
        
        if(sender.state == UIGestureRecognizer.State.ended) {
            currentAngle = newAngle
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
}

extension ARViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
        if let imageAnchor = anchor as? ARImageAnchor {
//            let referenceImage = imageAnchor.referenceImage
            let whaleURL = Bundle.main.url(forResource: "small-dolphin", withExtension: "usdz")!
            if let whaleNode = SCNReferenceNode(url: whaleURL) {
                whaleNode.load()
                node.addChildNode(whaleNode)
                currentNode = whaleNode
            }
            
//            let plane = SCNPlane(width: referenceImage.physicalSize.width,
//                                 height: referenceImage.physicalSize.height)
//
//            let planeNode = SCNNode(geometry: plane)
//            planeNode.opacity = 0.25
//
           
            node.transform = SCNMatrix4MakeTranslation(0, 0.3, 0)
            node.eulerAngles.x = -.pi / 2
//
//            let highlightAction = SCNAction.sequence([.wait(duration: 0.25),
//                                                      .fadeOpacity(to: 0.85, duration: 1.50),
//                                                      .fadeOpacity(to: 0.15, duration: 1.50),
//                                                      .fadeOpacity(to: 0.85, duration: 1.50),
//                                                      .fadeOut(duration: 0.75),
//                                                      .removeFromParentNode()])
//            planeNode.runAction(highlightAction)
//            node.addChildNode(planeNode)
            
        }
        return node
    }
}
