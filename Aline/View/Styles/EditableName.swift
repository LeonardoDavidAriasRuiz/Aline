//
//  EditableName.swift
//  Aline
//
//  Created by Leonardo on 13/08/23.
//

import SwiftUI

struct EditableName: View {
    @EnvironmentObject private var restaurantM: RestaurantPickerManager
    @EnvironmentObject private var menuSection: MenuSection
    @Environment(\.dismiss) private var dismiss
    
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
                    .padding(.vertical, 8)
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button("Actualizar", action: update)
                        .disabled(updateButtonDisabled)
                }
                ToolbarItem(placement: .keyboard) {
                    HideKeyboardToolbarButton()
                }
            }
        }
        .onAppear(perform: onApper)
        .onChange(of: newName, isValidName)
        .onChange(of: restaurantM.currentId, {dismiss()})
        .onChange(of: menuSection.section, {dismiss()})
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
                let nameRegex = "^[a-zA-ZÀ-ÖØ-öø-ÿ .]+$"
                let namePredicate = NSPredicate(format: "SELF MATCHES %@", nameRegex)
                updateButtonDisabled = !namePredicate.evaluate(with: newName)
            }
        } else {
            updateButtonDisabled = true
        }
    }
    
    private func update() {
        dismiss()
        name = newName
        accion()
    }
}
