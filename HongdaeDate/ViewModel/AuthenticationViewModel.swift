//
//  AuthenticationViewModel.swift
//  HongdaeDate
//
//  Created by 최준영 on 2023/03/08.
//

import Foundation
import Firebase
import GoogleSignIn

class AuthenticationViewModel: ObservableObject {

    @Published var state: State = .signedOut
    
    func signin() {
        // 이전에 signin한 기록이 있으면 restore한다.
        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            GIDSignIn.sharedInstance.restorePreviousSignIn { [unowned self] user, error in
                authenticateUser(user: user, error: error)
            }
        } else {
            // target설정에서 입력한 client id를 가져온다, app()은 처음에 생성한 default Firebase app이다.
            guard let clientId = FirebaseApp.app()?.options.clientID else {
                return
            }
            
            // ClientId를 가진 configuration을 전달한다.
            let configuration = GIDConfiguration(clientID: clientId)
            GIDSignIn.sharedInstance.configuration = configuration
            
            // SwiftUI는 ViewController를 사용하지 않기때문에 `UIApplication`에서 rootViewcontroller를 추출할 수 있다.
            // 직접적으로 `UIWindow`를 사용하는 것은 deprecated 되어서 `UIWindowScene`을 사용하여 접근해야 한다.
            guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
                return
            }
            guard let rootViewController = scene.windows.first?.rootViewController else {
                return
            }
            
            GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [unowned self] signInResult, error in
                authenticateUser(user: signInResult?.user, error: error)
            }
            
        }
    }
    
    private func authenticateUser(user: GIDGoogleUser?, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        // accessToken과 idToken을 user로부터 가져와서 AuthCredential(인증 자격)을 만들다
        guard let accessToken = user?.accessToken, let idToken = user?.idToken else {
            return
        }
        
        let credentail = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: accessToken.tokenString)
        
        Auth.auth().signIn(with: credentail) { [unowned self] (_, error) in
            if let error = error {
                print("SignIn 실패", error.localizedDescription)
            } else {
                self.state = .signedIn
            }
        }
        
    }
}

extension AuthenticationViewModel {
    enum State {
        case signedIn
        case signedOut
    }
}
