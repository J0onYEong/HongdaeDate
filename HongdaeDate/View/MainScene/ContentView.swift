//
//  ContentView.swift
//  HongdaeDate
//
//  Created by 최준영 on 2023/02/23.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var viewModel = ContentView_ViewModel()
    
    // - Binding state
    @State private var coordinateRegion = MKCoordinateRegion(center: ContentView_ViewModel.defaultCoordinate, latitudinalMeters: ContentView_ViewModel.defaultSpan, longitudinalMeters: ContentView_ViewModel.defaultSpan)
    @State private var selectionItem: LocationItem?
    
    // 유저가 검색할때 쓰이는 문자열
    @State private var mainSearchString = ""
    
    var body: some View {
        VStack {
            ZStack {
                // 메인 맵
                Map(coordinateRegion: $coordinateRegion, interactionModes: .all, showsUserLocation: true, userTrackingMode: .none, annotationItems: viewModel.searchAnnotationCollection, annotationContent: { locationItem in
                    MapAnnotation(coordinate: locationItem.mapItem.placemark.coordinate) {
                        MarkerView(item: locationItem) {
                            withAnimation {
                                selectionItem = locationItem
                            }
                        }
                        .frame(width: 30, height: 30)
                    }
                })
                .ignoresSafeArea()
                .onAppear {
                    viewModel.reqeustCurrentLocation()
                }
                .onChange(of: viewModel.coordinateRegion) { newValue in
                    // ViewModel의 coordinateRegion이 변경되면 View에 반영하는 코드이다.
                    withAnimation {
                        coordinateRegion = newValue
                    }
                }
                
                // 검색창
                GeometryReader { geo in
                    MainSearchView(inputString: $mainSearchString) {
                        // 현재 지도의 중심을 ViewModel에 전달한다.
                        viewModel.setCoordinateRegion(coordinateRegion.center)
                        
                        // 현재지도의 중심을 기준으로 검색을 시작한다.
                        viewModel.startSeachCompleter(searchString: mainSearchString)
                    }
                        .padding([.leading, .trailing], 10)
                        .position(x: geo.size.width/2, y: geo.size.height/15)
                        .onChange(of: viewModel.searchAnnotationCollection) { array in
                            if !array.isEmpty {
                                withAnimation {
                                    selectionItem = array[0]
                                }
                            }
                        }
                }
                
                // 현재 디바이스로 이동하는 버튼
                GeometryReader { geo in
                    Button {
                        withAnimation {
                            viewModel.reqeustCurrentLocation()
                        }
                    } label: {
                        Image(systemName: "location.circle")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.secondary)
                            .frame(width: 50, height: 50)
                    }
                    .position(x: geo.size.width-40, y: geo.size.height-40)
                }
                
                if let item = selectionItem {
                    if let index = viewModel.searchAnnotationCollection.findIndex(item) {
                        let nextIndex = index == viewModel.searchAnnotationCollection.count-1 ? 0 : index+1
                        LocationDetailView(item: item) {
                            // Sheet의 아이템을 변경한다.
                            let nextItem = viewModel.searchAnnotationCollection[nextIndex]
                            selectionItem = nextItem
                            
                            withAnimation {
                                // 현재 세부정보를 보고있는 장소로 맵의 중앙을 이동시킨다.
                                viewModel.setCoordinateRegion(nextItem.mapItem.placemark.coordinate)
                            }
                        } dismiss: {
                            withAnimation {
                                selectionItem = nil
                            }
                        }
                        .transition(.move(edge: .bottom))
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
