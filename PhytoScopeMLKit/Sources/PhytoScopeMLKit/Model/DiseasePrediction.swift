//
//  DiseasePrediction.swift
//  PhytoScopeMLKit
//
//  Created by Daniil Shmoylov on 10.05.2025.
//

public struct DiseasePrediction {
    
    /// The name of the object or scene the image classifier recognizes in an image.
    
    public let classification: String
    
    /// The image classifier's confidence as a percentage string.
    /// The prediction string doesn't include the % symbol in the string.
    
    public let confidencePercentage: String
}
