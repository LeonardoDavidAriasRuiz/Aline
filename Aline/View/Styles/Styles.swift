//
//  Styles.swift
//  Aline
//
//  Created by Leonardo David Arias Ruiz on 29/03/23.
//

import SwiftUI

extension Color {
     static var green: Color = Color("Green")
     static var blue: Color = Color("Blue")
     static var red: Color = Color("Red")
     static var orange: Color = Color("Orange")
     static var background: Color = Color("Background")
}



struct EditableName: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @Binding var name: String
    @State private var newName: String = ""
    @State private var updateButtonDisabled: Bool = true
    let accion: () -> Void
    var body: some View {
        Sheet(title: "Nombre") {
            WhiteArea {
                TextField("Nombre", text: $newName)
                    .textInputAutocapitalization(.words)
                    .keyboardType(.alphabet)
                    .autocorrectionDisabled(true)
                    .onAppear(perform: onApper)
                    .onChange(of: newName, isValidName)
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button("Actualizar", action: update)
                        .disabled(updateButtonDisabled)
                }
            }
        }
    }
    
    private func onApper() {
        newName = name
    }
    
    private func isValidName() {
        if name != newName {
            if newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                updateButtonDisabled = true
                return
            } else {
                let nameRegex = "^[a-zA-Z ]+$"
                let namePredicate = NSPredicate(format: "SELF MATCHES %@", nameRegex)
                updateButtonDisabled = !namePredicate.evaluate(with: newName)
            }
        } else {
            updateButtonDisabled = true
        }
    }
    
    private func update() {
        self.presentationMode.wrappedValue.dismiss()
        name = newName
        accion()
    }
}



struct HeaderAreas: ViewModifier {
    private var padding: CGFloat = 10
    private var background: Color = Color.white
    private var cornerRadius: CGFloat = 15
    
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

struct WallColor: ViewModifier {
     let color: String
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(color))
    }
}

struct ButtonColor: ViewModifier {
     let color: Color
    
    func body(content: Content) -> some View {
        content
            .padding(10)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .foregroundColor(Color.white)
    }
}

struct TextFieldLogIn: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 30)
            .padding(.vertical, 10)
            .background(Color.background)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .padding(.bottom, 10)
    }
}

struct TextFieldSpendings: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(10)
            .padding(.leading, 10)
            .background(Color.background)
            .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}





//ForEach(Array(userVM.restaurants.enumerated()), id: \.element) { (index, restaurant) in
//    content
//    if index != userVM.restaurants.count - 1 {
//        Divider()
//    }
//}
