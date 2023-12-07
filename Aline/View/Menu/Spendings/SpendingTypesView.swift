//
//  SpendingTypesView.swift
//  Aline
//
//  Created by Leonardo on 25/09/23.
//

import SwiftUI

struct SpendingTypesView: View {
    @EnvironmentObject private var restaurantM: RestaurantPickerManager
    @EnvironmentObject private var menuSection: MenuSection
    @EnvironmentObject private var alertVM: AlertViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var isLoading: Bool = false
    @State private var editableSpendingTypeAreaOpened: Bool = false
    @State private var editableSpendingType: SpendingType = SpendingType()
    @State private var existingSpendingTypeSelected: Bool = false
    
    @Binding  var spendingTypes: [SpendingType]
    
    var body: some View {
        Sheet(section: .spendingTypes, isLoading: $isLoading) {
            editableSpendingTypeArea
            spendingTypesListArea
        }
        .onChange(of: menuSection.section, {dismiss()})
    }
    
    private var editableSpendingTypeArea: some View {
        WhiteArea {
            NewButton(pressed: $editableSpendingTypeAreaOpened, newText: "Nueva categoría", action: toggleEditableSpendingTypeArea)
            if editableSpendingTypeAreaOpened {
                Divider()
                TextField("Nombre", text: $editableSpendingType.name)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 8)
                Divider()
                TextField("Descripción", text: $editableSpendingType.description)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 8)
                Divider()
                if existingSpendingTypeSelected {
                    UpdateButton(action: save)
//                    Divider()
//                    DeleteButton(action: delete)
                } else {
                    SaveButton(action: save)
                }
            }
        }
    }
    
    private var spendingTypesListArea: some View {
        WhiteArea {
            ForEach(spendingTypes, id: \.self) { spendingType in
                HStack {
                    Button(action: {selectSpendingType(spendingType)}) {
                        HStack {
                            Text(spendingType.name).foregroundStyle(Color.text)
                            Spacer()
                            Text(spendingType.description).foregroundStyle(Color.text.secondary)
                            
                        }.padding(.vertical, 8)
                    }
                    if spendingType == editableSpendingType,
                       !editableSpendingTypeAreaOpened {
                        Button("Editar", action: openEditableSectionForSpendingType)
                    }
                }
                if spendingTypes.last != spendingType {
                    Divider()
                }
            }
        }
    }
    
    private func selectSpendingType(_ spendingType: SpendingType) {
        withAnimation {
            if spendingType == editableSpendingType {
                existingSpendingTypeSelected = false
                editableSpendingTypeAreaOpened = false
                editableSpendingType = SpendingType()
            } else {
                editableSpendingTypeAreaOpened = false
                editableSpendingType = spendingType
                existingSpendingTypeSelected = true
                
            }
        }
    }
    
    private func openEditableSectionForSpendingType() {
        withAnimation {
            editableSpendingTypeAreaOpened = true
        }
    }
    
    private func toggleEditableSpendingTypeArea() {
        withAnimation {
            existingSpendingTypeSelected = false
            editableSpendingType = SpendingType()
            editableSpendingTypeAreaOpened.toggle()
        }
    }
    
    private func closeEditableSpendingTypeArea() {
        withAnimation {
            editableSpendingType = SpendingType()
            editableSpendingTypeAreaOpened = false
        }
    }
    
    private func save() {
        withAnimation {
            isLoading = true
            editableSpendingType.restaurantId = restaurantM.currentId
            SpendingViewModel().save(editableSpendingType.record) { saved in
                if saved {
                    if existingSpendingTypeSelected {
                        guard let index = spendingTypes.firstIndex(where: { $0.id == editableSpendingType.id }) else { return }
                        spendingTypes[index] = editableSpendingType
                    } else {
                        spendingTypes.append(editableSpendingType)
                        spendingTypes.sort(by: {$0.name < $1.name})
                    }
                    toggleEditableSpendingTypeArea()
                } else {
                    alertVM.show(.crearingError)
                }
                isLoading = false
            }
        }
    }
    
    private func delete() {
        withAnimation {
            isLoading = true
            SpendingViewModel().delete(editableSpendingType.record) { deleted in
                if deleted {
                    spendingTypes.removeAll { $0 == editableSpendingType }
                    toggleEditableSpendingTypeArea()
                } else {
                    alertVM.show(.deletingError)
                }
                isLoading = false
            }
        }
    }
}
