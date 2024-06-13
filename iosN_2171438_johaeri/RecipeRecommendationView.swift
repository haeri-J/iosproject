import SwiftUI

// RecipeRecommendationView는 사용자가 카테고리를 선택하고, 해당 카테고리에 맞는 레시피를 추천받을 수 있는 뷰
struct RecipeRecommendationView: View {
    
    // Contentview에서 의존성 주입하여 상태에 접근할 수 있도록 만든 변수
    @EnvironmentObject var foodItems: FoodItems
    

    @State private var recommendedRecipes: [Recipe] = [] //사용자의 냉장고 재료에 따른 추천 레시피가 저장되는 변수
    @State private var selectedRecipe: Recipe? //레시피 상세 페이지로 넘어가기 위해 선택된 레시피를 저장할 변수
    @State private var showDetail = false //선택된 레시피의 시트가 표시될지 여부를 정함.
    
    let categories = ["밥", "국&찌개", "반찬", "후식", "일품", "기타"] //fetchRecipeData에서 호출한 api 데이터에서 RCP_PAT2에 해당되는 값들.
    
    var body: some View {
        VStack {
            // Picker를 이용해 사용자의 선택 받는 ui 생성
            Picker("카테고리 선택", selection: $foodItems.selectedCategory) {
                // 각 카테고리에 대해 Picker 항목을 생성
                ForEach(categories, id: \.self) { category in
                    Text(category).tag(category) //.tag()를 사용하여 선택된 항목을 식별하고, 해당 항목이 선택되었을 때 어떤 값을 반환할지 지정
                }
            }
            .pickerStyle(SegmentedPickerStyle()) // Picker 스타일을 SegmentedPicker로 설정
            .padding()
            
            // 추천 레시피를 표시하는 리스트
            List(foodItems.recommendedRecipes) { recipe in
                Button(action: {
                    if !recommendedRecipes.isEmpty {
                        selectedRecipe = recipe
                        showDetail = true
                    }
                })  {
                    HStack {
                        // 레시피 이미지가 있을 경우 AsyncImage를 사용하여 이미지를 비동기적으로 로드
                        if let imageUrl = recipe.ATT_FILE_NO_MAIN, let url = URL(string: imageUrl) {
                            AsyncImage(url: url) { image in
                                image.resizable()
                                    .aspectRatio(contentMode: .fill) // 이미지를 뷰의 크기에 맞게 조정
                                    .frame(width: 50, height: 50)
                                    .clipped() // 이미지가 프레임을 넘어가지 않도록 자름
                            } placeholder: {
                                ProgressView() // 이미지를 로드하는 동안 ProgressView(로딩 스피너)를 표시
                            }
                        } else {
                            //이미지가 없을때 에셋에 있는 이미지 없음으로 표시
                            Image(uiImage: UIImage(named: "img")!)
                                .frame(width: 50, height: 50)
                        }
                        // 레시피 이름과 열량 정보를 표시
                        VStack(alignment: .leading) {
                            Text(recipe.RCP_NM)
                                .font(.headline)
                            Text("열량: \(recipe.INFO_ENG ?? "N/A")")
                                .font(.subheadline)
                        }
                    }
                }
            }.onAppear {
                // 맨 처음 밥 카테고리에 해당되는 추천 레시피를 업데이트
                foodItems.updateRecipes()
            }
            
            // showDetail가 트루이고 선택된 레시피가 있으면  .sheet로 레시피 상세 뷰를 띄우고 selectedRecipe을 넘겨줌.
            .sheet(isPresented: $showDetail) {
                if let selectedRecipe = selectedRecipe {
                    RecipeDetailView(recipe: selectedRecipe)//selectedRecipe를 참조할 수 있도록 값 자체를 전달
                }
            }
        }
    }
}
