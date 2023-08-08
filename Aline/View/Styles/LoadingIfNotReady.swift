//
//  LoadingIfNotReady.swift
//  Aline
//
//  Created by Leonardo on 07/08/23.
//

import SwiftUI

struct LoadingIfNotReady<Content: View>: View  {
    @Binding  var done: Bool
     let content: () -> Content
    
    var body: some View {
        ZStack {
            content()
            if !done {
                LoadingView()
            }
        }
    }
}
