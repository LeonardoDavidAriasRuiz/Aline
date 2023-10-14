//
//  Styles.swift
//  Aline
//
//  Created by Leonardo David Arias Ruiz on 29/03/23.
//

import SwiftUI

struct ButtonColor: ViewModifier {
     let color: Color
    
    func body(content: Content) -> some View {
        content
            .padding(10)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .foregroundStyle(Color.white)
    }
}
