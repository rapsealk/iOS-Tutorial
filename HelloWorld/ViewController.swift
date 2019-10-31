//
//  ViewController.swift
//  HelloWorld
//
//  Created by rapsealk on 29/10/2019.
//  Copyright © 2019 rapsealk. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVFoundation

class ViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    
    @IBOutlet var previewView: UIView!
    @IBOutlet var captureImageView: UIImageView!
    
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Setup camera here..
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .medium
        
        guard let backCamera = AVCaptureDevice.default(for: AVMediaType.video)
            else {
                print("Unable to access back camera!")
                return
        }
        
        // 8. Prepare the input
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            
            // 9. Configure the output
            stillImageOutput = AVCapturePhotoOutput()
            
            // 10. Attach the input and output
            if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput) {
                captureSession.addInput(input)
                captureSession.addOutput(stillImageOutput)
                self.setupLivePreview()
            }
        }
        catch let error {
            print("Error Unable to initialize back camera: \(error.localizedDescription)")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.captureSession.stopRunning()
    }
    
    // 14. Taking the photo
    @IBAction func didTakePhoto(_ sender: Any) {
        
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        stillImageOutput.capturePhoto(with: settings, delegate: self)
    }
    
    // 11. Configure the live preview
    func setupLivePreview() {
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspect
        videoPreviewLayer.connection?.videoOrientation = .portrait
        
        previewView.layer.addSublayer(videoPreviewLayer)
        
        // 12. Start the session on the background thread
        DispatchQueue.global(qos: .userInitiated).async {   // [weak self] in
            self.captureSession.startRunning()
            
            // 13. Size the preview Layer to fit the Preview view
            DispatchQueue.main.async {
                self.videoPreviewLayer.frame = self.previewView.bounds
            }
        }
    }
    
    // 15. Process the captured photo
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        guard let imageData = photo.fileDataRepresentation()
            else { return }
        
        let image = UIImage(data: imageData)
        captureImageView.image = image
    }
    
    func alert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}

