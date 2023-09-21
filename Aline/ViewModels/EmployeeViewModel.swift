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
    
    func save(_ employee: Employee, isNew: Bool, completion: @escaping (Bool) -> Void) {
        dataBase.save(employee.record) { record, _ in
            completion(record != nil)
        }
    }
    
    func fetchEmployees(for restaurantId: String, completion: @escaping ([Employee]?) -> Void) {
        let predicate = NSPredicate(format: "\(employeeKeys.restaurantId) == %@", restaurantId)
        let query = CKQuery(recordType: employeeKeys.type, predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor (key: employeeKeys.lastName, ascending: true)]
        
        dataBase.fetch(withQuery: query) { result in
            guard case .success(let data) = result else { completion(.none); return }
            let employees = data.matchResults.compactMap { (_, result) -> Employee? in
                guard case .success(let record) = result else {completion(.none); return nil }
                return Employee(record: record)
            }
            completion(employees)
        }
    }
    
    func delete(_ employee: Employee, completion: @escaping (Bool) -> Void) {
        dataBase.delete(withRecordID: employee.record.recordID) { (recordID, _) in
            completion(recordID != nil)
        }
    }
}
