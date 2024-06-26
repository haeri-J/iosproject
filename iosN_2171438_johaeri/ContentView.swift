import SwiftUI
import Combine

class FoodItem: ObservableObject, Identifiable {
    let id = UUID()
    @Published var name: String
    @Published var expirationDate: Date
    @Published var memo: String
    @Published var image: UIImage?

    init(name: String, expirationDate: Date, memo: String, image: UIImage?) {
        self.name = name
        self.expirationDate = expirationDate
        self.memo = memo
        self.image = image
    }
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
    
    @Published var selectedDate: String = "전체" {
        willSet {
            separateByDate()  // 날짜별로 음식 아이템을 분리하는 메소드
            sortByEarliestDate()// 날짜가 과거일수록 상단에 표시되도록 정렬하는 함수
        }
    }
    @Published var separateByDateFood:[FoodItem] = [] //날짜를 기점으로 냉장고 재료가 저장되는 배열
    
    
    // 초기화 메서드
    init() {
        // 앱이 시작될 때 API를 호출하여 레시피 데이터를 가져옴.
        fetchRecipes(matching: items.map { $0.name }) { recipes in
            self.recipes = recipes //가져온 레시피 저장
            self.updateRecipes() // 레시피를 가져온 후 추천 레시피를 업데이트
            self.sortByEarliestDate()
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
    // 날짜가 과거일수록 상단에 표시되도록 정렬하는 함수
        func sortByEarliestDate() {
            DispatchQueue.main.async {
                self.separateByDateFood.sort {
                    $0.expirationDate < $1.expirationDate
                }
            }
        }

    // 날짜별로 음식 아이템을 분리하는 메소드
    public func separateByDate() {
        DispatchQueue.main.async {
            self.separateByDateFood = self.items.filter { item in
                let calendar = Calendar.current
                let today = Date()

                // 시간 정보를 제거한 오늘 날짜
                let components = calendar.dateComponents([.year, .month, .day], from: today)
                guard let todayWithoutTime = calendar.date(from: components) else {
                    return false
                }

                // 시간 정보를 제거한 아이템의 유통기한 날짜
                let itemComponents = calendar.dateComponents([.year, .month, .day], from: item.expirationDate)
                guard let itemDateWithoutTime = calendar.date(from: itemComponents) else {
                    return false
                }

                switch self.selectedDate {
                case "오늘":
                    return calendar.isDate(itemDateWithoutTime, inSameDayAs: todayWithoutTime)
                case "과거":
                    return itemDateWithoutTime < todayWithoutTime
                case "미래":
                    return itemDateWithoutTime > todayWithoutTime
                case "전체":
                    return true
                default:
                    return false
                }
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

