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
    @IBOutlet weak var toolBarView: UIView!
    @IBOutlet weak var minimizeButton: UIButton!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var imageNameLabel: UILabel!
    @IBOutlet weak var pageLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    var book: Book?
    
    var storedInfoViewHeight = CGFloat(0)
    var minimized = false
    var currentNode: SCNNode?
    var currentAngle = Float(0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController!.isNavigationBarHidden = true;
        // Do any additional setup after loading the view, typically from a nib.
        sceneView?.delegate = self
        resetTrackingConfiguration()
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGesture(sender:)))
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(scaleObject(gesture:)))
        sceneView.addGestureRecognizer(panRecognizer)
        sceneView.addGestureRecognizer(pinchRecognizer)
        view.addSubview(sceneView!)
        titleLabel.text = book?.title
        infoView.layer.zPosition = 10000.0
        toolBarView.layer.zPosition = 20000.0
    }
    
    @objc func panGesture(sender: UIPanGestureRecognizer) {
        guard let node = currentNode else { return }
        let translation = sender.translation(in: sender.view!)
        var newAngle = (Float)(translation.x)*(Float.pi)/180.0
        newAngle += currentAngle
        let scale = node.scale
        node.transform = SCNMatrix4MakeRotation(newAngle, 0, 1, 0)
        node.scale = scale
        if(sender.state == UIGestureRecognizer.State.ended) {
            currentAngle = newAngle
        }
    }
    
    @objc func scaleObject(gesture: UIPinchGestureRecognizer) {
        guard let nodeToScale = currentNode else { return }
        if gesture.state == .changed {
            let pinchScaleX: CGFloat = gesture.scale * CGFloat((nodeToScale.scale.x))
            let pinchScaleY: CGFloat = gesture.scale * CGFloat((nodeToScale.scale.y))
            let pinchScaleZ: CGFloat = gesture.scale * CGFloat((nodeToScale.scale.z))
            nodeToScale.scale = SCNVector3Make(Float(pinchScaleX), Float(pinchScaleY), Float(pinchScaleZ))
            gesture.scale = 1
        }
        if gesture.state == .ended { }
    }
    
    @IBAction func pressedMinimize(_ sender: Any) {
        if minimized {
            UIView.animate(withDuration: 0.5) {
                self.infoView.frame = CGRect(x: 0, y: self.toolBarView.bounds.maxY, width: self.infoView.bounds.width, height: self.infoView.bounds.height)
                self.minimizeButton.transform = CGAffineTransform(rotationAngle: 0)
                self.view.layoutIfNeeded()
            }
        } else {
            UIView.animate(withDuration: 0.5) {
                self.infoView.frame = CGRect(x: 0, y: 0 - self.infoView.bounds.height, width: self.infoView.bounds.width, height: self.infoView.bounds.height)
                self.minimizeButton.transform = CGAffineTransform(rotationAngle: CGFloat(Float.pi))
                self.view.layoutIfNeeded()
            }
        }
        minimized = !minimized
    }
    
    @IBAction func pressedExitButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
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
        guard let book = self.book else { return node }
        if currentNode == nil, let imageAnchor = anchor as? ARImageAnchor, let imageName = imageAnchor.name {
            let image = book.images.first { im -> Bool in
                return im.title == imageName
            }
            let modelURL = fileInDocumentsDirectory(filename: image!.modelFile)
            if let modelNode = SCNReferenceNode(url: modelURL) {
                modelNode.load()
                node.addChildNode(modelNode)
                currentNode = modelNode
            }
           
            node.transform = SCNMatrix4MakeTranslation(0, 0.1, 0)
            node.eulerAngles.x = -.pi / 2
            
            DispatchQueue.main.async {
                self.imageNameLabel.text = image!.title
                self.pageLabel.text = String(image!.pageNumber)
            }
        }
        return node
    }
}

private extension ARViewController {
    func resetTrackingConfiguration() {
        guard let book = self.book else { return }
        currentNode = nil
        let referenceImages: Set<ARReferenceImage> = Set(book.images.map { (image) -> ARReferenceImage in
            let refImage = ARReferenceImage((image.imageFile.cgImage)!, orientation: .up, physicalWidth: 0.3)
            refImage.name = image.title
            return refImage
        })
        let configuration = ARWorldTrackingConfiguration()
        configuration.detectionImages = referenceImages
        configuration.maximumNumberOfTrackedImages = 1
        let options: ARSession.RunOptions = [.resetTracking, .removeExistingAnchors]
        sceneView.session.run(configuration, options: options)
        imageNameLabel.text = ""
        pageLabel.text = ""
    }
    
    func fileInDocumentsDirectory(filename: String) -> URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(filename)
        return fileURL
    }
}
