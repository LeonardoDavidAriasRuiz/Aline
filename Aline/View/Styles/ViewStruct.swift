//
//  ViewStruct.swift
//  Aline
//
//  Created by Leonardo on 07/08/23.
//

import SwiftUI

struct Header: View {
    let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        Text(text)
            .font(.footnote)
            .textCase(.uppercase)
            .padding(.leading, 20)
            .foregroundStyle(.secondary)
    }
}

struct Footer: View {
    let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        Text(text).font(.footnote)
            .padding(.leading, 20)
            .foregroundStyle(.secondary)
    }
}
