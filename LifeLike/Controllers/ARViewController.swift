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
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var sceneView: ARSCNView!
    let dataManager = DataManager()
    var images = [Image]()
    
    var currentNode: SCNNode?
    var currentAngle = Float(0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController!.hidesBarsOnTap = true;
        
        dataManager.downloadBook(id: "5bff2130a9a32a5ac40d233c", { [self] in
            let book = self.dataManager.getBook(title: "How to Solve a Rubiks Cube")
            self.images = book!.images
            DispatchQueue.main.async {
                 self.resetTrackingConfiguration()
            }
        })
        // Do any additional setup after loading the view, typically from a nib.
        
        sceneView?.delegate = self
        resetTrackingConfiguration()
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGesture(sender:)))
        sceneView.addGestureRecognizer(panRecognizer)
        
        view.addSubview(sceneView!)
    }
    
    override var prefersStatusBarHidden: Bool {
        return navigationController?.isNavigationBarHidden == true
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return UIStatusBarAnimation.slide
    }
    
    @objc func panGesture(sender: UIPanGestureRecognizer) {
        guard let node = currentNode else { return }
        let translation = sender.translation(in: sender.view!)
        var newAngle = (Float)(translation.x)*(Float.pi)/180.0
        newAngle += currentAngle
        
        node.transform = SCNMatrix4MakeRotation(newAngle, 0, 1, 0)
        
        if(sender.state == UIGestureRecognizer.State.ended) {
            currentAngle = newAngle
        }
    }
    
    @objc func tapGesture(sender:  UITapGestureRecognizer) {
        self.navigationController!.navigationBar.isHidden = false;
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    @IBAction func refreshButtonPressed(_ sender: Any) {
        resetTrackingConfiguration()
    }
}

extension ARViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
        if let imageAnchor = anchor as? ARImageAnchor, let imageName = imageAnchor.name {
            let image = images.first { im -> Bool in
                return im.title == imageName
            }
            let modelURL = URL(string: image!.modelFile)!
            if let modelNode = SCNReferenceNode(url: modelURL) {
                modelNode.load()
                node.addChildNode(modelNode)
                currentNode = modelNode
            }
           
            node.transform = SCNMatrix4MakeTranslation(0, 0.3, 0)
            node.eulerAngles.x = -.pi / 2
            
            DispatchQueue.main.async {
                self.statusLabel.text = "Image detected: \(imageName)"
            }
        }
        return node
    }
}

private extension ARViewController {
    func resetTrackingConfiguration() {
        currentNode = nil
        let referenceImages: Set<ARReferenceImage> = Set(images.map { (image) -> ARReferenceImage in
            let refImage = ARReferenceImage((image.imageFile.cgImage)!, orientation: .up, physicalWidth: 0.5)
            refImage.name = image.title
            return refImage
        })
        let configuration = ARWorldTrackingConfiguration()
        configuration.detectionImages = referenceImages
        configuration.maximumNumberOfTrackedImages = 1
        let options: ARSession.RunOptions = [.resetTracking, .removeExistingAnchors]
        sceneView.session.run(configuration, options: options)
        statusLabel.text = "Move camera around to detect images"
    }
}
