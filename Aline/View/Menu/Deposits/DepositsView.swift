//
//  DepositsView.swift
//  Aline
//
//  Created by Leonardo David Arias Ruiz on 29/03/23.
//

import SwiftUI

struct DepositsView: View {
    @EnvironmentObject private var restaurantM: RestaurantPickerManager
    @EnvironmentObject private var alertVM: AlertViewModel
    @EnvironmentObject private var userVM: UserViewModel
    
    @State private var selectedDeposit: Deposit?
    @State private var editableDepositAreaOpen: Bool = false
    @State private var deposits: [Deposit] = []
    @State private var deleteDepositButtonVisible: Bool = false
    
    private let newDepositRangeForStepper: ClosedRange<Int> = 50...10000
    private let newDepositStepQuantity: Int = 50
    private let cancelButtonText: String = "Cancelar"
    private let newDepositButtonText: String = "Nuevo depósito"
    private let plusImageName: String = "plus"
    private let saveButtonText: String = "Guardar"
    private let errorMessage: String = "No se pudo completar la operación."
    
    @State private var isLoading: Bool = true
    
    var body: some View {
        Sheet(isLoading: $isLoading) {
            if deposits.isNotEmpty {
                depositsListArea
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarLeading) {
                NewRecordToolbarButton(destination: NewDepositView())
                UpdateRecordsToolbarButton(action: getDeposits)
            }
            ToolbarItem(placement: .topBarTrailing) {
                ExportToolbarButton(data: createCSV()).disabled(deposits.isEmpty)
            }
        }
        .overlay {
            if deposits.isEmpty, !isLoading {
                ContentUnavailableView(label: {
                    Label(
                        title: { Text("Sin depositos") },
                        icon: { Image(systemName: "tray.full.fill").foregroundStyle(Color.blue) }
                    )
                }, description: {
                    Text("Los nuevos depósitos se mostrarán aquí.")
                })
            }
        }
        .onAppear(perform: getDeposits)
    }
    
    private var depositsListArea: some View {
        WhiteArea {
            ForEach(deposits, id: \.self) { deposit in
                HStack {
                    Button(action: {selectDeposit(deposit)}) {
                        HStack {
                            Text(deposit.date.shortDate).foregroundStyle(Color.text)
                            Spacer()
                            Text("\(deposit.quantity)").foregroundStyle(Color.text.secondary)
                            if selectedDeposit != deposit {
                                Image(systemName: "ellipsis").foregroundStyle(Color.text.secondary)
                            }
                        }.padding(.vertical, 8)
                    }
                    if selectedDeposit == deposit {
                        Button(action: delete) {
                            Image(systemName: "trash.fill")
                                .foregroundStyle(.white)
                                .padding(6)
                                .font(.title3)
                                .background(Color.red)
                                .clipShape(Circle())
                                .padding(3)
                        }
                    }
                }
                if deposits.last != deposit {
                    Divider()
                }
            }
        }
    }
    
    private func selectDeposit(_ deposit: Deposit) {
        withAnimation {
            if selectedDeposit == deposit {
                selectedDeposit = nil
            } else {
                selectedDeposit = deposit
            }
        }
    }
    
    private func delete() {
        withAnimation {
            isLoading = true
            if let  deposit = selectedDeposit {
                DepositViewModel().delete(deposit.getCKRecord()) {
                    guard let index = deposits.firstIndex(of: deposit) else { return }
                    deposits.remove(at: index)
                } ifNot: {
                    alertVM.show(.deletingError)
                } alwaysDo: {
                    isLoading = false
                }
            } else {
                alertVM.show(.deletingError)
            }
        }
    }
    
    private func getDeposits() {
        withAnimation {
            isLoading = true
            DepositViewModel().fetch(restaurantId: restaurantM.currentId) { deposits in
                if let deposits = deposits {
                    self.deposits = deposits.sorted(by: {$0.date > $1.date})
                } else {
                    alertVM.show(.dataObtainingError)
                }
                isLoading = false
            }
        }
    }
    
    func createCSV() -> Data? {
        var csvString = "Fecha,Cantidad\n"
        for deposit in deposits {
            let depositString = "\(deposit.date.shortDate),\(deposit.quantity)\n"
            csvString.append(depositString)
        }
        return csvString.data(using: .utf8)
    }
}



