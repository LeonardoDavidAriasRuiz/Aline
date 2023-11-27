//
//  WorksheetSettingsView.swift
//  Aline
//
//  Created by Leonardo on 15/10/23.
//

import SwiftUI
import CloudKit

struct WorksheetSettingsView: View {
    @EnvironmentObject private var restaurantM: RestaurantPickerManager
    @EnvironmentObject private var alertVM: AlertViewModel
    @EnvironmentObject private var userVM: UserViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var worksheetSettings: WorksheetSettings = WorksheetSettings()
    @State private var isLoading: Bool = false
    @State private var importingLogo: Bool = false
    @State private var logoHovering: Bool = false
    
//    @Binding var worksheet: Worksheet
    
    var body: some View {
        FullSheet(section: .worksheetSettings, isLoading: $isLoading) {
            ScrollView(.horizontal) {
                WhiteArea {
                    TextField("Titulo", text: $worksheetSettings.worksheetTitle).bold().font(.largeTitle).foregroundStyle(Color.green).multilineTextAlignment(.center)
                    Text("PAYROLL WORKSHEET").bold().font(.title).foregroundStyle(Color.blue)
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                saveToolBarButton
                            }
                            ToolbarItemGroup(placement: .topBarLeading) {
                                Button(action: {dismiss()}) {
                                    Text("Cancelar").foregroundStyle(Color.red)
                                }
                            }
                        }
                    HStack {
                        Button(action: {importingLogo = true}) {
                            ZStack {
                                Image(uiImage: worksheetSettings.logo).resizable().scaledToFill().frame(width: 150, height: 150)
                                    .clipShape(Circle())
                                if logoHovering {
                                    VStack {
                                        Image(systemName: "plus").font(.system(size: 120))
                                    }.frame(width: 150, height: 150).background(.black.opacity(0.2)).clipShape(Circle())
                                }
                            }
                            .onHover { hovering in
                                logoHovering = hovering
                            }
                        }
                        .fileImporter(isPresented: $importingLogo, allowedContentTypes: [.jpeg, .png, .svg, .image]) { result in
                            if case .success(let url) = result,
                               let data = try? Data(contentsOf: url), let uiImage = UIImage(data: data) {
                                self.worksheetSettings.logo = uiImage
                            } else {
                                
                            }
                        }
                        
                        Spacer()
                        VStack {
                            Text("Pay date:").bold().foregroundStyle(Color.orange)
                            Text(Date().shortDate)
                            Text("")
                            Text("Starting Check # Direct Deposit").bold().foregroundStyle(.gray)
                            HStack {
                                Text("From:").bold().foregroundStyle(Color.blue)
                                Text(Date().shortDate)
                            }
                            HStack {
                                Text("To:").bold().foregroundStyle(Color.blue)
                                Text(Date().shortDate)
                            }
                        }
                    }
                    
                    TextField("Company name", text: $worksheetSettings.companyName).bold().font(.title2).foregroundStyle(Color.red)
                    TextField("# Street Ste", text: $worksheetSettings.numberStreetSte).foregroundStyle(Color.orange)
                    TextField("City, State abbreviated P.C.", text: $worksheetSettings.cityStatePC).foregroundStyle(Color.orange).padding(.bottom, 70)
                }.frame(width: 1275)
                
            }
        }
        .shadow(radius: 10)
        .navigationBarBackButtonHidden()
        .onAppear(perform: getSettings)
        .onChange(of: restaurantM.currentId, {dismiss()})
    }
    
    private var saveToolBarButton: some View {
        VStack {
            if checkIfSpendingReadyToSave() {
                Button(action: save) {
                    Text("Guardar")
                }
            } else {
                Menu("Guardar") {
                    if worksheetSettings.worksheetTitle.isEmpty {
                        Text("Escribe un título.")
                    }
                    if worksheetSettings.companyName.isEmpty {
                        Text("Escribe el nombre de la empresa..")
                    }
                    if worksheetSettings.numberStreetSte.isEmpty || worksheetSettings.cityStatePC.isEmpty {
                        Text("Escribe una dirección.")
                    }
                }
            }
        }
    }
    
    private func checkIfSpendingReadyToSave() -> Bool {
        return worksheetSettings.worksheetTitle.isNotEmpty &&
        worksheetSettings.companyName.isNotEmpty &&
        worksheetSettings.numberStreetSte.isNotEmpty &&
        worksheetSettings.cityStatePC.isNotEmpty
    }
    
    private func save() {
        isLoading = true
        worksheetSettings.restaurantId = restaurantM.currentId
        WorksheetSettingsViewModel().save(worksheetSettings.record) {
            dismiss()
        } ifNot: {
            alertVM.show(.crearingError)
        }
    }
    
    private func getSettings() {
        isLoading = true
        WorksheetSettingsViewModel().fetch(for: restaurantM.currentId) { worksheets in
            if let worksheets = worksheets {
                if let worksheet = worksheets.first {
                    worksheetSettings = worksheet
                }
            } else {
                alertVM.show(.dataObtainingError)
            }
            isLoading = false
        }
    }
}
