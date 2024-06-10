//
//  imagePicker.swift
//  iosN_2171438_johaeri
//
//  Created by mac029 on 2024/06/05.
//

import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
        @Environment(\.presentationMode) var presentationMode

        func makeUIViewController(context: Context) -> some UIViewController {
            let picker = UIImagePickerController()
            picker.delegate = context.coordinator
            return picker
        }

        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}

        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }

        class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
            var parent: ImagePicker
            init(_ parent: ImagePicker) {
                self.parent = parent
            }

            func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
                if let image = info[.originalImage] as? UIImage {
                    parent.selectedImage = image
                }

                parent.presentationMode.wrappedValue.dismiss()
            }
        }
}
//
//struct imagePicker_Previews: PreviewProvider {
//    static var previews: some View {
//        ImagePicker()
//    }
//}
