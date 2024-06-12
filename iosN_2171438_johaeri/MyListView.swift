import SwiftUI

struct MyListView: View {
    let imageSize = CGSize(width: 100, height: 100)
    
    @EnvironmentObject var foodItems: FoodItems
    
    @State private var showingAddFoodItemView = false
    @State private var newFoodItem = FoodItem(name: "", expirationDate: Date(), memo: "", image: nil)
    @State private var showingCalendarView = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach($foodItems.items) { $item in
                    NavigationLink(destination: EditFoodItemView(foodItem: $item)) {
                        HStack {
                            Image(uiImage: (item.image ?? UIImage(named: "img")!))
                                .resizable()
                                .frame(width: imageSize.width, height: imageSize.height)
                            VStack(alignment: .leading) {
                                Text(item.name)
                                Text(formattedDate(item.expirationDate))
                                Text(item.memo)
                            }
                        }
                    }
                }
                .onDelete(perform: delete)
            }
            .navigationTitle("냉장고 속 음식들")
            .navigationBarItems(
                leading: HStack {
                    EditButton()
                    Button(action: {
                        showingCalendarView.toggle()
                    }) {
                        Image(systemName: "calendar")
                    }
                    .sheet(isPresented: $showingCalendarView) {
                        CalendarView(foodItems: $foodItems.items)
                    }
                },
                trailing: Button(action: {
                    self.showingAddFoodItemView = true
                }) {
                    Image(systemName: "plus")
                }
            )
            .sheet(isPresented: $showingAddFoodItemView) {
                EditFoodItemView(foodItem: $newFoodItem)
                    .onDisappear {
                        if !self.newFoodItem.name.isEmpty {
                            self.foodItems.items.append(self.newFoodItem)
                            self.newFoodItem = FoodItem(name: "", expirationDate: Date(), memo: "", image: nil)
                        }
                    }
            }
            .onAppear {
                self.foodItems.items.sort { $0.expirationDate < $1.expirationDate }
            }
        }
    }

    func delete(at offsets: IndexSet) {
        foodItems.items.remove(atOffsets: offsets)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy/MM/dd"
        return formatter.string(from: date)
    }
}
