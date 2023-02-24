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
    
    
    // Binding state
    @State private var coordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 35.5936, longitude: 129.352), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
    
    var body: some View {
        VStack {
            ZStack {
                Map(coordinateRegion: $coordinateRegion)
                    .onChange(of: viewModel.currentLocation) { current in
                        if let location = current {
                            coordinateRegion.center = location.coordinate
                        }
                    }
                GeometryReader { geo in
                    Button {
                        viewModel.reqeustCurrentLocation()
                    } label: {
                        Image(systemName: "location.circle")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.secondary)
                            .frame(width: 70, height: 70)
                            .position(x: geo.size.width*0.9, y: geo.size.height*0.95)
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
