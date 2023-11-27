//
//  NewSpendingView.swift
//  Aline
//
//  Created by Leonardo on 28/09/23.
//

import SwiftUI

struct NewSpendingView: View {
    @EnvironmentObject private var restaurantM: RestaurantPickerManager
    @EnvironmentObject private var alertVM: AlertViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var newSpending: Spending = Spending()
    @State private var beneficiaries: [Beneficiary] = []
    @State private var isLoading: Bool = false
    @State private var defaultNote: Bool = false
    @State private var defaultNoteButNoTypeSlected: Bool = false
    
    @Binding var spendingTypes: [SpendingType]
    
    var body: some View {
        Sheet(section: .newSpending, isLoading: $isLoading) {
            spendingQuantityField
            datePicker
            spendingTypePicker
            beneficiaryPicker
            notesArea
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
        .onAppear(perform: onAppear)
    }
    
    private var datePicker: some View {
        WhiteArea {
            MonthPicker(date: $newSpending.date) {
                HStack {
                    Text("Mes")
                    Spacer()
                    Text(newSpending.date.month)
                }.padding(.vertical, 8)
            }
            Divider()
            YearPicker(date: $newSpending.date) {
                HStack {
                    Text("Año")
                    Spacer()
                    Text(newSpending.date.year)
                }.padding(.vertical, 8)
            }
        }
    }
    
    private var discardToolBarButton: some View {
        Button(action: {dismiss()}) {
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
                    if newSpending.quantity == 0.0 {
                        Text("Escribe una cantidad valida.")
                    }
                    if newSpending.spendingTypeId == "" {
                        Text("Selecciona un tipo de gasto.")
                    }
                    if newSpending.notes == ""{
                        Text("Escribe algo en notas.")
                    }
                }
            }
        }
    }
    
    private var spendingQuantityField: some View {
        WhiteArea {
            DecimalField("Cantidad", decimal: $newSpending.quantity, alignment: .leading)
                .padding(.vertical, 8)
        }
    }
    
    private var spendingTypePicker: some View {
        Menu {
            Picker("Tipo de gasto", selection: $newSpending.spendingTypeId) {
                ForEach(spendingTypes, id: \.self) { type in
                    Label(type.name, systemImage: type.id == newSpending.spendingTypeId ? "tag.fill" : "tag")
                        .tag(type.id)
                }
            }.pickerStyle(InlinePickerStyle())
        } label: {
            WhiteArea(spacing: 8) {
                HStack {
                    Text("Categoría")
                    Spacer()
                    Text(getSpendingTypeName(for: newSpending))
                }
            }
        }
        .onChange(of: newSpending.spendingTypeId, rewriteDefaultNote)
    }
    
    private var beneficiaryPicker: some View {
        Menu {
            Picker("Beneficiario", selection: $newSpending.beneficiaryId) {
                Label("Sin beneficiario", systemImage: "none" == newSpending.beneficiaryId ? "building.2.fill" : "building.2")
                    .tag("none")
                ForEach(beneficiaries, id: \.self) { beneficiary in
                    Label(beneficiary.fullName, systemImage: beneficiary.id == newSpending.beneficiaryId ? "person.fill" : "person")
                        .tag(beneficiary.id)
                }
            }.pickerStyle(InlinePickerStyle())
        } label: {
            WhiteArea(spacing: 8) {
                HStack {
                    Text("Beneficiario")
                    Spacer()
                    Text(getBeneficiaryName(for: newSpending))
                }
            }
        }
    }
    
    private var notesArea: some View {
        WhiteArea(spacing: 8) {
            TextField("Notas", text: $newSpending.notes)
                .disabled(defaultNote)
                .foregroundStyle(defaultNote ? .secondary : .primary)
            Divider()
            Toggle("Nota predeterminada", isOn: $defaultNote)
                .onChange(of: defaultNote, toggleDefaultNote)
            if defaultNoteButNoTypeSlected {
                HStack {
                    Text("Tienes que seleccionar un tipo de gasto.")
                        .font(.footnote)
                        .foregroundStyle(Color.red)
                    Spacer()
                }
            }
        }
    }
    
    private func save() {
        isLoading = true
        newSpending.restaurantId = restaurantM.currentId
        SpendingViewModel().saveSpending(newSpending) { saved in
            DispatchQueue.main.async {
                if saved {
                    dismiss()
                } else {
                    isLoading = false
                    alertVM.show(.crearingError)
                }
            }
        }
    }
    
    private func rewriteDefaultNote() {
        withAnimation {
            defaultNoteButNoTypeSlected = false
        }
        if defaultNote {
            newSpending.notes = "Gasto de \(getSpendingTypeName(for: newSpending)) para \(newSpending.date.monthAndYear)"
        }
    }
    
    private func toggleDefaultNote() {
        if newSpending.spendingTypeId == "" {
            withAnimation {
                defaultNote = false
                defaultNoteButNoTypeSlected = true
            }
        } else {
            withAnimation {
                defaultNoteButNoTypeSlected = false
            }
            newSpending.notes = defaultNote ?
            "Gasto de \(getSpendingTypeName(for: newSpending)) para \(newSpending.date.monthAndYear)" :
            newSpending.notes
        }
    }
    
    private func checkIfSpendingReadyToSave() -> Bool {
        return newSpending.quantity != 0.0 && 
        newSpending.spendingTypeId != "" &&
        newSpending.notes != ""
    }
    
    private func getSpendingTypeName(for spending: Spending) -> String {
        if let spendingTypeName = spendingTypes.first(where: {$0.id == spending.spendingTypeId})?.name {
            return spendingTypeName
        } else {
            return ""
        }
    }
    
    private func getBeneficiaryName(for spending: Spending) -> String {
        if spending.beneficiaryId == "none" {
            return "Sin beneficiario"
        } else if let beneficiaryName = beneficiaries.first(where: {$0.id == spending.beneficiaryId})?.fullName {
            return beneficiaryName
        } else {
            return ""
        }
    }
    
    private func fetchBeneficiaries() {
        withAnimation {
            isLoading = true
            BeneficiaryViewModel().fetch(for: restaurantM.currentId) { beneficiaries in
                if let beneficiaries = beneficiaries {
                    self.beneficiaries = beneficiaries
                } else {
                    alertVM.show(.dataObtainingError)
                }
                isLoading = false
            }
        }
    }
    
    private func onAppear() {
        fetchBeneficiaries()
    }
}
