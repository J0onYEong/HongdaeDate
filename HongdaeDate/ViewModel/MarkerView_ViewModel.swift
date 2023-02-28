//
//  MarkerView_ViewModel.swift
//  HongdaeDate
//
//  Created by 최준영 on 2023/02/27.
//

import Foundation
import MapKit

@MainActor
class MarkerView_ViewModel: ObservableObject {
    static private let markerImageName: [MKPointOfInterestCategory : String] = [
        .cafe : "cup.and.saucer",
        .restaurant : "fork.knife.circle",
    ]
    
    func getImageName(_ type: MKPointOfInterestCategory?) -> String {
        if let unwrapped = type {
            return Self.markerImageName[unwrapped] ?? "questionmark.app"
        }
        return "questionmark.app"
    }
}
