//
//  EditableName.swift
//  Aline
//
//  Created by Leonardo on 13/08/23.
//

import SwiftUI

struct EditableName: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @Binding var name: String
    @State private var newName: String = ""
    @State private var updateButtonDisabled: Bool = true
    let accion: () -> Void
    var body: some View {
        Sheet(section: .editableName) {
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
