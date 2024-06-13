//
//  imagePicker.swift
//  iosN_2171438_johaeri
//
//  Created by mac029 on 2024/06/05.
//

import SwiftUI

// ImagePicker는 UIViewControllerRepresentable 프로토콜을 채택하여 UIKit의 UIImagePickerController를 SwiftUI에서 사용할 수 있게 함.
struct ImagePicker: UIViewControllerRepresentable {
    // 선택된 이미지를 저장할 바인딩 변수
    @Binding var selectedImage: UIImage?
    // 현재 뷰의 프레젠테이션 모드를 나타내는 환경 변수
    @Environment(\.presentationMode) var presentationMode

    // UIImagePickerController 인스턴스를 생성하고 반환하는 함수
    func makeUIViewController(context: Context) -> some UIViewController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator // delegate를 설정
        return picker
    }

    // UIViewController 업데이트 함수 (여기서는 특별한 작업을 하지 않음)
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}

    // Coordinator 인스턴스를 생성하는 함수
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // Coordinator 클래스는 UIImagePickerControllerDelegate 및 UINavigationControllerDelegate 프로토콜을 채택
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePicker
        
        // Coordinator의 생성자
        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        // 사용자가 이미지를 선택했을 때 호출되는 함수
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            // 선택된 이미지를 바인딩 변수에 저장
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image //부모(editFoodItem)의selectedImage에 image를 넣음
            }

            // 이미지 피커를 닫음
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

