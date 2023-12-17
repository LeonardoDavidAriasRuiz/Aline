//
//  NewBeneficiarySpending.swift
//  Aline
//
//  Created by Leonardo on 07/12/23.
//

import SwiftUI

struct NewBeneficiarySpending: View {
    @EnvironmentObject private var alertVM: AlertViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var newSpending: BeneficiarySpending
    @State private var isLoading: Bool = false
    
    @Binding private var spendings: [BeneficiarySpending]
    
    let beneficiarySpendingVM = BeneficiarySpendingViewModel()
    
    init(beneficiary: Beneficiary, beneficiarySpendings: Binding<BeneficiarySpendings>, restaurantId: String) {
        self._spendings = beneficiarySpendings.spendings
        let date: Date = beneficiarySpendings.date.wrappedValue
        let spending = BeneficiarySpending(beneficiary: beneficiary, date: date, restaurantId: restaurantId)
        self._newSpending = State<BeneficiarySpending>(initialValue: spending)
    }
    
    var body: some View {
        NavigationStack {
            Sheet(isLoading: $isLoading) {
                WhiteArea(spacing: 10){
                    Text(newSpending.date.shortDate)
                    Divider()
                    DecimalField("0.0", decimal: $newSpending.quantity, alignment: .leading)
                    Divider()
                    TextField("Nota", text: $newSpending.note)
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button("Cancelar", action: {dismiss()}).foregroundStyle(Color.red)
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    SaveButton(action: save)
                }
            }
        }
    }
    
    private func save() {
        withAnimation {
            isLoading = false
            beneficiarySpendingVM.save(newSpending.record) {
                spendings.append(newSpending)
                dismiss()
            } ifNot: {
                isLoading = false
                alertVM.show(.crearingError)
            }
        }
    }
}
