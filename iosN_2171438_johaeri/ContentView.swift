import SwiftUI
import Combine

// FoodItem 구조체는 냉장고에 저장된 음식 아이템을 나타냄
struct FoodItem: Identifiable {
    let id = UUID() // 각 아이템을 고유하게 식별하기 위한 UUID
    var name: String // 음식 이름
    var expirationDate: Date // 유통기한
    var memo: String // 메모
    var image: UIImage? // 이미지
}

// FoodItems 클래스는 ObservableObject로 지정 //@ObservedObject는 ObservableObject 프로토콜을 준수하는 객체를 관찰하는 뷰 내에서 사용되는 프로퍼티 래퍼
class FoodItems: ObservableObject {
    @Published var items: [FoodItem] = [] //냉장고에 저장된 음식 아이템 배열로, @Published는 인스턴스의 변화를 감지하고 해당 인스턴스가 변화할 때 마다 뷰를 업데이트함.
    @Published var recipes: [Recipe] = [] // 레시피 데이터를 저장하는 배열
    @Published var selectedCategory: String = "밥" { // 사용자가 선택한 카테고리, 기본값은 "밥"
        didSet {
            updateRecipes() // 카테고리가 변경되면 추천 레시피를 업데이트
        }
    }
    @Published var recommendedRecipes: [Recipe] = [] // 추천 레시피가 저장되는 배열

    // 초기화 메서드
    init() {
        // 앱이 시작될 때 API를 호출하여 레시피 데이터를 가져옴.
        fetchRecipes(matching: items.map { $0.name }) { recipes in
            self.recipes = recipes //가져온 레시피 저장
            self.updateRecipes() // 레시피를 가져온 후 추천 레시피를 업데이트
        }
    }

    // 추천 레시피를 업데이트하는 메서드
    public func updateRecipes() {
        DispatchQueue.main.async {
            self.recommendedRecipes = self.recipes.filter { recipe in
                //  fetchRecipeData의 재료분석 로직 호출로, 선택된 카테고리가 같은지 확인
                compareIngredients(recipe.RCP_PARTS_DTLS, recipeName: recipe.RCP_NM, userIngredients: self.items.map { $0.name }) &&
                recipe.RCP_PAT2 == self.selectedCategory
            }
        }
    }
}
//시작뷰
struct ContentView: View {
    @StateObject private var foodItems = FoodItems() // 참조 타입 객체를 뷰의 상태로 관리

    var body: some View {
        TabView {
            // 첫 번째 탭: 냉장고 뷰
            NavigationView {
                MyListView()
                    .navigationTitle("냉장고")
            }
            .tabItem {
                Image(systemName: "list.bullet")
                Text("냉장고")
            }
            .environmentObject(foodItems) // FoodItems 객체를 environmentObject로 전달

            // 두 번째 탭: 레시피 추천 뷰
            NavigationView {
                RecipeRecommendationView()
                    .navigationTitle("레시피 추천")
            }
            .tabItem {
                Image(systemName: "book.fill")
                Text("레시피 추천")
            }
            .environmentObject(foodItems) // FoodItems 객체를 environmentObject로 전달
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
