//
//  EditFoodItemView.swift
//  iosN_2171438_johaeri
//
//  Created by mac029 on 2024/06/04.
//

import SwiftUI
//사용자의 냉장고 재료 수정하기 위한 뷰
struct EditFoodItemView: View {
    @Binding var foodItem: FoodItem // 상위뷰의 FoodItem의 정보를 수정할 수 있도록 Binding 사용
    @Environment(\.presentationMode) var presentationMode // 뷰를 닫기 위한 환경 변수
    @State private var showingImagePicker = false //.sheet를 표시할지 여부를 정하는 변수
    @State private var inputImage: UIImage? {
          didSet {
              foodItem.image = inputImage //inputImage가 변경될 때마다 foodItem.image도 업데이트
          }
      }
    

    var body: some View {
        Form {
            Section(header: Text("음식 정보")) {
                
                TextField("이름", text: $foodItem.name)//이름 받고 이름 넣기
                DatePicker("유통기한", selection: $foodItem.expirationDate, displayedComponents: .date)//날짜받고 날자 저장
                TextField("메모", text: $foodItem.memo)//메모 받고 메모저장
                // 사진 추가 및 수정 기능 구현
                Section {
                    if let image = inputImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                    }
                    Button("사진 선택") {
                        showingImagePicker = true//.sheet 함수 실행
                    }
                }
            }
            Button("완료") {
                self.presentationMode.wrappedValue.dismiss() // 완료 버튼을 누르면 뷰를 닫음
            }
        }
        .navigationTitle("음식 정보 수정하기")
        .sheet(isPresented: $showingImagePicker) {//$showingImagePicker가 트루면 ImagePicker 호출
            ImagePicker(selectedImage: $inputImage)
        }
    }
}



