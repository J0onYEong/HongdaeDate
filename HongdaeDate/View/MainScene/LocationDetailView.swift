//
//  LocationDetailView.swift
//  HongdaeDate
//
//  Created by 최준영 on 2023/02/28.
//

import SwiftUI

struct LocationDetailView: View {
    @EnvironmentObject var userEnvironment: UserEnvironment
    
    var item: LocationItem
    
    var next: (()->())?
    
    var dismiss: (()->())?
    
    let viewHeight: CGFloat = 0.3
    
    // 화면에 표시되지 않는 디테일뷰 영역
    let emptySpace = 100.0
    
    let cornerRadius = 40.0
    
    let swipeDistance = 75.0
    
    // Gesture guide
    @State private var imageOpacity = 0.0
    @State private var textOpacity = 0.0
    @State private var imageOffset = CGSize(width: 0, height: 0)
    
    
    var body: some View {
        
        GeometryReader { geo in
            ZStack {
                VStack(spacing: 0) {
                    Button {
                        dismiss?()
                    } label: {
                        HStack {
                            Image(systemName: "arrow.down.to.line")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.secondary)
                                .padding([.top, .bottom], 10)
                        }
                        .frame(width: geo.size.width, height: cornerRadius)
                    }
                    HStack {
                        VStack {
                            Text(item.mapItem.placemark.name ?? "Unknown place")
                                .font(.title)
                                .padding(5)
                            // 세세한 정보
                        }
                        Spacer()
                    }
                    Rectangle()
                        .fill(.secondary)
                        .frame(height: 1)
                    HStack {
                        VStack(alignment: .hstacksInVstack) {
                            HStack {
                                Image(systemName: "phone.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(.green)
                                Text(item.mapItem.phoneNumber ?? "010-1111-1111")
                                    .alignmentGuide(HorizontalAlignment.hstacksInVstack) { d in
                                        d[.leading]
                                    }
                            }
                            .frame(height: 20)
                            
                            HStack {
                                Text("링크")
                                    .font(.callout)
                                Text(item.mapItem.url?.absoluteString ?? "no url")
                                    .alignmentGuide(HorizontalAlignment.hstacksInVstack) { d in
                                        d[.leading]
                                    }
                                    .font(.caption)
                            }
                        }
                        Spacer()
                    }
                    .padding([.leading, .top], 5)
                    
                    
                    Spacer()
                    
                }
                .frame(width: geo.size.width, height: geo.size.height * viewHeight + emptySpace)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                .shadow(color: .secondary, radius: 10)
                .position(x: geo.size.width/2, y: geo.size.height * (1-viewHeight/2) + emptySpace/2)
                
                
                // Swipe guide
                if userEnvironment.userData.isFirstAccess {
                    VStack {
                        Image(systemName: "hand.point.up.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geo.size.width * 0.2)
                            .position(x: geo.size.width, y: geo.size.height * (1 - viewHeight + viewHeight/2))
                            .foregroundColor(.blue.opacity(imageOpacity))
                            .offset(imageOffset)
                            .onAppear {
                                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                                    imageOpacity = 1.0
                                    textOpacity = 1.0
                                    withAnimation(.easeOut(duration: 1.5)) {
                                        imageOffset = CGSize(width: -200, height: 0)
                                        imageOpacity = 0
                                    }
                                    withAnimation(.easeIn(duration: 2.0)) {
                                        textOpacity = 0
                                    }
                                }
                                Timer.scheduledTimer(withTimeInterval: 4.0, repeats: false) { _ in
                                    userEnvironment.changeAccessState(false)
                                }
                            }
                        Spacer()
                        Text("왼쪽으로 화면을 스와이프 하세요")
                            .font(.caption)
                            .foregroundColor(.blue)
                            .opacity(textOpacity)
                    }
                }
            }
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    let vector = value.translation
                    
                    // 왼쪽으로 스와이프 시
                    if vector.width < 0, abs(vector.width) > swipeDistance {
                        next?()
                    }
                    // 아래로 스와이프 시
                    if vector.height > 0, abs(vector.height) > swipeDistance-10 {
                        dismiss?()
                    }
                }
        )
    }
}

extension HorizontalAlignment {
    enum CustomAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            return 0
        }
    }
    
    static let hstacksInVstack = HorizontalAlignment(CustomAlignment.self)
}




struct LocationDetailView_Previews: PreviewProvider {
    static var previews: some View {
        LocationDetailView(item: LocationItem.example)
            .environmentObject(UserEnvironment())
    }
}
