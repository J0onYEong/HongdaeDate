//
//  MainSearchView.swift
//  HongdaeDate
//
//  Created by 최준영 on 2023/02/26.
//

import SwiftUI

struct MainSearchView: View {
    @Binding var inputString: String
    @FocusState var focusState
    
    var submit: ( () -> () )?
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass.circle.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(.secondary.opacity(0.75))
                .frame(maxHeight: 30)
            TextField("위치정보를 입력하세요", text: $inputString)
                .frame(minHeight: 40)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .focused($focusState)
                .foregroundColor(.black)
        }
        .padding(5)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(focusState ? 0.5 : 0.3))
                .shadow(radius: 10)
        )
        .onSubmit {
            submit?()
        }
        
    }
}

struct MainSearchView_Previews: PreviewProvider {
    static var previews: some View {
        MainSearchView(inputString: Binding<String>.constant("")) {
            
        }
    }
}
