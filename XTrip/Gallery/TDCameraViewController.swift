//
//  TDCameraViewController.swift
//  XTrip
//
//  Created by Khoa Bui on 12/9/17.
//  Copyright © 2017 Hoang Cap. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation

protocol TDCameraViewControllerDelegate: class {
    func didShotNewPicture(withPictureData: (UIImage, CLLocationCoordinate2D?))
}

class TDCameraViewController: UIViewController {
    
    // MARK:- Public method
    static func newInstance() -> TDCameraViewController {
        return UIStoryboard.init(name: "MyPictures", bundle: nil).instantiateViewController(withIdentifier: "TDCameraViewController") as! TDCameraViewController
    }
    
     // MARK:- Outlets
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var headerHeightConstraints: NSLayoutConstraint!
    // MARK:- Properties
    var session: AVCaptureSession?
    var input: AVCaptureDeviceInput?
    var stillImageOutput: AVCaptureStillImageOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var isBackCamera: Bool = true
    weak var delegate: TDCameraViewControllerDelegate?
    var long: Double = 0.0
    var lat: Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        APP_PERMISSIONS_MANAGER.checkLocationInUsePermissions(viewController: self, completionHandler: { (isAuthorized) in
            if isAuthorized {
                LOCATION_MANAGER.startLocationService()
            }
        }, onTapped: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.titleLabel.text = "Take A Picture"
        
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 2436:
                self.headerHeightConstraints.constant = 80
            default:
                self.headerHeightConstraints.constant = 64
            }
        }
    }
    
    // MARK:- Private method
    fileprivate func setupView() {
        self.loadCamere()
    }
    
    fileprivate func loadCamere() {
        //Initialize session an output variables this is necessary
        session = AVCaptureSession()
        stillImageOutput = AVCaptureStillImageOutput()
        var camera: AVCaptureDevice!
        if self.isBackCamera {
            camera = getDevice(position: .back)
        } else {
            camera = getDevice(position: .front)
        }
        do {
            input = try AVCaptureDeviceInput(device: camera)
        } catch let error as NSError {
            print(error)
            input = nil
        }
        if(session?.canAddInput(input) == true){
            session?.addInput(input)
            stillImageOutput?.outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]
            if(session?.canAddOutput(stillImageOutput) == true){
                session?.addOutput(stillImageOutput)
                previewLayer = AVCaptureVideoPreviewLayer(session: session)
                previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
                previewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.portrait
                previewLayer?.frame = CGRect(x: 0, y: 0, width: SCREEN_SIZE.width, height: SCREEN_SIZE.height - 64 - 100)
                previewView.layer.addSublayer(previewLayer!)
                session?.startRunning()
            }
        }
    }
    
    //Get the device (Front or Back)
    fileprivate func getDevice(position: AVCaptureDevicePosition) -> AVCaptureDevice? {
        let devices: NSArray = AVCaptureDevice.devices()! as NSArray
        for de in devices {
            let deviceConverted = de as! AVCaptureDevice
            if(deviceConverted.position == position){
                return deviceConverted
            }
        }
        return nil
    }
    
    fileprivate func reloadCamera() {
        session?.stopRunning()
        previewLayer?.removeFromSuperlayer()
        self.isBackCamera = !self.isBackCamera
        self.loadCamere()
    }
    
    // MARK:- Actions
    
    @IBAction func flipButtonTapped(_ sender: UIButton) {
        self.reloadCamera()
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cameraButtonTapped(_ sender: UIButton) {
        // Make sure capturePhotoOutput is valid
        if let videoConnection = stillImageOutput?.connection(withMediaType: AVMediaTypeVideo) {
            stillImageOutput?.captureStillImageAsynchronously(from: videoConnection) {
                (imageDataSampleBuffer, error) -> Void in
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                if let image = imageData?.uiImage {
                    CustomPhotoAlbum.sharedInstance.saveImage(image: image)
                    let pictureLocation = CLLocationCoordinate2DMake(LOCATION_MANAGER.lastKnownCoordinate!.latitude, LOCATION_MANAGER.lastKnownCoordinate!.longitude)
                    self.delegate?.didShotNewPicture(withPictureData: (image, pictureLocation))
                    self.dismiss(animated: true, completion: nil)
                }
                
            }
        }
    }
}
