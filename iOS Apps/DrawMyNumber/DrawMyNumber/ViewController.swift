/// Copyright (c) 2017 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import CoreML
import Vision

class ViewController: UIViewController {

  @IBOutlet weak var drawView: DrawView!
  @IBOutlet weak var predictLabel: UILabel!

  // TODO: Define lazy var classificationRequest

  override func viewDidLoad() {
    super.viewDidLoad()
    predictLabel.isHidden = true
  }

  @IBAction func clearTapped() {
    drawView.lines = []
    drawView.setNeedsDisplay()
    predictLabel.isHidden = true
  }

  @IBAction func predictTapped() {
    guard let context = drawView.getViewContext(),
      let inputImage = context.makeImage()
      else { fatalError("Get context or make image failed.") }
    // TODO: Perform request on model
    let ciImage = CIImage(cgImage: inputImage)
    let handler = VNImageRequestHandler(ciImage: ciImage)
    do {
        try handler.perform([classificationRequest])
    } catch {
        print(error)
    }
  }
    
   lazy var classificationRequest: VNCoreMLRequest = {
        // Load the ML model through its generated class and create a Vision request for it.
        do {
            let model = try VNCoreMLModel(for: MNIST_model().model)
            return VNCoreMLRequest(model: model, completionHandler: handleClassification)
        } catch {
            fatalError("Can't load Vision ML model: \(error).")
        }
    }()
    
    func handleClassification(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNClassificationObservation]
            else { fatalError("Unexpected result type from VNCoreMLRequest.") }
        guard let best = observations.first
            else { fatalError("Can't get best result.") }
        
        DispatchQueue.main.async {
            self.predictLabel.text = best.identifier
            self.predictLabel.isHidden = false
        }
    }
    
    

}

