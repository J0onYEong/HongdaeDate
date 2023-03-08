//
//  HongdaeDateApp.swift
//  HongdaeDate
//
//  Created by 최준영 on 2023/02/23.
//

import SwiftUI
import Firebase


@main
struct HongdaeDateApp: App {
    
    @StateObject var userEnvironment = UserEnvironment()
    @StateObject var authenticationViewModel = AuthenticationViewModel()
    
    init() {
        self.setupAuthentication()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userEnvironment)
                .environmentObject(authenticationViewModel)
        }
    }
}

extension HongdaeDateApp {
    private func setupAuthentication() {
        /// `configure`매서드는 default파이어베이스 어플리케이션을 만들어준다.
        FirebaseApp.configure()
    }
}
