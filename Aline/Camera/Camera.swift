//
//  Camera.swift
//  Aline
//
//  Created by Leonardo on 16/08/23.
//

import SwiftUI

struct Camera: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var open: Bool

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: Camera
        
        init(_ parent: Camera) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            parent.image = info[.originalImage] as? UIImage
            withAnimation { parent.open = false }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            withAnimation { parent.open = false }
        }
    }
}
