//
//  AccountantView.swift
//  Aline
//
//  Created by Leonardo David Arias Ruiz on 29/03/23.
//

import SwiftUI

struct AccountantView: View {
    @EnvironmentObject private var restaurantM: RestaurantPickerManager
    @EnvironmentObject private var alertVM: AlertViewModel
    
    @State private var accountant = Accountant()
    @State private var isLoading: Bool = false
    
    var body: some View {
        Sheet(isLoading: $isLoading) {
            contadorArea
            messageArea
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                UpdateRecordsToolbarButton(action: getAccountant)
            }
        }
        .onAppear(perform: getAccountant)
    }
    
    private var messageArea: some View {
        WhiteArea {
            TextEditor(text: $accountant.message)
                .foregroundStyle(accountant.message == Accountant().message ? .secondary : .primary)
                .frame(height: 80)
            Divider()
            SaveButton(action: save)
        }
    }
    
    private var contadorArea: some View {
        WhiteArea {
            NavigationLink {
                EditableName(name: $accountant.name, accion: save)
            } label: {
                HStack {
                    Text("Nombre:").foregroundStyle(Color.text)
                    Spacer()
                    Text(accountant.name).foregroundStyle(Color.text.secondary)
                    Image(systemName: "chevron.right").foregroundStyle(Color.text.secondary)
                }.padding(.vertical, 8)
            }
            Divider()
            NavigationLink {
                EditableEmailNoConfirmation(email: $accountant.email, accion: save)
            } label: {
                HStack {
                    Text("Email:").foregroundStyle(Color.text)
                    Spacer()
                    Text(accountant.email).foregroundStyle(Color.text.secondary)
                    Image(systemName: "chevron.right").foregroundStyle(Color.text.secondary)
                }.padding(.vertical, 8)
            }
            
        }
    }
    
    private func save() {
        withAnimation {
            isLoading = true
            accountant.restaurantId = restaurantM.currentId
            AccountantViewModel().save(accountant) { saved in
                if !saved {
                    alertVM.show(.updatingError)
                }
                isLoading = false
            }
        }
    }
    
    private func getAccountant() {
        withAnimation {
            isLoading = true
            AccountantViewModel().fetch(for: restaurantM.currentId) { accountants in
                if let accountant = accountants?.first {
                    self.accountant = accountant
                } else {
                    alertVM.show(.dataObtainingError)
                }
                isLoading = false
            }
        }
    }
}
