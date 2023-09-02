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
    
    func save(_ employee: Employee, isNew: Bool, completion: @escaping (Employee?) -> Void) {
        dataBase.save(employee.record) { record, _ in
            if let record = record {
                completion(Employee(record: record))
            } else {
                completion(.none)
            }
        }
    }
    
    func fetchEmployees(for restaurantId: String, completion: @escaping ([Employee]?) -> Void) {
        var employees: [Employee] = []
        
        let predicate = NSPredicate(format: "\(employeeKeys.restaurantId) == %@", restaurantId)
        let query = CKQuery(recordType: employeeKeys.type, predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor (key: employeeKeys.lastName, ascending: true)]
        let queryOperation = CKQueryOperation(query: query)
        
        queryOperation.recordMatchedBlock = { (_, result) in
            switch result {
                case .success(let record):
                    employees.append(Employee(record: record))
                case .failure:
                    completion(.none)
            }
        }
        
        queryOperation.queryResultBlock = { _ in
            completion(employees)
        }
        dataBase.add(queryOperation)
    }
    
    func delete(_ employee: Employee, completion: @escaping (Bool) -> Void) {
        dataBase.delete(withRecordID: employee.record.recordID) { (recordID, _) in
            completion(recordID != nil)
        }
    }
}
