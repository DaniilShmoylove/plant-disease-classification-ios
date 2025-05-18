//
//  PlantRecognitionService.swift
//  PhytoScopeMLKit
//
//  Created by Daniil Shmoylov on 10.05.2025.
//

import CoreML
@preconcurrency import Vision
import UIKit

public typealias ImagePredictionHandler = (
    _ predictions: [DiseasePrediction]?
) -> Void

final public class PlantRecognitionService {
    private static let imageClassifier = createImageClassifier()
    
    private var predictionHandlers = [VNRequest: ImagePredictionHandler]()
}

public extension PlantRecognitionService {
    var modelDescription: MLModelDescription? {
        let model = try? PhotoScope_image_classification(
            configuration: .init()
        )
        
        return model?.model.modelDescription
    }
    
    func makePredictions(
        for imageData: Data,
        completionHandler: @escaping ImagePredictionHandler
    ) throws {
        
        // Create NSImage (macOS)
        
#if canImport(AppKit)
        guard
            let nsImage = NSImage(data: imageData),
            let photoImage = nsImage.cgImage(
                forProposedRect: nil,
                context: nil,
                hints: nil
            )
        else {
            fatalError("Photo doesn't have underlying CGImage.")
        }
        
        //FIXME: - Fix macos image orientation
        
        let orientation: CGImagePropertyOrientation = .up
        
        // Create UIImage (iOS)
        
#elseif canImport(UIKit)
        guard
            let uiImage = UIImage(data: imageData),
            let photoImage = uiImage.cgImage
        else {
            fatalError("Photo doesn't have underlying CGImage.")
        }
        
        let orientation = CGImagePropertyOrientation(uiImage.imageOrientation)
#else
        fatalError("AppKit or UIKit cannot be imported")
#endif
        
        let imageClassificationRequest = self.createImageClassificationRequest()
        self.predictionHandlers[imageClassificationRequest] = completionHandler
        
        let handler = VNImageRequestHandler(
            cgImage: photoImage,
            orientation: orientation
        )
        
        let requests: [VNRequest] = [imageClassificationRequest]
        
        // Start the image classification request.
        
        try handler.perform(requests)
    }
}

private extension PlantRecognitionService {
    static func createImageClassifier() -> VNCoreMLModel {
        let defaultConfig = MLModelConfiguration()
        defaultConfig.modelDisplayName = "Plant disease"
        
        let imageClassifierWrapper = try? PhotoScope_image_classification(
            configuration: defaultConfig
        )
        
        guard let imageClassifier = imageClassifierWrapper else {
            fatalError("App failed to create an image classifier model instance.")
        }
        
        let imageClassifierModel = imageClassifier.model
        
        guard let imageClassifierVisionModel = try? VNCoreMLModel(for: imageClassifierModel) else {
            fatalError("App failed to create a `VNCoreMLModel` instance.")
        }
        
        return imageClassifierVisionModel
    }
    
    func createImageClassificationRequest() -> VNImageBasedRequest {
        
        // Create an image classification request with an image classifier model.
        
        let imageClassificationRequest = VNCoreMLRequest(
            model: PlantRecognitionService.imageClassifier,
            completionHandler: visionRequestHandler
        )
        
        imageClassificationRequest.imageCropAndScaleOption = .centerCrop
        return imageClassificationRequest
    }
    
    func visionRequestHandler(
        _ request: VNRequest,
        error: Error?
    ) {
        
        // Remove the caller's handler from the dictionary and keep a reference to it.
        
        guard
            let predictionHandler = self.predictionHandlers.removeValue(forKey: request)
        else {
            fatalError("Every request must have a prediction handler.")
        }
        
        /// Start with a `nil` value in case there's a problem.
        
        var predictions: [DiseasePrediction]? = nil
        
        // Call the client's completion handler after the method returns.
        
        defer {
            
            // Send the predictions back to the client.
            
            predictionHandler(predictions)
        }
        
        // Check for an error first.
        
        if let error = error {
            print("Vision image classification error...\n\n\(error.localizedDescription)")
            return
        }
        
        /// Check that the results aren't `nil`.
        
        if request.results == nil {
            print("Vision request had no results.")
            return
        }
        
        /// Cast the request's results as an `VNClassificationObservation` array.
        
        guard let observations = request.results as? [VNClassificationObservation] else {
            
            // Image classifiers, like MobileNet, only produce classification observations.
            // However, other Core ML model types can produce other observations.
            // For example, a style transfer model produces `VNPixelBufferObservation` instances.
            
            print("VNRequest produced the wrong result type: \(type(of: request.results)).")
            return
        }
        
        // Create a prediction array from the observations.
        
        predictions = observations.map { observation in
            
            /// Convert each observation into an `Prediction` instance.
            
            DiseasePrediction(
                classification: observation.identifier,
                confidencePercentage: observation.confidencePercentageString
            )
        }
    }
}
