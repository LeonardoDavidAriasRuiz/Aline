//
//  DepositsView.swift
//  Aline
//
//  Created by Leonardo David Arias Ruiz on 29/03/23.
//

import SwiftUI

struct DepositsView: View {
    
    @EnvironmentObject private var restaurantVM: RestaurantViewModel
    @EnvironmentObject private var depositVM: DepositViewModel
    @EnvironmentObject private var loading: LoadingViewModel
    @EnvironmentObject private var accentColor: AccentColor
    @EnvironmentObject private var userVM: UserViewModel
    
    @State private var editableDeposit = Deposit()
    @State private var editableDepositAreaOpen: Bool = false
    @State private var deposits: [Deposit] = []
    @State private var deleteDepositButtonVisible: Bool = false
    
    @State private var alertShowed: Bool = false
    @State private var alertType: AlertType = AlertType.dataObtainingError
    
    private let newDepositRangeForStepper: ClosedRange<Int> = 50...10000
    private let newDepositStepQuantity: Int = 50
    private let cancelButtonText: String = "Cancelar"
    private let newDepositButtonText: String = "Nuevo depósito"
    private let plusImageName: String = "plus"
    private let saveButtonText: String = "Guardar"
    private let errorMessage: String = "No se pudo completar la operación."
    
    
    
    var body: some View {
        Sheet(section: .deposits) {
            editableDepositArea
            deposits.isEmpty ? nil : depositsListArea
        }
        .alertInfo(alertType, showed: $alertShowed)
        .onAppear(perform: getDeposits)
    }
    
    private var depositsListArea: some View {
        WhiteArea {
            ForEach(deposits, id: \.self) { deposit in
                Button(action: {selectDeposit(deposit)}, label: {
                    HStack {
                        Text(deposit.date.short).foregroundStyle(.black)
                        Spacer()
                        Text("\(deposit.quantity)").foregroundStyle(.black.secondary)
                        Image(systemName: "chevron.forward").foregroundStyle(.black.secondary)
                    }
                    
                })
                if deposits.last != deposit {
                    Divider()
                }
            }
        }
    }
    
    private var editableDepositArea: some View {
        WhiteArea {
            Button(action: toggleEditableDepositArea) {
                HStack {
                    Text(editableDepositAreaOpen ? cancelButtonText : newDepositButtonText)
                    Spacer()
                    Image(systemName: plusImageName)
                        .font(.title2)
                        .rotationEffect(Angle(degrees: editableDepositAreaOpen ? 45 : 0))
                        .symbolEffect(.bounce, value: editableDepositAreaOpen)
                }
            }
            if editableDepositAreaOpen {
                Divider()
                HStack {
                    Stepper("$\(editableDeposit.quantity)",
                            value: $editableDeposit.quantity,
                            in: newDepositRangeForStepper,
                            step: newDepositStepQuantity
                    )
                    DatePicker("",
                               selection: $editableDeposit.date,
                               displayedComponents: .date
                    )
                }
                Divider()
                Button("Guardar", action: create)
                
                if deleteDepositButtonVisible {
                    Divider()
                    Button("Eliminar", action: delete)
                }
            }
        }
    }
    
    private func selectDeposit(_ deposit: Deposit) {
        withAnimation {
            if editableDeposit == deposit {
                toggleEditableDepositArea()
            } else {
                deleteDepositButtonVisible = true
                editableDeposit = deposit
                editableDepositAreaOpen = true
            }
        }
    }
    
    private func create() {
        withAnimation {
            loading.isLoading = true
            editableDeposit.restaurantId = restaurantVM.restaurant.id
            depositVM.save(editableDeposit) { deposit in
                if let deposit = deposit {
                    deposits.append(deposit)
                    toggleEditableDepositArea()
                    deposits.sort { $0.date > $1.date }
                } else {
                    alertShowed = true
                    alertType = .crearingError
                }
                loading.isLoading = false
            }
        }
    }
    
    private func delete() {
        withAnimation {
            loading.isLoading = true
            depositVM.delete(deposit: editableDeposit) { deleted in
                if deleted {
                    guard let index = deposits.firstIndex(of: editableDeposit) else { return }
                    deposits.remove(at: index)
                    toggleEditableDepositArea()
                } else {
                    alertShowed = true
                    alertType = .deletingError
                }
                loading.isLoading = false
            }
        }
    }
    
    private func toggleEditableDepositArea() {
        withAnimation {
            editableDepositAreaOpen.toggle()
            deleteDepositButtonVisible = false
            editableDeposit = Deposit()
        }
    }
    
    private func getDeposits() {
        loading.isLoading = true
        depositVM.fetchDeposits(for: restaurantVM.restaurant.id) { deposits in
            if let deposits = deposits {
                self.deposits = deposits
            } else {
                alertType = .dataObtainingError
                alertShowed = true
            }
            loading.isLoading = false
        }
    }
}



