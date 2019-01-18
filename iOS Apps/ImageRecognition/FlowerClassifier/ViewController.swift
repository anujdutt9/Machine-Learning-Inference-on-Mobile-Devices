//
//  ViewController.swift
//  ImageRecognition
//
//  Created by Anuj Dutt on 9/3/18.
//  Copyright © 2018 Anuj Dutt. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageLabel: UITextView!
    
    // Array containing image names
    let images = ["daisy.jpg", "dandelion.png", "rose.jpg", "sunflower.jpg", "tulips.jpg"]
    var imageIndex = 0
    
    // Instance of CoreML Model
    private var model: Flowers = Flowers()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Action Button to show next image in Array
    @IBAction func nextImage(_ sender: Any) {
        if (imageIndex > self.images.count - 1){
            imageIndex = 0
        }
        let img = UIImage(named: self.images[imageIndex])
        self.imageView.image = img
        
        // Resize the Image before sending into CoreML Model
        let resizedImage = img?.resizeTo(size: CGSize(width: 224, height: 224))
        
        // The CoreML Model requires the image input as CVPixelBuffer format
        let buffer = resizedImage?.toBuffer()
        
        // Make prediction using the Model on Image
        let prediction = try! self.model.prediction(image: buffer!)
        self.imageLabel.text = "The model thinks that it is a \(prediction.label) with a probability of \(prediction.labelProbability[prediction.label] ?? 0)."
        
        imageIndex += 1
    }
    
}

// Extension to Resize the Image to the Required Size Input by the CoreML Model
extension UIImage{
    
    // Function to Resize the Image
    func resizeTo(size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        self.draw(in: CGRect(origin: CGPoint.zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return resizedImage
    }
    
    // Function to convert the image to form CVPixelBuffer
    func toBuffer() -> CVPixelBuffer? {
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                     kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(self.size.width), Int(self.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        
        let context = CGContext(data: pixelData, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        return pixelBuffer!
    }
}
