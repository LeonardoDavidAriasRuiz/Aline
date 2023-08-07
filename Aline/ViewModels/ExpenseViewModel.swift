//
//  ExpenseViewModel.swift
//  Aline
//
//  Created by Leonardo David Arias Ruiz on 11/04/23.
//

import CloudKit
import SwiftUI

class ExpenseViewModel: ObservableObject {
    
    private let dataBase: CKDatabase = CKContainer.default().publicCloudDatabase
    private let type = ExpenseType()
    private let spending = Expense()
    private let spendingKeys = Expense.Keys.self
    private let typeKeys = ExpenseType.Keys.self
    
    @Published var currentRestaurantLink: String = ""
    @Published var types: [ExpenseType] = []
    @Published var spendingsPerMonth: [spendingPerMonth] = []
    
     func addType(_ type: ExpenseType) {
        let newType = CKRecord(recordType: typeKeys.type.rawValue)
        newType[typeKeys.id.rawValue] = type.id
        newType[typeKeys.name.rawValue] = type.name
        newType[typeKeys.description.rawValue] = type.description
        newType[typeKeys.restaurantLink.rawValue] = currentRestaurantLink
        
        saveType(record: newType)
    }
    
     func addSpending(_ spending: Expense) {
        let cal = Calendar.current
        let year = spending.year
        let month = spending.month
        let day = 1
        let dateComponents = DateComponents(year: year, month: month, day: day)
        
        let newSpending = CKRecord(recordType: spendingKeys.type.rawValue)
        newSpending[spendingKeys.id.rawValue] = spending.id
        newSpending[spendingKeys.quantity.rawValue] = Double(spending.quantity)
        newSpending[spendingKeys.description.rawValue] = spending.description
        newSpending[spendingKeys.date.rawValue] = cal.date(from: dateComponents)
        newSpending[spendingKeys.typeLink.rawValue] = spending.typeLink
        newSpending[spendingKeys.restaurantLink.rawValue] = currentRestaurantLink
        
        saveSpending(record: newSpending)
    }
    
    private func saveSpending(record: CKRecord) {
        dataBase.save(record) { record, error in
            guard let _ = record else { return }
        }
    }
    
    private func saveType(record: CKRecord) {
        dataBase.save(record) { record, _ in
            guard let _ = record else { return }
        }
    }
    
     func fetchTypes() {
        DispatchQueue.main.async { [self] in types = [] }
        
        let predicateFormat = "\(typeKeys.restaurantLink) == %@"
        let predicate = NSPredicate(format: predicateFormat, currentRestaurantLink)
        let query = CKQuery(recordType: typeKeys.type.rawValue, predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor (key: typeKeys.name.rawValue, ascending: true)]
        let queryOperation = CKQueryOperation(query: query)
        
        queryOperation.recordMatchedBlock = { [self] (_, result) in
            guard case .success(let record) = result,
                  let id: String = record[typeKeys.name.rawValue],
                  let name: String = record[typeKeys.name.rawValue],
                  let description: String = record[typeKeys.description.rawValue],
                  let restaurantLink: String = record[typeKeys.restaurantLink.rawValue] else { return }
            
            let type = ExpenseType(id: id, name: name, description: description, restaurantLink: restaurantLink)
            
            DispatchQueue.main.sync {
                withAnimation {
                    types.append(type)
                }
            }
        }
        
        addQueryOperation(queryOperation)
    }
    
     func fetchSpendingsFrom(type: ExpenseType) {
        let LastTwelveMonthsRange = 0...12
        let calendar = Calendar.current
        
        DispatchQueue.main.async {
            self.spendingsPerMonth = []
        }
        
        
        for i in LastTwelveMonthsRange {
            guard let date = calendar.date(byAdding: .month, value: -i, to: Date()),
                  let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) else { return }
            
            var spm = spendingPerMonth(type: type, date: firstDayOfMonth, quantity: 0.0)
            
            let predicateFormat = "\(spendingKeys.typeLink) == %@ AND \(spendingKeys.date) == %@"
            let predicate = NSPredicate(format: predicateFormat, type.id, firstDayOfMonth as NSDate)
            let query = CKQuery(recordType: spendingKeys.type.rawValue, predicate: predicate)
            query.sortDescriptors = [NSSortDescriptor (key: spendingKeys.date.rawValue, ascending: true)]
            let queryOperation = CKQueryOperation(query: query)
            queryOperation.recordMatchedBlock = { [self] (_, result) in
                guard case .success(let record) = result,
                      let quantity: Double = record[spendingKeys.quantity.rawValue] else { return }
                spm.quantity += quantity
            }
            
            queryOperation.queryResultBlock = { [self] returnedResult in
                DispatchQueue.main.sync {
                    withAnimation {
                        spendingsPerMonth.append(spm)
                        spendingsPerMonth.sort { (spending1, spending2) -> Bool in
                            return spending1.date < spending2.date
                        }
                    }
                }
            }
            addQueryOperation(queryOperation)
        }
    }
    
    private func addQueryOperation(_ queryOperation: CKQueryOperation) {
        dataBase.add(queryOperation)
    }
}

struct spendingPerMonth: Hashable {
    let type: ExpenseType
    let date: Date
    var quantity: Double
    
    init(type: ExpenseType, date: Date, quantity: Double) {
        self.type = type
        self.date = date
        self.quantity = quantity
    }
}
