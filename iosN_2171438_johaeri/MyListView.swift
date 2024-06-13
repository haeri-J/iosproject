import SwiftUI

// MyListView는 사용자의 냉장고 속 음식들을 관리하는 뷰
struct MyListView: View {
    let imageSize = CGSize(width: 100, height: 100)

    // EnvironmentObject로 FoodItems를 사용. 이는 앱 전체에서 공유되는 데이터.
    @EnvironmentObject var foodItems: FoodItems

    // 새로운 음식 항목을 추가하는 뷰를 표시할지 여부를 나타내는 상태 변수
    @State private var showingAddFoodItemView = false
    // 새로운 음식 항목을 저장하는 상태 변수
    @State private var newFoodItem = FoodItem(name: "", expirationDate: Date(), memo: "", image: nil)
    // 캘린더 뷰를 표시할지 여부를 나타내는 상태 변수
    @State private var showingCalendarView = false

    var body: some View {

        List {
            // foodItems 배열을 순회하며 각 항목을 표시
            ForEach($foodItems.items) { $item in
                // 각 항목을 클릭하면 EditFoodItemView로 이동
                NavigationLink(destination: EditFoodItemView(foodItem: $item)) {
                    HStack {
                        // 이미지가 있으면 표시하고, 없으면 기본 이미지를 표시
                        Image(uiImage: (item.image ?? UIImage(named: "img")!))
                            .resizable()
                            .frame(width: imageSize.width, height: imageSize.height)
                        VStack(alignment: .leading) {
                            Text(item.name) // 음식 이름
                            Text(formattedDate(item.expirationDate)) // 유통 기한 날짜
                            Text(item.memo) // 메모
                        }
                    }
                }
            }
            .onDelete(perform: delete) // 삭제
        }
        .navigationTitle("냉장고 속 음식들")
        .navigationBarItems(
            leading: HStack {
                EditButton() // 편집 모드로 전환하는 버튼
                Button(action: {
                    showingCalendarView.toggle() // 캘린더 뷰를 토글
                }) {
                    Image(systemName: "calendar") // 캘린더 아이콘
                }
                .sheet(isPresented: $showingCalendarView) {
                    CalendarView(foodItems: $foodItems.items) // 캘린더 뷰를 표시
                }
            },
            trailing: Button(action: {
                self.showingAddFoodItemView = true // 새로운 음식 항목 추가 뷰를 표시
            }) {
                Image(systemName: "plus") // 플러스 아이콘
            }
        )
        .sheet(isPresented: $showingAddFoodItemView) {
            // EditFoodItemView를 시트로 표시
            EditFoodItemView(foodItem: $newFoodItem)
                .onDisappear {
                    // 시트가 사라질 때 새로운 음식 항목을 배열에 추가
                    if !self.newFoodItem.name.isEmpty {
                        self.foodItems.items.append(self.newFoodItem)
                        // 새로운 음식 항목을 초기화
                        self.newFoodItem = FoodItem(name: "", expirationDate: Date(), memo: "", image: nil)
                    }
                }
        }
    }

    // 음식 항목을 삭제하는 함수
    func delete(at offsets: IndexSet) {
        foodItems.items.remove(atOffsets: offsets)
    }

    // 날짜를 포맷팅하는 함수
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy/MM/dd"
        return formatter.string(from: date)
    }
}
