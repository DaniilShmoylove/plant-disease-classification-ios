//
//  PlantRecognitionFeature.swift
//  PhytoScopeMLKit
//
//  Created by Daniil Shmoylov on 10.05.2025.
//

import ComposableArchitecture

@Reducer
public struct PlantRecognitionFeature: Sendable {
    public init() { }
    
    @Dependency(\.plantRecognitionClient)
    private var plantRecognitionClient
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .detectDiseases:
                return .run { send in
                    try await plantRecognitionClient.predictDiseases(.init())
                }
            }
        }
    }
}

public extension PlantRecognitionFeature {
    @ObservableState
    struct State {
        
    }
}

public extension PlantRecognitionFeature {
    @CasePathable
    enum Action: Equatable {
        case detectDiseases
    }
}
