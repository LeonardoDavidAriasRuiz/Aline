//
//  HourPicker.swift
//  Aline
//
//  Created by Leonardo on 15/10/23.
//

import SwiftUI

struct HourPicker<Label: View>: View{
    let label: () -> Label
    @Binding var hours: Hour
    
    init(hours: Binding<Hour>, @ViewBuilder label: @escaping () -> Label) {
        self._hours = hours
        self.label = label
    }
    
    var body: some View {
        Menu {
            Picker("Horas", selection: $hours.hours) {
                ForEach(0..<121) {hour in
                    Text("\(hour)").tag(hour)
                }
            }.pickerStyle(.menu)
            Picker("Minutos", selection: $hours.minutes) {
                Text("00").tag(0)
                Text("15").tag(15)
                Text("30").tag(30)
                Text("45").tag(45)
            }.pickerStyle(.menu)
        } label: {
            label()
        }
    }
}
