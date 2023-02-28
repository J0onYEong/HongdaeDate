//
//  LocationDetailView.swift
//  HongdaeDate
//
//  Created by 최준영 on 2023/02/28.
//

import SwiftUI

struct LocationDetailView: View {
    @Binding var item: LocationItem?
    
    var next: (()->())?
    
    let viewHeight: CGFloat = 0.5
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                HStack {
                    Button("닫기") {
                        item = nil
                    }
                    .padding(20)
                    Spacer()
                    if let action = next {
                        Button("다음", action: action)
                            .padding(20)
                    }
                }
                GeometryReader { geo1 in
                    HStack {
                        Text(item?.mapItem.placemark.name ?? "Unknown place")
                            .font(.largeTitle.bold())
                            .padding([.leading, .trailing], 10)
                        Image(systemName: item?.getImageName() ?? "")
                            .resizable()
                            .scaledToFit()
                            .frame(height: geo1.size.height * 0.8)
                    }
                    .frame(width: geo1.size.width, height: geo1.size.height)
                    .position(x: geo1.size.width/2, y: geo1.size.height/2)
                }
                .frame(height: geo.size.height * 0.1)
                Rectangle()
                    .fill(.secondary)
                    .frame(height: 2)
                Spacer()
                
            }
            .frame(width: geo.size.width, height: geo.size.height * viewHeight + 100)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 40))
            .position(x: geo.size.width/2, y: geo.size.height * (1-viewHeight/2) + 50)
        }
        .ignoresSafeArea()
    }
}

