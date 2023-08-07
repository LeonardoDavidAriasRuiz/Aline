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
    @State private var cloudKitOperationError: Bool = false
    @State private var deposits: [Deposit] = []
    @State private var dataObtained: Bool = false
    @State private var deleteDepositButtonVisible: Bool = false

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
        LoadingIfNotReady(done: $dataObtained) {
            Sheet(title: title) {
                editableDepositArea
                deposits.isEmpty ? nil : depositsListArea
            }
        }
        .tint(tint)
        .onAppear(perform: onAppear)
        .alert(errorMessage, isPresented: $cloudKitOperationError, actions: {})
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
            editableDeposit.restaurantLink = restaurantVM.restaurant.id
            depositVM.save(self.editableDeposit)
            deposits.append(self.editableDeposit)
            toggleEditableDepositArea()
            deposits.sort { lhs, rhs in
                lhs.date > rhs.date
            }
        }
    }
    
    private func deleteDeposit() {
        withAnimation {
            guard let index = deposits.firstIndex(of: editableDeposit) else { return }
            deposits.remove(at: index)
            depositVM.delete(deposit: editableDeposit)
            editableDepositAreaOpen = false
            editableDeposit = Deposit()
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
        depositVM.fetchDeposits(for: restaurantVM.restaurant.id) { deposits in
            self.deposits = deposits
            self.dataObtained = true
        }
    }
}

extension Date {
    var short: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy"
        return dateFormatter.string(from: self)
    }
}

