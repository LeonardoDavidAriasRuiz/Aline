//
//  SaleViewModel.swift
//  Aline
//
//  Created by Leonardo on 30/08/23.
//

import CloudKit
import SwiftUI

class SaleViewModel: ObservableObject {
    private let dataBase: CKDatabase = CKContainer.default().publicCloudDatabase
    private let saleKeys: SalesKeys = SalesKeys()
    
    func save(_ sale: Sale, completion: @escaping (Sale?) -> Void) {
        dataBase.save(sale.record) { record, error in
            if let record = record {
                completion(Sale(record: record))
            } else {
                completion(.none)
            }
        }
    }
    
    func fetchSales(for restaurantId: String, completion: @escaping ([Sale]?) -> Void) {
        var sales: [Sale] = []
        
        let predicate = NSPredicate(format: "\(saleKeys.restaurantId) == %@", restaurantId)
        let query = CKQuery(recordType: saleKeys.type, predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor (key: saleKeys.date, ascending: false)]
        let queryOperation = CKQueryOperation(query: query)
        
        queryOperation.recordMatchedBlock = { (_, result) in
            switch result {
                case .success(let record):
                    sales.append(Sale(record: record))
                case .failure:
                    completion(.none)
            }
        }
        
        queryOperation.queryResultBlock = { _ in
            completion(sales)
        }
        dataBase.add(queryOperation)
    }
    
    func delete(_ sale: Sale, completion: @escaping (Bool) -> Void) {
        dataBase.delete(withRecordID: sale.record.recordID) { (recordID, _) in
            completion(recordID != nil)
        }
    }
}

