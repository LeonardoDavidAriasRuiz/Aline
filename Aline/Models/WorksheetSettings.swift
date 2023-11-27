//
//  WorksheetSettings.swift
//  Aline
//
//  Created by Leonardo on 15/10/23.
//

import Foundation
import CloudKit
import SwiftUI

struct WorksheetSettings: Hashable, Equatable, Identifiable {
    private let keys: WorksheetSettingsKeys = WorksheetSettingsKeys()
    
    var id: String
    var worksheetTitle: String
    var companyName: String
    var numberStreetSte: String
    var cityStatePC: String
    var logo: UIImage
    var restaurantId: String
    
    private var _record: CKRecord
    
    var record: CKRecord {
        _record[keys.id] = id
        _record[keys.worksheetTitle] = worksheetTitle
        _record[keys.companyName] = companyName
        _record[keys.numberStreetSte] = numberStreetSte
        _record[keys.cityStatePC] = cityStatePC
        _record[keys.logo] = convertUIImageToCKAsset(logo)
        _record[keys.restaurantId] = restaurantId
        return _record
    }
    
    init() {
        self.id = UUID().uuidString
        self.worksheetTitle = ""
        self.companyName = ""
        self.numberStreetSte = ""
        self.cityStatePC = ""
        self.restaurantId = ""
        self.logo = UIImage(systemName: "circle") ?? UIImage(named: "")!
        self._record = CKRecord(recordType: keys.type)
    }
    
    init(record: CKRecord) {
        self._record = record
        self.id = record[keys.id] ?? ""
        self.worksheetTitle = record[keys.worksheetTitle] ?? ""
        self.companyName = record[keys.companyName] ?? ""
        self.numberStreetSte = record[keys.numberStreetSte] ?? ""
        self.cityStatePC = record[keys.cityStatePC] ?? ""
//        self.logo = record[keys.cityStatePC] ?? ""
        if let asset = record[keys.logo] as? CKAsset,
           let url = asset.fileURL,
           let data = try? Data(contentsOf: url),
           let image = UIImage(data: data) {
            self.logo = image
        } else {
            self.logo = UIImage(systemName: "circle") ?? UIImage(named: "")!
        }
        self.restaurantId = record[keys.restaurantId] ?? ""
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: WorksheetSettings, rhs: WorksheetSettings) -> Bool {
        lhs.id == rhs.id &&
        lhs.worksheetTitle == rhs.worksheetTitle &&
        lhs.companyName == rhs.companyName &&
        lhs.numberStreetSte == rhs.numberStreetSte &&
        lhs.cityStatePC == rhs.cityStatePC &&
        lhs.logo == rhs.logo &&
        lhs.restaurantId == rhs.restaurantId
    }
    
    func convertUIImageToCKAsset(_ image: UIImage) -> CKAsset? {
        if let imageData = image.jpegData(compressionQuality: 1.0) {
            let tempDirectory = FileManager.default.temporaryDirectory
            let tempFileURL = tempDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")
            
            do {
                try imageData.write(to: tempFileURL)
                return CKAsset(fileURL: tempFileURL)
            } catch {
                return nil
            }
        }
        return nil
    }
}
