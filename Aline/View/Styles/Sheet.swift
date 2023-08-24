//
//  Sheet.swift
//  Aline
//
//  Created by Leonardo on 07/08/23.
//

import SwiftUI

struct Sheet<Content> : View where Content : View {
    @EnvironmentObject private var accentColor: AccentColor
    private var title: String
    private var tint: Color
    private let content: () -> Content
    
    init(section: MenuSection, @ViewBuilder content: @escaping () -> Content) {
        self.title = section.title
        self.tint = section.color
        self.content = content
    }
    
    var body: some View {
        ScrollView {
            VStack{
                content()
            }
            .frame(maxWidth: 800)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
        }
        .tint(tint)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.large)
        .onAppear(perform: onAppear)
    }
    
    private func onAppear() {
        accentColor.set(tint)
    }
}

struct FullSheet<Content: View>: View {
    @EnvironmentObject private var accentColor: AccentColor
    private let content: () -> Content
    private let tint: Color
    private let title: String
    
    init(section: MenuSection, @ViewBuilder content: @escaping () -> Content) {
        self.title = section.title
        self.tint = section.color
        self.content = content
    }
    
    var body: some View {
        ScrollView {
            VStack(content: content)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
        }
        .tint(tint)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.large)
        .onAppear(perform: onAppear)
    }
    
    private func onAppear() {
        accentColor.set(tint)
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
