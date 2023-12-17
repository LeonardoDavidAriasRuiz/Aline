//
//  BeneficiaryView.swift
//  Aline
//
//  Created by Leonardo on 07/12/23.
//

import SwiftUI

struct BeneficiaryView: View {
    @EnvironmentObject private var restaurantM: RestaurantPickerManager
    @EnvironmentObject private var menuSection: MenuSection
    @EnvironmentObject private var alertVM: AlertViewModel
    @Environment(\.dismiss) private var dismiss
    
    
    @State private var isLoading: Bool = false
    @State private var beneficiary: Beneficiary
    @State private var beneficiarySpendings: [BeneficiarySpendings] = []
    @State private var newSpendingPressed: Bool = false
    @State private var indexForNewSpending: Int = 0
    @State private var spendingSelected: BeneficiarySpending?
    
    init(beneficiary: Beneficiary) {
        self._beneficiary = State<Beneficiary>(initialValue: beneficiary)
    }
    
    var body: some View {
        FullSheet(isLoading: $isLoading) {
            WhiteArea(spacing: 10) {
                TextField("Mombre", text: $beneficiary.name).onSubmit(updateBeneficiary)
                Divider()
                TextField("Apellido", text: $beneficiary.lastName).onSubmit(updateBeneficiary)
                Divider()
                HStack {
                    Text("Porcentaje")
                    Spacer()
                    Text((beneficiary.percentage * 100).comasText + "%")
                }.foregroundStyle(.secondary)
                Divider()
                HStack {
                    Text("Incremento: ")
                    DecimalField("0.0", decimal: $beneficiary.status, alignment: .leading).onSubmit(updateBeneficiary)
                }
                Divider()
                HStack {
                    VStack {
                        Text("Inicio").font(.title).bold().foregroundStyle(Color.green)
                        DatePicker("", selection: $beneficiary.startEndDates[0], displayedComponents: .date).datePickerStyle(.graphical)
                    }
                    Divider()
                    VStack {
                        Text("Fin").font(.title).bold().foregroundStyle(Color.green)
                        if beneficiary.startEndDates.count <= 1 {
                            Button(action: addEndDate) {
                                Image(systemName: "plus")
                                    .font(.largeTitle)
                                    .foregroundStyle(Color.white)
                                    .padding(10)
                                    .background(Color.green)
                                    .clipShape(Circle())
                            }
                            Text("No se ha establecido una fecha de fin").bold().foregroundStyle(Color.red)
                        } else {
                            DatePicker("", selection: $beneficiary.startEndDates[1], displayedComponents: .date).datePickerStyle(.graphical)
                            Button("Quitar fin", action: deleteEndDate)
                        }
                    }
                }
            }
            WhiteArea {
                HStack {
                    Text("Gastos").bold().font(.largeTitle)
                    Spacer()
                }.padding(.top, 10)
                ScrollView(.horizontal){
                    HStack {
                        ForEach(beneficiarySpendings.indices, id: \.self) { index in
                            ScrollView {
                                VStack(spacing: 20) {
                                    Text(beneficiarySpendings[index].date.monthInt == 1 ? beneficiarySpendings[index].date.year : " ").bold().font(.title2).foregroundStyle(Color.green)
                                    Text(beneficiarySpendings[index].date.month).bold().font(.title3)
                                    Divider()
                                    Text(beneficiarySpendings[index].totalSpendings.comasTextWithDecimals)
                                    ForEach(beneficiarySpendings[index].spendings, id: \.self) { spending in
                                        Divider()
                                        VStack {
                                            HStack {
                                                Button(spending.quantity.comasTextWithDecimals, action: {selecteSpending(spending)})
                                                    .foregroundStyle(Color.text.tertiary)
                                                deleteButton(spending)
                                            }
                                            
                                            if spendingSelected == spending {
                                                Text(spending.note).foregroundStyle(.secondary)
                                            }
                                        }
                                    }
                                    Divider()
                                    Button("Nuevo", action: {openNewSpendingArea(index: index)})
                                }.frame(width: 150, alignment: .top)
                            }
                        }
                    }.padding(.vertical, 30)
                }
            }
        }
        .sheet(isPresented: $newSpendingPressed) {
            NewBeneficiarySpending(beneficiary: beneficiary, beneficiarySpendings: $beneficiarySpendings[indexForNewSpending].animation(), restaurantId: restaurantM.currentId)
        }
        .toolbar(content: toolbarItems)
        .onAppear(perform: getSpendings)
        .onChange(of: menuSection.section, {dismiss()})
        .onChange(of: beneficiary.startEndDates, updateBeneficiary)
    }
    
