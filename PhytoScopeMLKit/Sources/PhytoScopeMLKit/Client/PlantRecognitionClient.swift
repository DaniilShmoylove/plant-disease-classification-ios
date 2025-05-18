//
//  File.swift
//  PhytoScopeMLKit
//
//  Created by Daniil Shmoylov on 10.05.2025.
//

import ComposableArchitecture
import Foundation

@DependencyClient
struct PlantRecognitionClient: Sendable {
    var predictDiseases: @Sendable (Data) async throws -> ()
}

extension PlantRecognitionClient: DependencyKey {
    static var liveValue: PlantRecognitionClient {
        let plantRecognitionService = PlantRecognitionService()
        return Self(
            predictDiseases: { data in
//                plantRecognitionService.makePredictions(
//                    for: data
//                ) { predictions in
//                    
//                }
            }
        )
    }
}


