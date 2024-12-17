//
//  ViewController.swift
//  FlowerPicker
//
//  Created by Jessica Parsons on 12/13/24.
//

import UIKit
import CoreML
import Vision
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    
    var wikiManager = WikiManager()
    
    let wikipediaURL = "https://en.wikipedia.org/w/api.php"

    let imagePicker = UIImagePickerController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        wikiManager.delegate = self
   
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        
    }
    
    // take the image that's been picked, make sure it's a UIImage, set it in our app, then move on to converting it to a CII image so our model can process it. then call our function that uses our converted image to see what it is
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userPickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            
            imageView.image = userPickedImage
            
            guard let convertedCIImage = CIImage(image: userPickedImage) else {
                fatalError("Could not convert into CIImage")
            }
            
            detect(flowerImage: convertedCIImage)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    
    func detect(flowerImage: CIImage) {
        
        // use the Flower model
        guard let model = try? VNCoreMLModel(for: MLModel(contentsOf: FlowerClassifier.urlOfModelInThisBundle)) else {
            fatalError("can't load ML model")
        }
        
        // create a Vision CoreML request, it will return our "request" and an error
        let request = VNCoreMLRequest(model: model) { request, error in
            
            //process the results
            let classification = request.results?.first as? VNClassificationObservation
            
            //do something with the results
            if let flowerName = classification?.identifier {
                self.navigationItem.title = flowerName.capitalized
                
                //give the flower name to Alamofire so we can grab its description
                self.requestInfo(flowerName: flowerName)
            }
        }
        
        //create a handler that specifies the image we want to classify
        let handler = VNImageRequestHandler(ciImage: flowerImage)
        
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
        
    }

    
    func requestInfo(flowerName: String) {
        
        let parameters : [String:String] = [
          "format" : "json",
          "action" : "query",
          "prop" : "extracts",
          "exintro" : "",
          "explaintext" : "",
          "titles" : flowerName,
          "indexpageids" : "",
          "redirects" : "1",
          ]
        
        AF.request(wikipediaURL, method: .get, parameters: parameters).response { (response) in
            
            switch response.result {
                case .success:
                    print("got the info")
                case .failure:
                print("didnt get the info")
            }
            
        }
    }
    
    
    @IBAction func cameraButton(_ sender: UIBarButtonItem) {
        
        present(imagePicker, animated: true, completion: nil)
        
        
    }
    

}


extension ViewController: WikiManagerDelegate {
    func didUpdateWiki(data: ParsedData) {
        //set the UI using data.whatever
        
        DispatchQueue.main.async {
            
        }
        
    }
    
    
}
