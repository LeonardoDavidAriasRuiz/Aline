//
//  WhiteArea.swift
//  Aline
//
//  Created by Leonardo on 07/08/23.
//

import SwiftUI

struct WhiteArea<Content: View>: View {
    let content: () -> Content
    let spacing : CGFloat
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.spacing = 0
    }
    
    init(spacing: CGFloat, @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.spacing = spacing
    }
    
    var body: some View {
        VStack(spacing: spacing, content: content)
            .padding(.horizontal, 20)
            .padding(.vertical, spacing == 0 ? 0 : 10)
            .frame(maxWidth: .infinity)
            .background(Color.whiteArea)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .shadow(color: .black.opacity(0.05), radius: 10)
    }
}
