//
//  Animation.swift
//  HongdaeDate
//
//  Created by 최준영 on 2023/03/01.
//

import Foundation
import SwiftUI

struct OffsetEffect: ViewModifier {
    var offset: CGSize
    func body(content: Content) -> some View {
        content.offset(offset)
    }
}


extension AnyTransition {
    static func showUpOffsetEffect(start: CGSize, destination: CGSize) -> AnyTransition {
        .modifier(active: OffsetEffect(offset: start), identity: OffsetEffect(offset: destination))
    }
    
    static func showDownOffsetEffect(start: CGSize, destination: CGSize) -> AnyTransition {
        .modifier(active: OffsetEffect(offset: destination), identity: OffsetEffect(offset: start))
    }
}
