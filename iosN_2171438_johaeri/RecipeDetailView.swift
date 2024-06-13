//
//  RecipeDetailView.swift
//  iosN_2171438_johaeri
//
//  Created by mac029 on 2024/06/10.
//

import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe  // 앞선 RecipeRecommednationView에서 선택된 레시피 데이터를 담고 있는 변수

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 이미지가 존재할 경우 표시
                if let imageUrl = recipe.ATT_FILE_NO_MAIN, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { image in // AsyncImage는 SwiftUI에서 비동기적으로 이미지를 로드하고 표시하는 데 사용되는 뷰
                        image.resizable()
                            .aspectRatio(contentMode: .fit) // 원본 비율을 유지하면서 뷰의 크기에 맞춤
                            .frame(maxWidth: .infinity) // 뷰의 최대 너비를 설정
                    } placeholder: {
                        ProgressView() // 이미지가 로드되는 동안 로딩 스피너를 표시
                    }
                } else {
                    // 이미지가 없을 경우 회색 직사각형 표시
                    Rectangle()
                        .fill(Color.gray)
                        .frame(height: 200)
                }
                
                // 레시피 기본 정보 표시
                Text(recipe.RCP_NM)  // 레시피 이름
                    .font(.largeTitle)
                    .bold()
                Text("열량: \(recipe.INFO_ENG ?? "N/A")")  // 열량 정보
                    .font(.headline)
                Text("탄수화물: \(recipe.INFO_CAR ?? "N/A") | 단백질: \(recipe.INFO_PRO ?? "N/A") | 지방: \(recipe.INFO_FAT ?? "N/A") | 나트륨: \(recipe.INFO_NA ?? "N/A")")  // 영양 성분 정보
                    .font(.subheadline)
                Text("재료: \(recipe.RCP_PARTS_DTLS)")  // 재료 정보
                    .font(.subheadline)
                
                Divider()  // 구분선
                
                // 만드는 법과 해당 이미지 표시
                ForEach(0..<recipe.MANUALS.count, id: \.self) { index in
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Step \(index + 1)")  // 단계 번호
                            .font(.headline)
                        Text(recipe.MANUALS[index])  // 단계 설명
                            .font(.body)

                        // 단계에 해당하는 이미지가 있을 경우 표시
                        if index < recipe.MANUAL_IMGS.count, let imageUrl = recipe.MANUAL_IMGS[index], let url = URL(string: imageUrl) {
                            AsyncImage(url: url) { image in
                                image.resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: .infinity)
                            } placeholder: {
                                ProgressView()
                            }
                        }
                    }
                    Divider()  //  구분선
                }
            }
            .padding()  // 전체 패딩
        }
        .navigationTitle("레시피 상세 정보")
    }
}
