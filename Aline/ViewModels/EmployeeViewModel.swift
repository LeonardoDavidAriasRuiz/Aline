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
    
    func fetch(restaurantId: String, completion: @escaping ([Employee]?) -> Void) {
        let predicate = NSPredicate(format: "\(keys.restaurantId) == %@", restaurantId)
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
}
