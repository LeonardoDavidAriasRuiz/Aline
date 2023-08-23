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
    @EnvironmentObject private var accentColor: AccentColor
    @EnvironmentObject private var userVM: UserViewModel
    
    @State private var editableDeposit = Deposit()
    @State private var editableDepositAreaOpen: Bool = false
    @State private var deposits: [Deposit] = []
    @State private var deleteDepositButtonVisible: Bool = false
    
    @State private var isLoading: Bool = true
    @State private var alertShowed: Bool = false
    @State private var alertType: AlertType = AlertType.dataObtainingError
    
    private let tint: Color = .blue
    private let title: String = "Depositos"
    private let newDepositRangeForStepper: ClosedRange<Int> = 50...10000
    private let newDepositStepQuantity: Int = 50
    private let cancelButtonText: String = "Cancelar"
    private let newDepositButtonText: String = "Nuevo depósito"
    private let plusImageName: String = "plus"
    private let saveButtonText: String = "Guardar"
    private let errorMessage: String = "No se pudo completar la operación."
    
    
    
    var body: some View {
        LoadingIfNotReady($isLoading) {
            Sheet(title: title) {
                editableDepositArea
                deposits.isEmpty ? nil : depositsListArea
            }
        }
        .tint(tint)
        .alertInfo(alertType, showed: $alertShowed)
        .onAppear(perform: onAppear)
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
                DatePicker("", selection: $editableDeposit.date, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                Divider()
                Stepper("$\(editableDeposit.quantity)",
                        value: $editableDeposit.quantity,
                        in: newDepositRangeForStepper,
                        step: newDepositStepQuantity)
                Divider()
                Button("Guardar", action: createDeposit)
                
                if deleteDepositButtonVisible {
                    Divider()
                    Button("Eliminar", action: deleteDeposit)
                }
            }
        }
    }
    
    private func selectDeposit(_ deposit: Deposit) {
        withAnimation {
            if self.editableDeposit == deposit {
                editableDepositAreaOpen = false
                editableDeposit = Deposit()
                deleteDepositButtonVisible = false
            } else {
                deleteDepositButtonVisible = true
                self.editableDeposit = deposit
                editableDepositAreaOpen = true
            }
        }
    }
    
    private func createDeposit() {
        withAnimation {
            isLoading = true
            editableDeposit.restaurantId = restaurantVM.restaurant.id
            depositVM.save(editableDeposit) { result in
                switch result {
                    case .success(let deppsitCreated):
                        deposits.append(deppsitCreated)
                        toggleEditableDepositArea()
                        deposits.sort { $0.date > $1.date }
                    case .failure:
                        alertShowed = true
                        alertType = .crearingError
                        
                }
                isLoading = false
            }
        }
    }
    
    private func deleteDeposit() {
        withAnimation {
            isLoading = true
            depositVM.delete(deposit: editableDeposit) { result in
                switch result {
                    case .success:
                        guard let index = deposits.firstIndex(of: editableDeposit) else { return }
                        deposits.remove(at: index)
                        toggleEditableDepositArea()
                    case .failure:
                        alertShowed = true
                        alertType = .deletingError
                        
                }
                isLoading = false
            }
        }
    }
    
    private func toggleEditableDepositArea() {
        withAnimation {
            editableDepositAreaOpen.toggle()
            guard editableDepositAreaOpen else { return }
            editableDeposit = Deposit()
        }
    }
    
    private func onAppear() {
        accentColor.blue()
    }
    
    private func fetchDeposits() {
        depositVM.fetchDeposits(for: restaurantVM.restaurant.id) { result in
            switch result {
                case .success(let depositsObtainde):
                    deposits = depositsObtainde
                case .failure:
                    alertType = .dataObtainingError
                    alertShowed = true
            }
            isLoading = false
        }
    }
}



