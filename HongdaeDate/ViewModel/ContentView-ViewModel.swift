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
    
    // Mapkit - Local Search
    // 기본값은 홍익대학교의 좌표이다.
    static let defaultCoordinate = CLLocationCoordinate2D(latitude: 37.5515814, longitude: 126.9249751)
    // 지도의 범위에 해당하는 값으로 300m를 의미한다.
    static let defaultSpan: CLLocationDistance = 300
    
    // 검색 범위로 현재 검색을하는 위치로 부터 1km반경의 위치정보를 수집한다.
    private let searchDistance: Double = 1000
    
    // 자동완성 결과를 전달받는 Delegate객체이다.
    private let localSearchCompleterDelegate = LocalSearchDelegate()
    
    @Published private(set) var searchAnnotationCollection: [LocationItem] = []
    
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
                viewModel?.setCoordinateRegion(current.coordinate)
            }
        }
        
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print(error.localizedDescription)
            print(error.self)
        }
        
    }
    
    func setCoordinateRegion(_ coordinate: CLLocationCoordinate2D) {
        objectWillChange.send()
        currentLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: Self.defaultSpan, longitudinalMeters: Self.defaultSpan)
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
    
    func startSeachCompleter(searchString: String) {
        localSearchCompleterDelegate.searchCompleter.queryFragment = searchString
        // 현재 지도의 주앙을 기준으로 탐색을 한다.
        localSearchCompleterDelegate.searchCompleter.region = MKCoordinateRegion(center: coordinateRegion.center, latitudinalMeters: searchDistance, longitudinalMeters: searchDistance)
    }
    
    private func startSearching(_ data: [MKLocalSearchCompletion]) {
        objectWillChange.send()
        var resultItems: [LocationItem] = []
        Task {
            for completion in data {
                let mkLocalSearch = MKLocalSearch(request: MKLocalSearch.Request(completion: completion))
                
                do {
                    let response = try await mkLocalSearch.start()
                    for element in response.mapItems {
                        resultItems.append(LocationItem(mapItem: element))
                    }
                } catch {
                    print("startSearching에서 에러발생")
                }
            }
            // 검색의 시발점과 가까운 지역부터 앞에 위치되도록 정렬
            resultItems = resultItems.sorted { lhs, rhs in
                let lhsCoordinate = lhs.mapItem.placemark.coordinate
                let rhsCoordinate = rhs.mapItem.placemark.coordinate
                let currentCoordinate = coordinateRegion.center
                return lhsCoordinate.distanceBetween(currentCoordinate) < rhsCoordinate.distanceBetween(currentCoordinate)
            }
            
            // 정렬된 데이터를 전달한다.
            searchAnnotationCollection = resultItems
            
            // 가장가까운 장소로 맵의 중심을 이동시킨다.
            moveToSearchedPlace()
        }
    }
    
    // 검색된 장소로 화면을 이동시킨다.
    private func moveToSearchedPlace() {
        if !searchAnnotationCollection.isEmpty {
            if let item = searchAnnotationCollection.first {
                setCoordinateRegion(item.mapItem.placemark.coordinate)
            }
        }
    }
}

extension CLLocationCoordinate2D {
    
    // Haversine formula이다, 위도와 경도를 바탕으로 대략적인 거리(km)를 파악할 수 있다.
    private func degreesToRadians(degrees: Double) -> Double {
        return degrees * .pi / 180.0
    }
    
    func distanceBetween(_ target: CLLocationCoordinate2D) -> Double {
        // Earth's radius in kilometers
        let earthRadius = 6371.0
        
        let dLat = degreesToRadians(degrees: target.latitude - self.latitude)
        let dLon = degreesToRadians(degrees: target.longitude - self.longitude)
        
        let a = sin(dLat/2) * sin(dLat/2) + cos(degreesToRadians(degrees: self.latitude)) * cos(degreesToRadians(degrees: target.latitude)) * sin(dLon/2) * sin(dLon/2)
        let c = 2 * atan2(sqrt(a), sqrt(1-a))
        let distance = earthRadius * c
        
        return distance
    }
}


extension MKCoordinateRegion: Equatable {
    public static func == (lhs: MKCoordinateRegion, rhs: MKCoordinateRegion) -> Bool {
        lhs.center == rhs.center && lhs.span == rhs.span
    }
}

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

extension MKCoordinateSpan: Equatable {
    public static func == (lhs: MKCoordinateSpan, rhs: MKCoordinateSpan) -> Bool {
        lhs.latitudeDelta == rhs.latitudeDelta && lhs.longitudeDelta == rhs.longitudeDelta
    }
}

extension Array {
    // 요소의 인덱스를 전달
    func findIndex(_ element: Element) -> Int? where Element: Equatable {
        for i in 0..<self.count {
            if self[i] == element {
                return i
            }
        }
        return nil
    }
}


/*
 멀티 쓰레디를 사용하여 자료수집
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

