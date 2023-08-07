//
//  LoadingView.swift
//  Aline
//
//  Created by Leonardo on 29/06/23.
//

import SwiftUI

struct LoadingView: View {
    @State private var timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    @State private var step = 0
    @State private var rectHeights: [Double] = [30, 30, 30, 30, 30]
    private let colors: [Color] = [Color.green, Color.blue, Color.red, Color.orange]
    
    var body: some View {
        HStack {
            ForEach(0..<4) { index in
                RoundedRectangle(cornerRadius: 50)
                    .frame(maxWidth: 40, maxHeight: rectHeights[index])
                    .foregroundColor(colors[index])
                    .padding(.horizontal, 15)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.white.opacity(0.3))
        .onReceive(timer) { _ in
            withAnimation {
                updateRectHeights()
                step = (step + 1) % 11
            }
        }
    }
    
    func updateRectHeights() {
        let targetHeights: [Double] = [40, 40, 40, 40, 140, 240, 340, 440, 340, 240, 140]
        let reversedIndex = targetHeights.count - step - 1
        
        for index in 0..<rectHeights.count {
            let targetIndex = (reversedIndex + index) % targetHeights.count
            rectHeights[index] = targetHeights[targetIndex]
        }
    }
}

