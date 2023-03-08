//
//  UserView.swift
//  HongdaeDate
//
//  Created by 최준영 on 2023/03/08.
//

import SwiftUI

struct UserView: View {
    @EnvironmentObject var authenticateVm: AuthenticationViewModel
    
    
    var body: some View {
        switch authenticateVm.state {
        case .signedIn:
            UserDetailView()
        case.signedOut:
            SignInView()
        }
    }
}

struct UserView_Previews: PreviewProvider {
    static var previews: some View {
        UserView()
            .environmentObject(AuthenticationViewModel())
    }
}
