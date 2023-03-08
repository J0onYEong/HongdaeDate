//
//  SignInView.swift
//  HongdaeDate
//
//  Created by 최준영 on 2023/03/08.
//

import SwiftUI
import GoogleSignInSwift

/// 로그인이 필요한 경우에만 호출되는 View이다.
struct SignInView: View {
    @EnvironmentObject var authenticateViewModel: AuthenticationViewModel
    
    @ObservedObject var buttonVm = GoogleSignInButtonViewModel()
    
    var body: some View {
        VStack {
            Text("로그인 방법을 선택하세요")
            GoogleSignInButton(viewModel: buttonVm) {
                authenticateViewModel.signin()
            }
            .accessibilityIdentifier("GoogleSignInButton")
            .accessibility(hint: Text("Sign in with Google button."))
            .padding()
            .onAppear {
                /// 뷰모델을 활용하여 버튼옵션을 변경할 수 있다.
                buttonVm.style = .standard
                buttonVm.scheme = .light
            }
            
        }
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
            .environmentObject(AuthenticationViewModel())
    }
}
