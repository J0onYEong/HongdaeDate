//
//  HongdaeDateApp.swift
//  HongdaeDate
//
//  Created by 최준영 on 2023/02/23.
//

import SwiftUI

@main
struct HongdaeDateApp: App {
    
    @StateObject var obj = UserEnvironment()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(obj)
        }
    }
}
