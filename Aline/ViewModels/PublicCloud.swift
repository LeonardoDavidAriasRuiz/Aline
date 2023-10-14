//
//  PublicCloud.swift
//  Aline
//
//  Created by Leonardo on 03/10/23.
//

import Foundation
import CloudKit

class PublicCloud {
    let dataBase: CKDatabase = CKContainer.default().publicCloudDatabase
    
    func save(_ record: CKRecord, saved: @escaping () -> Void, ifNot: @escaping () -> Void, alwaysDo: @escaping () -> Void) {
        dataBase.save(record) { record, error in
            if record != nil {
                DispatchQueue.main.async {
                    saved()
                }
            } else {
                DispatchQueue.main.async {
                    ifNot()
                }
            }
            DispatchQueue.main.async {
                alwaysDo()
            }
        }
    }
    
    func save(_ record: CKRecord, saved: @escaping () -> Void, ifNot: @escaping () -> Void) {
        dataBase.save(record) { record, error in
            if record != nil {
                DispatchQueue.main.async {
                    saved()
                }
            } else {
                DispatchQueue.main.async {
                    ifNot()
                }
            }
        }
    }
    
    func delete(_ record: CKRecord, saved: @escaping () -> Void, ifNot: @escaping () -> Void, alwaysDo: @escaping () -> Void) {
        dataBase.delete(withRecordID: record.recordID) { recordID, _ in
            if recordID != nil {
                DispatchQueue.main.async {
                    saved()
                }
            } else {
                DispatchQueue.main.async {
                    ifNot()
                }
            }
            DispatchQueue.main.async {
                alwaysDo()
            }
        }
    }
    
    func delete(_ record: CKRecord, saved: @escaping () -> Void, ifNot: @escaping () -> Void) {
        dataBase.delete(withRecordID: record.recordID) { recordID, _ in
            if recordID != nil {
                DispatchQueue.main.async {
                    saved()
                }
            } else {
                DispatchQueue.main.async {
                    ifNot()
                }
            }
        }
    }
}
