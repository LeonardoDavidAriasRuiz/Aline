//
//  SaleViewModel.swift
//  Aline
//
//  Created by Leonardo on 30/08/23.
//

import CloudKit
import SwiftUI

class SaleViewModel {
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
    
    func fetchSales(for restaurantId: String, from: Date, to: Date, completion: @escaping ([Sale]?) -> Void) {
        var sales: [Sale] = []
        
        let predicates = [
            NSPredicate(format: "\(saleKeys.restaurantId) == %@", restaurantId),
            NSPredicate(format: "\(saleKeys.date) >= %@", from as NSDate),
            NSPredicate(format: "\(saleKeys.date) <= %@", to as NSDate)
        ]
        
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        let query = CKQuery(recordType: saleKeys.type, predicate: compoundPredicate)
        
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.resultsLimit = CKQueryOperation.maximumResults
        
        queryOperation.recordMatchedBlock = { (_, result) in
            switch result {
                case .success(let record):
                    sales.append(Sale(record: record))
                case .failure:
                    completion(.none)
            }
        }
        
        queryOperation.queryResultBlock = { result in
            switch result {
                case .success(let cursor):
                    if let cursor = cursor {
                        fetchLeftSales(cursor: cursor) { newSales in
                            if let newSales = newSales {
                                sales.append(contentsOf: newSales)
                            }
                            completion(sales)
                        }
                    } else {
                        completion(sales)
                    }
                case .failure:
                    completion(.none)
            }
            
        }
        
        dataBase.add(queryOperation)
        
        func fetchLeftSales(cursor: CKQueryOperation.Cursor, completion2: @escaping ([Sale]?) -> Void) {
            var newSales: [Sale] = []
            
            let queryOperation = CKQueryOperation(cursor: cursor)
            
            queryOperation.recordMatchedBlock = { (_, result) in
                switch result {
                    case .success(let record):
                        newSales.append(Sale(record: record))
                    case .failure:
                        completion2(.none)
                }
            }
            
            queryOperation.queryResultBlock = { result in
                switch result {
                    case .success(let cursor):
                        if let cursor = cursor {
                            fetchLeftSales(cursor: cursor) { returnedSales in
                                if let returnedSales = returnedSales {
                                    newSales.append(contentsOf: returnedSales)
                                }
                                completion2(newSales)
                            }
                        } else {
                            completion2(newSales)
                        }
                    case .failure:
                        completion2(.none)
                }
            }
            
            self.dataBase.add(queryOperation)
        }
    }
    
    func delete(_ sale: Sale, completion: @escaping (Bool) -> Void) {
        dataBase.delete(withRecordID: sale.record.recordID) { (recordID, _) in
            completion(recordID != nil)
        }
    }
    
    func delete(_ sales: [Sale]) {
        for sale in sales {
            dataBase.delete(withRecordID: sale.record.recordID) { (recordID, _) in
                
            }
        }
    }
}

