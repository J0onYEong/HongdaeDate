//
//  LocationItem.swift
//  HongdaeDate
//
//  Created by 최준영 on 2023/02/28.
//

import Foundation
import MapKit

// Location에 대한 정보를 담고 있는 구조체이다.
struct LocationItem: Identifiable, Equatable {
    let id = UUID()
    var mapItem: MKMapItem
    
    static private let markerImageName: [MKPointOfInterestCategory : String] = [
        .cafe : "cup.and.saucer",
        .restaurant : "fork.knife.circle",
    ]
    
    func getImageName() -> String {
        if let unwrapped = mapItem.pointOfInterestCategory {
            return Self.markerImageName[unwrapped] ?? "questionmark.app"
        }
        return "questionmark.app"
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
    static let example = LocationItem(mapItem: MKMapItem())
}
