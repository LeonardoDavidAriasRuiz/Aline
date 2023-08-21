//
//  LoadingIfNotReady.swift
//  Aline
//
//  Created by Leonardo on 07/08/23.
//

import SwiftUI

struct LoadingIfNotReady<Content: View>: View  {
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
            }
        }
    }
}
