//
//  WelcomeView.swift
//  Aline
//
//  Created by Leonardo on 25/10/23.
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        GeometryReader { geometry in
            AnimatedCircle(color: Color.green, geometry: geometry)
            AnimatedCircle(color: Color.blue, geometry: geometry)
            AnimatedCircle(color: Color.red, geometry: geometry)
            AnimatedCircle(color: Color.orange, geometry: geometry)
        }.background(Color.background)
    }
}

struct AnimatedCircle: View {
    @State private var timer = Timer.publish(every: 0.2, on: .main, in: .common).autoconnect()
    @State private var offset: CGSize = CGSize(width: CGFloat.random(in: -2000...2000), height: CGFloat.random(in: -2000...2000))
    @State private var toDown: Bool = Bool.random()
    @State private var toRight: Bool = Bool.random()
    @State private var tapped: Bool = false
    var color: Color
    var geometry: GeometryProxy
    let verticalSpeed: CGFloat = CGFloat.random(in: 80...200)
    let horizontalSpeed: CGFloat = CGFloat.random(in: 80...200)
    
    var body: some View {
        Circle().frame(width: toDown ? 80 : 300).offset(offset)
            .foregroundStyle(color)
            .onReceive(timer) { _ in
                withAnimation(.spring(duration: 2)) {
                    toDown = (offset.height > geometry.size.height - 300) ? false : (offset.height < 0 + 100) ? true : toDown
                    toRight = (offset.width > geometry.size.width - 300) ? false : (offset.width < 0 + 200) ? true : toRight
                    offset.width += toRight ? horizontalSpeed : -horizontalSpeed
                    offset.height += toDown ? verticalSpeed : -verticalSpeed
                }
            }
    }
}
