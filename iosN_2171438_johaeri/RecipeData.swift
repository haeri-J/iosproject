import Foundation
import Combine

class RecipeData: ObservableObject {
    @Published var recipes: [Recipe] = []
    @Published var isLoading = false
    
    init() {
        fetchAllRecipes()
    }
    
    private func fetchAllRecipes() {
        isLoading = true
        fetchRecipes(matching: []) { recipes in
            self.recipes = recipes
            self.isLoading = false
        }
    }
}
