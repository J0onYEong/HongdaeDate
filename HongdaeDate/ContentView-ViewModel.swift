//
//  ContentView-ViewModel.swift
//  HongdaeDate
//
//  Created by 최준영 on 2023/02/24.
//

import Foundation
import CoreLocation
import MapKit

@MainActor
class ContentView_ViewModel: ObservableObject {
    
    init() {
        locationDataManagerDelegate.viewModel = self
        localSearchCompleterDelegate.viewModel = self
    }
    
    // CoreLocation - Standard Service
    private let locationDataManagerDelegate = LocationDataManagerDelegate()
    @Published private(set) var currentLocation: CLLocation?
    // used for Map
    @Published var coordinateRegion = MKCoordinateRegion()
    
    let defaultCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.566535, longitude: 126.9779692), latitudinalMeters: 300, longitudinalMeters: 300)
    
    // Mapkit - Local Search
    // 기본값은 서울의 좌표이다.
    
    // 검색 범위로 현재 검색을하는 위치로 부터 2km반경의 위치정보를 수집한다.
    private let searchDistance: Double = 2000
    
    // 자동완성 결과를 전달받는 Delegate객체이다.
    private let localSearchCompleterDelegate = LocalSearchDelegate()
    
    @Published private(set) var searchAnnotationCollection: [MKMapItem] = []
    
}

// 현재 유저가있는 좌표를 파악하기위한 코드 wih CLLocation
extension ContentView_ViewModel {
    class LocationDataManagerDelegate: NSObject, CLLocationManagerDelegate {
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
            
            // delegate호출에 의한 ViewModel의 변호가 필요함으로 MainActor환경을 임의로 조성한다.
            Task { @MainActor in
                viewModel?.setCurrentLocation(current)
            }
        }
        
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print(error.localizedDescription)
            print(error.self)
        }
        
    }
    
    func setCurrentLocation(_ location: CLLocation) {
        objectWillChange.send()
        currentLocation = location
        coordinateRegion.center = location.coordinate
    }
    
    func reqeustCurrentLocation() {
        locationDataManagerDelegate.locationManager.requestLocation()
    }
}

// 유저가 입력한 문자열을 사용하여 맵을 검색
extension ContentView_ViewModel {
    
    // 마킹을 위한 임의의 Annotation아이템
    struct AnnotationLocation: Identifiable {
        let id = UUID()
        var coordinate: CLLocationCoordinate2D
        
        static var example = AnnotationLocation(coordinate: CLLocationCoordinate2D(latitude: 37.5515814, longitude: 126.9249751))
    }
    
    class LocalSearchDelegate: NSObject, MKLocalSearchCompleterDelegate {
        let searchCompleter = MKLocalSearchCompleter()
        
        var viewModel: ContentView_ViewModel?
        
        override init() {
            super.init()
            searchCompleter.delegate = self
        }
        
        // 성공할 경우
        func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
            Task { @MainActor in
                viewModel?.startSearching(completer.results)
            }
        }
        
        // 실패할 경우
        func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
            print("자동완성 실패", error.localizedDescription)
        }
    }
    
    func setCoordinateToDefault() {
        objectWillChange.send()
        coordinateRegion = defaultCoordinateRegion
    }
    
    func startSeachCompleter(searchString: String) {
        localSearchCompleterDelegate.searchCompleter.queryFragment = searchString
        // 현재 지도의 주앙을 기준으로 탐색을 한다.
        localSearchCompleterDelegate.searchCompleter.region = MKCoordinateRegion(center: coordinateRegion.center, latitudinalMeters: searchDistance, longitudinalMeters: searchDistance)
    }
    
    private func startSearching(_ data: [MKLocalSearchCompletion]) {
        objectWillChange.send()
        for completion in data {
            let mkLocalSearch = MKLocalSearch(request: MKLocalSearch.Request(completion: completion))
            Task {
                do {
                    let response = try await mkLocalSearch.start()
                    searchAnnotationCollection.append(contentsOf: response.mapItems)
                } catch {
                    print("startSearching에서 에러발생")
                }
            }
        }
    }
}

extension MKMapItem: Identifiable {
    
}

/*
 operation.addExecutionBlock {
     mkLocalSearch.start { response, error in
         Task { @MainActor in
             if let unwrapped = response {
                 self.objectWillChange.send()
                 await self.searchAnnotationCollection.addItem(unwrapped.mapItems)
             }
         }
     }
 }

 */
