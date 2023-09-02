//
//  TipsCashOutView.swift
//  Aline
//
//  Created by Leonardo on 30/08/23.
//

import SwiftUI

struct TipsCashOutView: View {
    @EnvironmentObject private var restaurantVM: RestaurantViewModel
    @EnvironmentObject private var employeeVM: EmployeeViewModel
    @EnvironmentObject private var userVM: UserViewModel
    
    @State private var employees: [Employee] = []
    @State private var employeesSelected: [Bool] = []
    
    @State private var tipsTotal: Double = 0.0
    @State private var employeesCountSelected: Int = 0
    @State private var tipsDate: Date = Date()
    
    @State private var isLoading: Bool = false
    @State private var errorOn: Bool = false
    @State private var errorAlert: AlertType = .dataObtainingError
    
    @State private var openCamera: Bool = false
    @State private var selectedImage: UIImage?
    
    var body: some View {
        LoadingIfNotReady($isLoading) {
            tipsCahsOutArea
        }
        .onAppear(perform: onAppear)
        .alertInfo(errorAlert, showed: $errorOn)
    }
    
    private var tipsCahsOutArea: some View {
        VStack {
            WhiteArea {
                HStack {
                    Text("Cantidad: ").onTapGesture (perform: hideKeyboard)
                    DecimalField("Tips", decimal: $tipsTotal)
                    DatePicker("", selection: $tipsDate, displayedComponents: .date)
                        .onTapGesture (perform: hideKeyboard)
                }
            }
            WhiteArea {
                ForEach(employees.indices, id: \.self) { index in
                    HStack {
                        Text("\(String(employees[index].lastName.first ?? "-")). \(employees[index].name)")
                        Spacer()
                        if employeesCountSelected != 0,
                        employeesSelected[index],
                        tipsTotal != 0.0 {
                            let tipAmount: Double = tipsTotal / Double(employeesCountSelected)
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
            SaveButtonWhite(action: {}).disabled(!checkIfReadyToSave())
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
    
    private func checkIfReadyToSave() -> Bool {
        tipsTotal <= 0.0 &&
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
        employeeVM.fetchEmployees(for: restaurantVM.restaurant.id) { employees in
            if let employees = employees {
                self.employees = employees.filter { $0.isActive }
                employeesSelected = Array(repeating: false, count: employees.count)
            } else {
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
