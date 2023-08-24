//
//  CashOutView.swift
//  Aline
//
//  Created by Leonardo David Arias Ruiz on 05/04/23.
//

import SwiftUI

struct CashOutView: View {
    
    @EnvironmentObject private var restaurantVM: RestaurantViewModel
    @EnvironmentObject private var employeeVM: EmployeeViewModel
    @EnvironmentObject private var userVM: UserViewModel
    @EnvironmentObject private var accentColor: AccentColor
    
    @State private var employees: [Employee] = []
    @State private var employeesSelected: [Bool] = []
    
    @State private var cashOutSectionSelected: String = "Tips"
    @State private var tipsTotal: String = ""
    @State private var employeesCountSelected: Int = 0
    @State private var tipsDate: Date = Date()
    
    @State private var isLoading: Bool = false
    @State private var errorOn: Bool = false
    @State private var errorAlert: AlertType = .dataObtainingError
    
    @State private var openCamera: Bool = false
    @State var selectedImage: UIImage?
    
    var body: some View {
        Sheet(section: .cashOut) {
                cashOutSectionPicker
                if cashOutSectionSelected == "Ventas" {
                    salesCashOutArea
                } else {
                    LoadingIfNotReady($isLoading) {
                        tipsCahsOutArea
                    }
                }
            
        }
        .onAppear(perform: onAppear)
        .tint(Color.red)
        .alertInfo(errorAlert, showed: $errorOn)
    }
    
    private var cashOutSectionPicker: some View {
        Picker(cashOutSectionSelected, selection: $cashOutSectionSelected) {
            Text("Ventas").tag("Ventas")
            Text("Tips").tag("Tips")
        }
        .pickerStyle(.segmented)
    }
    
    private var salesCashOutArea: some View {
        VStack {
            
        }
    }
    
    private var tipsCahsOutArea: some View {
        VStack {
            WhiteArea {
                HStack {
                    Text("Cantidad: ").onTapGesture (perform: hideKeyboard)
                    TextField("Tips", text: $tipsTotal)
                        .keyboardType(.decimalPad)
                        .foregroundStyle(.secondary)
                        .onChange(of: tipsTotal, validateTipsQuantity)
                    DatePicker("", selection: $tipsDate, displayedComponents: .date)
                        .onTapGesture (perform: hideKeyboard)
                }
            }
            WhiteArea {
                ForEach(employees.indices, id: \.self) { index in
                    HStack {
                        Text("\(String(employees[index].lastName.first ?? "-")). \(employees[index].name)")
                        Spacer()
                        if employeesCountSelected != 0 && employeesSelected[index] {
                            let tipAmount = (Double(tipsTotal) ?? 0.0) / Double(employeesCountSelected)
                            Text(String(format: "%.2f", tipAmount))
                                .foregroundStyle(.secondary)
                        }
                        if $employeesSelected.isNotEmpty {
                            Toggle("", isOn: $employeesSelected[index])
                                .frame(width: 50)
                                .onChange(of: employeesSelected, getNumberOfEmployeesSelected)
                        }
                    }
                    if employees.last != employees[index] {
                        Divider()
                    }
                }
            }
            .onTapGesture (perform: hideKeyboard)
            if !restaurantVM.restaurant.adminUsersIds.contains(userVM.user.id) {
                takePhotoButton
            }
            saveButton
        }
    }
    
    private func validateTipsQuantity(oldValue: String, newValue: String) {
        if newValue.isNotEmpty && Double(newValue) == nil {
            tipsTotal = oldValue
        }
    }
    
    private var cameraArea: some View {
        WhiteArea {
            Camera(image: $selectedImage, open: $openCamera)
                .clipShape(RoundedRectangle(cornerRadius: 15))
        }
    }
    
    private var takePhotoButton: some View {
        WhiteArea {
            Button(action: takePhoto) {
                Text(openCamera ? "Cancelar" : "Tomar foto")
                    .frame(maxWidth: .infinity)
            }
            if openCamera {
                Divider()
                cameraArea
            } else if let image = selectedImage {
                Divider()
                WhiteArea {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                }
            }
        }
    }
    
    private var saveButton: some View {
        WhiteArea {
            Button(action: {}) {
                Text("Guardar")
                    .frame(maxWidth: .infinity)
            }
            .disabled(!checkIfReadyToSave())
        }
    }
    
    private func checkIfReadyToSave() -> Bool {
        tipsTotal != "" &&
        Double(tipsTotal) != nil &&
        selectedImage != nil &&
        employeesCountSelected > 0
    }
    
    private func takePhoto() {
        withAnimation {
            openCamera.toggle()
        }
    }
    
    private func getNumberOfEmployeesSelected() {
        withAnimation {
            employeesCountSelected = employeesSelected.filter { $0 }.count
        }
    }
    
    private func onAppear() {
        if restaurantVM.restaurant.adminUsersIds.contains(userVM.user.id) {
            selectedImage = UIImage(named: "AppIcon")
        }
        isLoading = true
        accentColor.red()
        employeeVM.fetchEmployees(for: restaurantVM.restaurant.id) { result in
            switch result {
                case .success(let employees):
                    self.employees = employees.filter { $0.isActive }
                    employeesSelected = Array(repeating: false, count: employees.count)
                case .failure:
                    errorOn = true
                    errorAlert = .dataObtainingError
            }
            isLoading = false
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
