//
//  EmployeeViewModel.swift
//  Aline
//
//  Created by Leonardo David Arias Ruiz on 07/04/23.
//

import CloudKit
import SwiftUI

class EmployeeViewModel: ObservableObject {
    
    
    private let dataBase: CKDatabase = CKContainer.default().publicCloudDatabase
    private let employeeKeys: EmployeeKeys = EmployeeKeys()
    
    func delete(_ employee: Employee) {
        dataBase.delete(withRecordID: employee.record.recordID) { (_, error) in
            guard let _ = error else { return }
            
        }
    }
    
    func fetchEmployees(for restaurantId: String, completion: @escaping (Result<[Employee], Error>) -> Void) {
        var employees: [Employee] = []
        
        let predicate = NSPredicate(format: "\(employeeKeys.restaurantId) == %@", restaurantId)
        let query = CKQuery(recordType: employeeKeys.type, predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor (key: employeeKeys.lastName, ascending: true)]
        let queryOperation = CKQueryOperation(query: query)
        
        queryOperation.recordMatchedBlock = { (_, result) in
            switch result {
                case .success(let record):
                    employees.append(Employee(record: record))
                case .failure(let error):
                    completion(.failure(error))
            }
        }
        
        queryOperation.queryResultBlock = { _ in
            completion(.success(employees))
        }
        dataBase.add(queryOperation)
    }
    
    func save(_ employee: Employee, isNew: Bool, completion: @escaping (Result<Employee, Error>) -> Void) {
        let record = isNew ? CKRecord(recordType: employeeKeys.type) : employee.record
        record[employeeKeys.id] = employee.id
        record[employeeKeys.name] = employee.name
        record[employeeKeys.lastName] = employee.lastName
        record[employeeKeys.restaurantId] = employee.restaurantId
        
        dataBase.save(record) { record, error in
            if let record = record {
                completion(.success(Employee(record: record)))
            } else if let error = error {
                completion(.failure(error))
            }
        }
    }
}
