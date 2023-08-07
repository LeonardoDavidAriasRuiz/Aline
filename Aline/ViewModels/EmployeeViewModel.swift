//
//  EmployeeViewModel.swift
//  Aline
//
//  Created by Leonardo David Arias Ruiz on 07/04/23.
//

import CloudKit
import SwiftUI

class EmployeeViewModel: ObservableObject {
    
    @EnvironmentObject private var userController: UserViewModel
    
    @Published var currentRestaurantLink: String = ""
    @Published var employees: [Employee] = []
    
    private let dataBase: CKDatabase = CKContainer.default().publicCloudDatabase
    private let recordType = "Empleados"
    private let idkKey = "id"
    private let nameKey = "name"
    private let lastNameKey = "lastName"
    private let restaurantLinkKey = "restaurantLink"
    
     func deleteEmployee(_ employee: Employee) {
        let predicate = NSPredicate(format: "\(idkKey) == %@", employee.id)
        let query = CKQuery(recordType: recordType, predicate: predicate)
        let queryOperation = CKQueryOperation(query: query)
        
        queryOperation.recordMatchedBlock = {(_, result) in
            guard case .success(let record) = result else { return }
            self.dataBase.delete(withRecordID: record.recordID) { (recordID, _) in
                self.fetchEmployees()
            }
        }
        addQueryOperation(queryOperation)
    }
    
     func addEmployee(_ employee: Employee) {
        employee.record![restaurantLinkKey] = currentRestaurantLink
        saveEmployee(employee.record!)
    }
    
     func updateEmployee(_ employee: Employee) {
        let predicate = NSPredicate(format: "\(idkKey) == %@", employee.id)
        let query = CKQuery(recordType: recordType, predicate: predicate)
        let queryOperation = CKQueryOperation(query: query)
        
        queryOperation.recordMatchedBlock = { [weak self] (_, result) in
            guard case .success(let record) = result else { return }
            record[self?.nameKey ?? ""] = employee.name
            record[self?.lastNameKey ?? ""] = employee.lastName
            self?.saveEmployee(record)
        }
        
        addQueryOperation(queryOperation) 
    }
    
     func fetchEmployees() {
        
        let predicate = NSPredicate(format: "\(restaurantLinkKey) == %@", currentRestaurantLink)
        let query = CKQuery(recordType: recordType, predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor (key: lastNameKey, ascending: true)]
        let queryOperation = CKQueryOperation(query: query)
        
        DispatchQueue.main.async { [weak self] in
            self?.employees = []
        }
        
        queryOperation.recordMatchedBlock = { [weak self] (_, result) in
            guard case .success(let record) = result else { return }
            
            let empleado = Employee(record: record)
            
            DispatchQueue.main.async {
                self?.employees.append(empleado)
            }
        }
        
        queryOperation.queryResultBlock = { _ in
            DispatchQueue.main.async { [weak self] in
                self?.employees = self?.employees ?? []
            }
        }
        
        addQueryOperation(queryOperation)
        
    }
    
    private func saveEmployee(_ record: CKRecord) {
        dataBase.save(record) { [weak self] record, _ in
            guard let _ = record else { return }
            self?.fetchEmployees()
        }
    }
    
    private func addQueryOperation(_ queryOperation: CKQueryOperation) {
        dataBase.add(queryOperation)
    }
}
