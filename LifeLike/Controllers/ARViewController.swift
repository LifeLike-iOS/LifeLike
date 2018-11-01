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

class ARViewController: UIViewController {

  @IBOutlet weak var arSceneView: ARSKView!
  var sceneView: ARSCNView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        sceneView = ARSCNView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        
        let referenceImages: Set<ARReferenceImage> = Set<ARReferenceImage>()
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.detectionImages = referenceImages
        sceneView?.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        view.addSubview(sceneView!)
    }
}

