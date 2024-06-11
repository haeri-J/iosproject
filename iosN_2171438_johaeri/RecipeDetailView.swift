//
//  RecipeDetailView.swift
//  iosN_2171438_johaeri
//
//  Created by mac029 on 2024/06/10.
//

import SwiftUI

import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 이미지가 존재할 경우 표시
                if let imageUrl = recipe.ATT_FILE_NO_MAIN, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                    } placeholder: {
                        ProgressView()
                    }
                } else {
                    Rectangle()
                        .fill(Color.gray)
                        .frame(height: 200)
                }
                
                // 레시피 기본 정보 표시
                Text(recipe.RCP_NM)
                    .font(.largeTitle)
                    .bold()
                Text("열량: \(recipe.INFO_ENG ?? "N/A")")
                    .font(.headline)
                Text("탄수화물: \(recipe.INFO_CAR ?? "N/A") | 단백질: \(recipe.INFO_PRO ?? "N/A") | 지방: \(recipe.INFO_FAT ?? "N/A") | 나트륨: \(recipe.INFO_NA ?? "N/A")")
                    .font(.subheadline)
                Text("재료: \(recipe.RCP_PARTS_DTLS)")
                    .font(.subheadline)
                Text("Step:\(recipe.MANUALS ?? "제발")")
                    .font(.subheadline)
                
                Divider()
                
                // 만드는 법과 해당 이미지 표시
                ForEach(0..<recipe.MANUALS.count, id: \.self) { index in
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Step \(index + 1)")
                            .font(.headline)
                        Text(recipe.MANUALS[index])
                            .font(.body)

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
                    Divider()
                }
            }
            .padding()
        }
        .navigationTitle("레시피 상세 정보")
    }
}


//struct RecipeDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        RecipeDetailView()
//    }
//}
