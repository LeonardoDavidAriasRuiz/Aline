//
//  Sheet.swift
//  Aline
//
//  Created by Leonardo on 07/08/23.
//

import SwiftUI

struct Sheet<Content: View>: View {
    let title: String
    let content: () -> Content
    
    init(title: String, @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.title = title
    }
    
    var body: some View {
        ScrollView {
            VStack(content: content)
                .frame(maxWidth: 800)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.large)
    }
}

struct FullSheet<Content: View>: View {
    let content: () -> Content
    let color: Color
    let title: String
    
    init(color: Color, title: String, @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.color = color
        self.title = title
    }
    
    var body: some View {
        VStack {
            HStack {}.frame(maxWidth: .infinity, maxHeight: 1).background(.white)
            ScrollView {
                VStack(content: content)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.background)
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SheetWithoutScroll<Content: View>: View {
    let content: () -> Content
    let color: Color
    let title: String
    
    init(color: Color, title: String, @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.color = color
        self.title = title
    }
    
    var body: some View {
        ZStack {
            VStack {
                HStack {}.frame(maxWidth: .infinity, maxHeight: 1).background(.white)
                Spacer()
            }
            
            VStack(content: content)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Gradient(colors: [color, Color.background, Color.background]))
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
