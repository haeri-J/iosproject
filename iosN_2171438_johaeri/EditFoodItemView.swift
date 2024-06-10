//
//  EditFoodItemView.swift
//  iosN_2171438_johaeri
//
//  Created by mac029 on 2024/06/04.
//

import SwiftUI

struct EditFoodItemView: View {
    @Binding var foodItem: FoodItem // FoodItem의 정보를 수정할 수 있도록 Binding 사용
    @Environment(\.presentationMode) var presentationMode // 뷰를 닫기 위한 환경 변수
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?

    var body: some View {
        Form {
            Section(header: Text("음식 정보")) {

                TextField("이름", text: $foodItem.name)
                DatePicker("유통기한", selection: $foodItem.expirationDate, displayedComponents: .date)
                TextField("메모", text: $foodItem.memo)
                // 사진 추가 및 수정 기능 구현
                Section {
                    if foodItem.image != nil {
                        Image(uiImage: foodItem.image!)
                            .resizable()
                            .scaledToFit()
                    }
                    Button("사진 선택") {
                        showingImagePicker = true
                    }
                }
            }
            Button("완료") {
                if let inputImage = inputImage {
                                   foodItem.image = inputImage
                               }
                self.presentationMode.wrappedValue.dismiss() // 완료 버튼을 누르면 뷰를 닫음
            }
        }
        .navigationTitle("음식 정보 수정하기")
        .sheet(isPresented: $showingImagePicker) {//.sheet 모달 뷰를 보여주는 데 사용하는 뷰 수식어
            ImagePicker(selectedImage: $inputImage)
              }
    }
}

struct EditFoodItemView_Previews: PreviewProvider {
    @State static var foodItem = FoodItem(name: "1", expirationDate: Date(), memo: "Fresh and juicy", image: UIImage(named: "milk"))

    static var previews: some View {
        EditFoodItemView(foodItem: $foodItem)
    }
}

