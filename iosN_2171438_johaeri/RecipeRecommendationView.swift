//
//  RecipeRecommendationView.swift
//  iosN_2171438_johaeri
//
//  Created by mac029 on 2024/06/05.
//

import SwiftUI

struct RecipeRecommendationView: View {
    
    @EnvironmentObject var foodItems: FoodItems
    
    @State private var recommendedRecipes: [Recipe] = []
    @State private var selectedRecipe: Recipe?
    @State private var showDetail = false
    @State private var selectedCategory: String = "밥"

    let categories = ["밥", "국&찌개", "반찬", "후식", "일품", "기타"]
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("카테고리 선택", selection: $selectedCategory) {
                    ForEach(categories, id: \.self) { category in
                        Text(category).tag(category)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                List(recommendedRecipes) { recipe in
                    Button(action: {
                        selectedRecipe = recipe
                        showDetail = true
                    }) {
                        HStack {
                            if let imageUrl = recipe.ATT_FILE_NO_MAIN, let url = URL(string: imageUrl) {
                                AsyncImage(url: url) { image in
                                    image.resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 50, height: 50)
                                        .clipped()
                                } placeholder: {
                                    ProgressView()
                                }
                            } else {
                                Rectangle()
                                    .fill(Color.gray)
                                    .frame(width: 50, height: 50)
                            }
                            VStack(alignment: .leading) {
                                Text(recipe.RCP_NM)
                                    .font(.headline)
                                Text("열량: \(recipe.INFO_ENG ?? "N/A")")
                                    .font(.subheadline)
                            }
                        }
                    }
                }
                .navigationTitle("추천 레시피")
                // 레시피 추천 로직
                .onAppear {
                    fetchRecipes(matching: foodItems.items.map { $0.name }) { recipes in
                        self.recommendedRecipes = recipes.filter { recipe in
                            compareIngredients(recipe.RCP_PARTS_DTLS, recipeName: recipe.RCP_NM, userIngredients: foodItems.items.map { $0.name }) &&
                            recipe.RCP_PAT2 == selectedCategory
                        }
                    }
                }
                .sheet(isPresented: $showDetail) {
                    if let selectedRecipe = selectedRecipe {
                        RecipeDetailView(recipe: selectedRecipe)
                    }
                }
            }
        }
    }
}

struct RecipeRecommendationView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeRecommendationView()
    }
}
