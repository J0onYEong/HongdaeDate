//
//  MarkerView.swift
//  HongdaeDate
//
//  Created by 최준영 on 2023/02/27.
//

import SwiftUI
import MapKit

struct MarkerView: View {
    var item: LocationItem
    var perform: (() -> ())?
    
    var body: some View {
        VStack {
            Button {
                perform?()
            } label: {
                GeometryReader { geo in
                    
                    ZStack {
                        Circle()
                            .fill(.orange)
                            .padding(geo.size.width * 0.1)
                            .background(
                                Circle()
                                    .fill(.white)
                            )
                        Image(systemName: item.getImageName())
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.white)
                            .frame(width: geo.size.width * 0.5)
                    }
                    .position(x: geo.size.width/2, y: geo.size.height/2)
                }
            }
        }
    }
}

struct MarkerView_Previews: PreviewProvider {
    static var previews: some View {
        MarkerView(item: LocationItem.example)
    }
}