    private func deleteButton(_ spending: BeneficiarySpending) -> some View {
        Group {
            if spendingSelected == spending {
                Button(action: {deleteSpending(spending: spending)}) {
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
    }
    
    private func addEndDate() {
        withAnimation {
            if beneficiary.startEndDates.count <= 1 {
                beneficiary.startEndDates.append(Date())
            }
        }
    }
    
    private func deleteEndDate() {
        withAnimation {
            if beneficiary.startEndDates.count > 1 {
                beneficiary.startEndDates.removeLast()
            }
        }
    }
    
    private func updateBeneficiary() {
        BeneficiaryViewModel().save(beneficiary.record) {
            getSpendings()
        } ifNot: {
            alertVM.show(.updatingError)
        }
    }
    
    private func selecteSpending(_ spending: BeneficiarySpending) {
        withAnimation {
            spendingSelected = spendingSelected == spending ? nil : spending
        }
    }
    
    private func openNewSpendingArea(index: Int) {
        indexForNewSpending = index
        newSpendingPressed = true
    }
    
    private func getSpendings() {
        withAnimation {
            BeneficiarySpendingViewModel().fetch(for: restaurantM.currentId) { spendings in
                if let spendings = spendings {
                    for index in beneficiarySpendings.indices {
                        beneficiarySpendings[index].spendings = spendings.filter { spending in
                            spending.date >= beneficiarySpendings[index].date.firstDayOfMonth &&
                            spending.date <= beneficiarySpendings[index].date.lastDayOfMonth &&
                            spending.beneficiaryId == beneficiarySpendings[index].beneficiary.id
                        }
                    }
                }
            }
            setBeneficiarySpendingsDates()
        }
    }
    
    private func setBeneficiarySpendingsDates() {
        withAnimation {
            var currentDate = beneficiary.startEndDates[0].firstDayOfMonth
            var firstDaysOfMonth: [Date] = []
            let endDate: Date = beneficiary.startEndDates.count <= 1 ? Date() : beneficiary.startEndDates[1]
            
            while currentDate <= endDate {
                firstDaysOfMonth.append(currentDate.firstDayOfMonth)
                if let nextMonth = Calendar.current.date(byAdding: DateComponents(month: 1), to: currentDate) {
                    currentDate = nextMonth
                } else {
                    break
                }
            }
            beneficiarySpendings = firstDaysOfMonth.map {BeneficiarySpendings(beneficiary: beneficiary, date: $0, spendings: [])}
        }
    }
    
    private func deleteSpending(spending: BeneficiarySpending) {
        withAnimation {
            isLoading = true
            BeneficiarySpendingViewModel().delete(spending.record) {
                for index in beneficiarySpendings.indices {
                    beneficiarySpendings[index].spendings.removeAll(where: {$0 == spending})
                }
            } ifNot: {
                alertVM.show(.deletingError)
            } alwaysDo: {
                isLoading = false
            }
        }
    }
}

extension BeneficiaryView {
    private func toolbarItems() -> some ToolbarContent {
        Group {
            ToolbarItemGroup(placement: .topBarLeading) {
                UpdateRecordsToolbarButton(action: getSpendings)
            }
        }
    }
}
