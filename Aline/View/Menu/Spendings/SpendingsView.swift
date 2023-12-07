//
//  SpendingsView.swift
//  Aline
//
//  Created by Leonardo David Arias Ruiz on 29/03/23.
//

import SwiftUI
import Charts

struct SpendingsView: View {
    @EnvironmentObject private var restaurantM: RestaurantPickerManager
    @EnvironmentObject private var alertVM: AlertViewModel
    @EnvironmentObject private var userVM: UserViewModel
    
    @State private var spendingTypes: [SpendingType] = []
    @State private var date: Date = Date()
    @State private var spendingTypeSlectedToView: SpendingType?
    @State private var spendingTypesSlectedToView: [SpendingType] = []
    @State private var spendingSelectedToEdit: Spending?
    @State private var isLoading: Bool = true
    
    var body: some View {
        FullSheet(isLoading: $isLoading) {
            if spendingTypes.isNotEmpty {
                spendingsByTypeList
                totalArea
            }
        }
        .navigationTitle("Gostos - " + date.monthAndYear)
        .toolbar {
            ToolbarItemGroup(placement: .topBarLeading) {
                NewRecordToolbarButton(destination: NewSpendingView(spendingTypes: $spendingTypes))
                UpdateRecordsToolbarButton(action: getTypes)
            }
            ToolbarItemGroup(placement: .topBarTrailing) {
                ExportCSVToolbarButton(data: createCSV()).disabled(spendingTypes.isEmpty)
                NavigationLink("Categorías") {
                    SpendingTypesView(spendingTypes: $spendingTypes)
                }
                CalendarToolbarMenu {
                    MonthPicker(date.month, date: $date)
                    YearPicker(date.year, date: $date)
                        .onChange(of: date, getTypes)
                }
            }
        }
        .overlay { if spendingTypes.isEmpty, !isLoading { EmptySpendingsView() } }
        .onAppear(perform: getTypes)
        .onChange(of: restaurantM.currentId, getTypes)
    }
    
    private var spendingsByTypeList: some View {
        WhiteArea {
            ForEach(spendingTypes, id: \.self) { type in
                Button(action: {selectSpendingTypeToView(type)}) {
                    HStack {
                        Text(type.name).foregroundStyle(Color.text)
                            .font(spendingTypesSlectedToView.contains(type) ? .title : .body)
                            .bold(spendingTypesSlectedToView.contains(type))
                        Spacer()
                        Text("$\(getTotalForSpendingType(spendingType: type).comasTextWithDecimals)")
                            .foregroundStyle(Color.text.secondary)
                            .font(spendingTypesSlectedToView.contains(type) ? .title : .body)
                        Image(systemName: spendingTypesSlectedToView.contains(type) ? "chevron.up" : "chevron.down")
                            .foregroundStyle(Color.text.secondary)
                    }.padding(.vertical, 8)
                }
                if spendingTypesSlectedToView.contains(type) {
                    Divider()
                    VStack(spacing: 0) {
                        ForEach(type.spendings, id: \.self) { spending in
                            HStack {
                                Button(action: {selectSpendingToView(spending)}) {
                                    HStack(spacing: 10) {
                                        Text("$\(spending.quantity.comasTextWithDecimals)").foregroundStyle(Color.text)
                                        Text(spending.notes).foregroundStyle(Color.text.secondary)
                                        Spacer()
                                    }.padding(.vertical, 8)
                                }
                                if spendingSelectedToEdit == spending {
                                    Button(action: {deleteSpending(spending)}) {
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
                            if spending != type.spendings.last {
                                Divider()
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .background(Color.background)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                }
                if type != spendingTypes.last {
                    Divider()
                }
            }
        }
    }
    
    private func clearFilters() {
        withAnimation {
            date = Date()
        }
    }
    
    private var totalArea: some View {
        WhiteArea(spacing: 8) {
            Text("$\(getTotalInMonth().comasTextWithDecimals)")
                .font(.largeTitle)
        }
    }
    private func deleteSpending(_ spending: Spending) {
        isLoading = true
        withAnimation {
            SpendingViewModel().delete(spending.record) { deleted in
                if deleted {
                    getTypes()
                } else {
                    alertVM.show(.deletingError)
                }
                isLoading = false
            }
        }
    }
    
    private func selectSpendingTypeToView(_ type: SpendingType) {
        withAnimation {
            if spendingTypesSlectedToView.contains(type) {
                spendingTypesSlectedToView.removeAll(where: {$0 == type})
            } else {
                if type.spendings.isNotEmpty {
                    spendingTypesSlectedToView.append(type)
                }
            }
        }
    }
    
    private func selectSpendingToView(_ spending: Spending) {
        withAnimation {
            if spendingSelectedToEdit == spending {
                spendingSelectedToEdit = nil
            } else {
                spendingSelectedToEdit = spending
            }
        }
    }
    
    private func getSpendingType(for spending: Spending) -> SpendingType? {
        return spendingTypes.first { spendingType in
            spending.id == spendingType.id
        }
    }
    
    private func getTotalForSpendingType(spendingType: SpendingType) -> Double {
        var total: Double = 0.0
        for spending in spendingType.spendings {
            total += spending.quantity
        }
        return total
    }
    
    private func getTotalInMonth() -> Double {
        var total: Double = 0.0
        for type in spendingTypes {
            total += getTotalForSpendingType(spendingType: type)
        }
        
        return total
    }
    
    private func getTypes() {
        isLoading = true
        withAnimation {
            spendingTypesSlectedToView.removeAll()
            SpendingViewModel().fetchTypes(for: restaurantM.currentId) { spendingTypes in
                if let spendingTypes = spendingTypes {
                    self.spendingTypes = spendingTypes.sorted(by: {$0.name < $1.name})
                    getSpendings()
                } else {
                    alertVM.show(.dataObtainingError)
                    isLoading = false
                }
            }
        }
    }
    
    private func getSpendings() {
        SpendingViewModel().fetchSpendings(for: restaurantM.currentId) { spendings in
            if let spendings = spendings {
                print(spendings)
            }
        }
        SpendingViewModel().fetch(restaurantId: restaurantM.currentId, date: date) { spendings in
            if let spendings = spendings {
//                print(spendings)
                for index in spendingTypes.indices {
                    for spending in spendings {
                        if spending.spendingTypeId == spendingTypes[index].id {
                            self.spendingTypes[index].spendings.append(spending)
                        }
                    }
                }
            } else {
                alertVM.show(.dataObtainingError)
            }
            isLoading = false
        }
    }
    
    func createCSV() -> Data? {
        var csvString = "Nombre,Descripción\n"
        for type in spendingTypes {
            csvString.append("\(type.name),\(type.description)\n")
            csvString.append("Fecha,Notas,Cantidad\n")
            for spending in type.spendings {
                csvString.append("\(spending.date.shortDate),\(spending.notes),\(spending.quantity)\n")
            }
        }
        return csvString.data(using: .utf8)
    }
}
