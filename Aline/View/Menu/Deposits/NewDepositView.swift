//
//  NewDepositView.swift
//  Aline
//
//  Created by Leonardo on 03/10/23.
//

import SwiftUI

struct NewDepositView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject private var restaurantM: RestaurantPickerManager
    @EnvironmentObject private var alertVM: AlertViewModel
    
    @State private var newDeposit = Deposit()
    @State private var isLoading: Bool = false
    
    private let newDepositRangeForStepper: ClosedRange<Int> = 50...10000
    private let newDepositStepQuantity: Int = 50
    
    var body: some View {
        Sheet(section: .newDeposit, isLoading: $isLoading) {
            WhiteArea {
                Stepper("$\(newDeposit.quantity)",
                        value: $newDeposit.quantity,
                        in: newDepositRangeForStepper,
                        step: newDepositStepQuantity
                )
                .padding(.vertical, 8)
            }
            WhiteArea {
                DatePicker("",selection: $newDeposit.date, displayedComponents: .date)
                    .datePickerStyle(.graphical)
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
                    Text("Escribe una cantidad valida.")
                }
            }
        }
    }
    
    private func checkIfSpendingReadyToSave() -> Bool {
        return newDeposit.quantity != 0
    }
    
    private func save() {
        isLoading = true
        newDeposit.restaurantId = restaurantM.currentId
        DepositViewModel().save(newDeposit.getCKRecord()) {
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
