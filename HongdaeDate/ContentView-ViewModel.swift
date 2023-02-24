//
//  ContentView-ViewModel.swift
//  HongdaeDate
//
//  Created by 최준영 on 2023/02/24.
//

import Foundation
import CoreLocation
import MapKit

class ContentView_ViewModel: ObservableObject {
    class LocationDataManager: NSObject, CLLocationManagerDelegate {
        var locationManager = CLLocationManager()
        var viewModel: ContentView_ViewModel?
        
        override init() {
            super.init()
            // delegate 오브젝트를 할당한다.
            locationManager.delegate = self
        }
        
        func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            switch manager.authorizationStatus {
            case .notDetermined:
                manager.requestWhenInUseAuthorization()
            case .authorizedWhenInUse:
                manager.requestAlwaysAuthorization()
            default:
                return;
            }
        }
        
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            // 배열의 끝에 위치한 요소가 가장최근 데이터이다.
            let current = locations[locations.count-1]
            viewModel?.setCurrentLocation(current)
        }
        
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print(error.localizedDescription)
            print(error.self)
        }
        
    }
    private let locationDataManager = LocationDataManager()
    @Published private(set) var currentLocation: CLLocation?
    
    init() {
        locationDataManager.viewModel = self
    }
    
    // CoreLocation
    func setCurrentLocation(_ location: CLLocation) {
        objectWillChange.send()
        currentLocation = location
    }
    
    func reqeustCurrentLocation() {
        locationDataManager.locationManager.requestLocation()
    }
    
    
}

