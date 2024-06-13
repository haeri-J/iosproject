import SwiftUI

struct RecipeRecommendationView: View {
    
    @EnvironmentObject var foodItems: FoodItems
    
    @State private var recommendedRecipes: [Recipe] = []
    @State private var selectedRecipe: Recipe?
    @State private var showDetail = false
//    @State private var selectedCategory: String = "밥"{
//    didSet {
//               updateRecipes()
//           }
//    }
    

    let categories = ["밥", "국&찌개", "반찬", "후식", "일품", "기타"]
    
    var body: some View {
        VStack {
            Picker("카테고리 선택", selection: $foodItems.selectedCategory) {
                ForEach(categories, id: \.self) { category in
                    Text(category).tag(category)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            List(foodItems.recommendedRecipes) { recipe in
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
            }.onAppear {
                foodItems.updateRecipes()
            }
            
            .sheet(isPresented: $showDetail) {
                if let selectedRecipe = selectedRecipe {
                    RecipeDetailView(recipe: selectedRecipe)
                }
            }
        }
    }
}

