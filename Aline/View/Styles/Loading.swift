//
//  Loading.swift
//  Aline
//
//  Created by Leonardo on 08/09/23.
//

import SwiftUI

struct Loading<Content: View>: View  {
    @Binding  var isLoading: Bool
    let content: () -> Content
    
    init(_ isLoading: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) {
        self._isLoading = isLoading
        self.content = content
    }
    
    var body: some View {
        ZStack {
            content()
            if isLoading {
                LoadingView()
                VStack {
                    Spacer()
                    Button("The View stops") {
                        isLoading = false
                    }
                    .padding(.bottom, 20)
                }
            }
        }
    }
}


