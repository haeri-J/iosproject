import SwiftUI
import Combine

struct FoodItem: Identifiable {
    let id = UUID()
    var name: String
    var expirationDate: Date
    var memo: String
    var image: UIImage?
}

class FoodItems: ObservableObject {
    @Published var items: [FoodItem] = []
    @Published var recipes: [Recipe] = [] // 레시피 데이터를 저장하는 배열
    @Published var selectedCategory: String = "밥" {
        didSet {
            updateRecipes()
        }
    }
    @Published var recommendedRecipes: [Recipe] = []

    init() {
        // 앱이 시작될 때 API를 호출하여 레시피 데이터를 가져옵니다.
        fetchRecipes(matching: items.map { $0.name }) { recipes in
            self.recipes = recipes
            self.updateRecipes()
        }
    }

    public func updateRecipes() {
        DispatchQueue.main.async {
            self.recommendedRecipes = self.recipes.filter { recipe in
                compareIngredients(recipe.RCP_PARTS_DTLS, recipeName: recipe.RCP_NM, userIngredients: self.items.map { $0.name }) &&
                recipe.RCP_PAT2 == self.selectedCategory
            }
        }
    }
}



struct ContentView: View {
    @StateObject private var foodItems = FoodItems()
    
    var body: some View {
        TabView {
            NavigationView {
                MyListView()
                    .navigationTitle("냉장고")
            }
            .tabItem {
                Image(systemName: "list.bullet")
                Text("냉장고")
            }
            .environmentObject(foodItems)
           
            NavigationView {
                RecipeRecommendationView()
                    .navigationTitle("레시피 추천")
            }
            .tabItem {
                Image(systemName: "book.fill")
                Text("레시피 추천")
            }
            .environmentObject(foodItems)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
