//
//  NewRestaurantView.swift
//  Aline
//
//  Created by Leonardo on 07/10/23.
//

import SwiftUI

struct NewRestaurantView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject private var alertVM: AlertViewModel
    @EnvironmentObject private var userVM: UserViewModel
    
    @State private var newRestaurant: Restaurant = Restaurant()
    @State private var isLoading: Bool = false
    
    var body: some View {
        Sheet {
            WhiteArea{
                NavigationLink(destination: EditableName(name: $newRestaurant.name, accion: {})) {
                    HStack {
                        Text("Nombre").foregroundStyle(Color.text)
                        Spacer()
                        Text(newRestaurant.name).foregroundStyle(Color.text.secondary)
                        Image(systemName: "chevron.right").foregroundStyle(Color.text.secondary)
                    }.padding(.vertical, 8)
                }
                Divider()
                NavigationLink(destination: EditableEmail(email: $newRestaurant.email, accion: {})) {
                    HStack {
                        Text("Email").foregroundStyle(Color.text)
                        Spacer()
                        Text(newRestaurant.email).foregroundStyle(Color.text.secondary)
                        Image(systemName: "chevron.right").foregroundStyle(Color.text.secondary)
                    }.padding(.vertical, 8)
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarLeading) {
                discardToolBarButton
            }
            ToolbarItemGroup(placement: .topBarTrailing) {
                saveToolBarButton
            }
        }
        .navigationBarBackButtonHidden()
    }
    
    private var discardToolBarButton: some View {
        Button(action: discard) {
            Text("Descartar").foregroundStyle(Color.red)
        }
    }
    
    private var saveToolBarButton: some View {
        VStack {
            if checkIfSpendingReadyToSave() {
                Button(action: save) {
                    Text("Guardar")
                }
            } else {
                Menu("Guardar") {
                    if newRestaurant.name.isEmpty {
                        Text("Escribe un nombre.")
                    }
                    if newRestaurant.email.isEmpty {
                        Text("Escribe un email.")
                    }
                }
            }
        }
    }
    
    private func checkIfSpendingReadyToSave() -> Bool {
        return newRestaurant.name.isNotEmpty && newRestaurant.email.isNotEmpty
    }
    
    private func save() {
        isLoading = true
        newRestaurant.adminUsersIds.append(userVM.user.id)
        userVM.user.adminIds.append(newRestaurant.id)
        userVM.save()
        RestaurantViewModel().save(newRestaurant.record) {
            discard()
        } ifNot: {
            alertVM.show(.crearingError)
        } alwaysDo: {
            isLoading = false
        }

        
    }
    
    private func discard() {
        self.presentationMode.wrappedValue.dismiss()
    }
}
