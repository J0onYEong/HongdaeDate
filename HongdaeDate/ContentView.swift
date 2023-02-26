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
    
    // 유저가 검색할때 쓰이는 문자열
    @State private var mainSearchString = ""
    
    var body: some View {
        VStack {
            ZStack {
                // 메인 맵
                Map(coordinateRegion: $viewModel.coordinateRegion, interactionModes: .all, showsUserLocation: true, userTrackingMode: .none, annotationItems: viewModel.searchAnnotationCollection, annotationContent: { item in
                    MapMarker(coordinate: item.placemark.coordinate, tint: .red)
                })
                .ignoresSafeArea()
                .onAppear {
                    viewModel.setCoordinateToDefault()
                    viewModel.reqeustCurrentLocation()
                }
                
                // 검색창
                GeometryReader { geo in
                    MainSearchView(inputString: $mainSearchString) {
                        viewModel.startSeachCompleter(searchString: mainSearchString)
                    }
                        .padding([.leading, .trailing], 10)
                        .position(x: geo.size.width/2, y: geo.size.height/15)
                }
                
                // 현재 디바이스로 이동하는 버튼
                GeometryReader { geo in
                    Button {
                        viewModel.reqeustCurrentLocation()
                    } label: {
                        Image(systemName: "location.circle")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.secondary)
                            .frame(width: 50, height: 50)
                    }
                    .position(x: geo.size.width-40, y: geo.size.height-40)
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
