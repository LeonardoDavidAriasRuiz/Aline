//
//  EmployeeViewModel.swift
//  Aline
//
//  Created by Leonardo David Arias Ruiz on 07/04/23.
//

import CloudKit
import SwiftUI

class EmployeeViewModel: PublicCloud {
    private let keys: EmployeeKeys = EmployeeKeys()
    
    @Published var employees: [Employee] = []
    var activeEmployees: [Employee] {
        employees.compactMap { employee in
            return employee.isActive ? employee : nil
        }
    }
    
    func create(_ record: CKRecord, saved: @escaping (Bool) -> Void) {
        dataBase.save(record) { record, error in
            withAnimation {
                if let record = record {
                    self.employees.append(Employee(record: record))
                    self.employees.sort(by: <)
                    saved(true)
                } else {
                    saved(false)
                }
            }
        }
    }
    
    func fetch(restaurantId: String, fetched: @escaping (Bool) -> Void) {
        let predicate = NSPredicate(format: "\(keys.restaurantId) == %@", restaurantId)
        let query = CKQuery(recordType: keys.type, predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor (key: keys.lastName, ascending: true)]
        
        dataBase.fetch(withQuery: query) { result in
            guard case .success(let data) = result else { fetched(false); return }
            withAnimation {
                self.employees = data.matchResults.compactMap { _, result in
                    guard case .success(let record) = result else { fetched(false); return nil }
                    return Employee(record: record)
                }.sorted(by: <)
            }
            fetched(true)
        }
    }
    
    func fetch(employeesIds: [String], completion: @escaping ([Employee]?) -> Void) {
        let predicate = NSPredicate(format: "\(keys.id) IN %@", employeesIds)
        let query = CKQuery(recordType: keys.type, predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor (key: keys.lastName, ascending: true)]
        
        dataBase.fetch(withQuery: query) { result in
            guard case .success(let data) = result else { completion(.none); return }
            let employees: [Employee] = data.matchResults.compactMap { _, result in
                guard case .success(let record) = result else {completion(.none); return nil }
                return Employee(record: record)
            }
            completion(employees)
        }
    }
    
    func update(_ record: CKRecord, updated: @escaping (Bool) -> Void) {
        dataBase.save(record) { record, error in
            withAnimation {
                if let record = record {
                    let employee = Employee(record: record)
                    if let index = self.employees.firstIndex(where: { $0.id == employee.id }) {
                        self.employees[index] = employee
                    }
                    updated(true)
                } else {
                    updated(false)
                }
            }
        }
    }
}
