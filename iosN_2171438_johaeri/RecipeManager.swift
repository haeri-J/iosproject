import Foundation

class RecipeManager {
    static let shared = RecipeManager()
    
    private init() {}
    
    private var cachedRecipes: [Recipe]?
    
    func fetchRecipes(matching ingredients: [String], completion: @escaping ([Recipe]) -> Void) {
        if let cachedRecipes = cachedRecipes {
            let filteredRecipes = cachedRecipes.filter { compareIngredients($0.RCP_PARTS_DTLS, recipeName: $0.RCP_NM, userIngredients: ingredients) }
            completion(filteredRecipes)
            return
        }
        
        var allRecipes: [Recipe] = []
        let batchSize = 1000
        var start = 1
        var end = batchSize
        
        func fetchBatch() {
            guard let url = createRecipeURL(start: start, end: end) else {
                print("Invalid URL")
                return
            }

            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                guard let data = data, error == nil else {
                    print("Error fetching data")
                    return
                }

                do {
                    let container = try JSONDecoder().decode(RecipeContainer.self, from: data)
                    let recipes = container.COOKRCP01.recipes
                    allRecipes.append(contentsOf: recipes)

                    if recipes.count == batchSize {
                        // 아직 더 많은 데이터가 남아있음. 다음 배치를 가져옴.
                        start += batchSize
                        end += batchSize
                        fetchBatch()
                    } else {
                        // 모든 데이터를 다 가져왔음.
                        DispatchQueue.main.async {
                            self.cachedRecipes = allRecipes
                            let filteredRecipes = allRecipes.filter { compareIngredients($0.RCP_PARTS_DTLS, recipeName: $0.RCP_NM, userIngredients: ingredients) }
                            print("Total recipes fetched: \(allRecipes.count)")
                            completion(filteredRecipes)
                        }
                    }
                } catch {
                    print("Error decoding data: \(error)")
                }
            }

            task.resume()
        }
        
        fetchBatch()
    }
}
