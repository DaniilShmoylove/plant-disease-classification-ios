//
//  PlantRecognitionDependencyKey.swift
//  PhytoScopeMLKit
//
//  Created by Daniil Shmoylov on 10.05.2025.
//

import ComposableArchitecture

extension DependencyValues {
    var plantRecognitionClient: PlantRecognitionClient {
        get { self[PlantRecognitionClient.self] }
        set { self[PlantRecognitionClient.self] = newValue }
    }
}
