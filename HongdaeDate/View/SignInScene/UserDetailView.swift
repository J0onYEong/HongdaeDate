//
//  UserDetailView.swift
//  HongdaeDate
//
//  Created by 최준영 on 2023/03/08.
//

import SwiftUI
import GoogleSignIn

struct UserDetailView: View {
    private let user = GIDSignIn.sharedInstance.currentUser
    
    var body: some View {
        VStack {
            // withDimention은 Pixel x Pixel을 의미하며 여기서는 200 x 200 이미즈를 요구한다.
            UserProfileImage(url: user?.profile?.imageURL(withDimension: 240))
                .frame(width: 80)
            Text(user?.profile?.name ?? "Unknown")
        }
    }
}

struct UserProfileImage: View {
    var url: URL?
    
    var body: some View {
        if let profileUrl = url, let data = try? Data(contentsOf: profileUrl), let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
        }
        else {
            Image(systemName: "person.circle")
                .resizable()
                .scaledToFit()
        }
    }
}


struct UserDetailView_Previews: PreviewProvider {
    static var previews: some View {
        UserDetailView()
    }
}
