//
//  WhiteArea.swift
//  Aline
//
//  Created by Leonardo on 07/08/23.
//

import SwiftUI

struct WhiteArea<Content: View>: View {
     let content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        VStack(content: content)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

#Preview {
    Sheet(title: "WhiteArea") {
        WhiteArea {
            Text("WhiteArea")
        }
        
    }
}
