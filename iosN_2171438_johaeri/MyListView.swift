import SwiftUI

struct FoodItem: Identifiable {
    let id = UUID()
    var name: String
    var expirationDate: Date
    var memo: String
    var image: UIImage?
}

struct MyListView: View {
    let imageSize = CGSize(width: 100, height: 100)
    
    @State private var foodItems: [FoodItem] = []
    @State private var showingAddFoodItemView = false
    @State private var newFoodItem = FoodItem(name: "", expirationDate: Date(), memo: "", image: nil)
    @State private var showingCalendarView = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach($foodItems) { $item in
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
                        CalendarView(foodItems: $foodItems)
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
                            self.foodItems.append(self.newFoodItem)
                            self.newFoodItem = FoodItem(name: "", expirationDate: Date(), memo: "", image: nil)
                        }
                    }
            }
            .onAppear {
                self.foodItems.sort { $0.expirationDate < $1.expirationDate }
            }
        }
    }

    func delete(at offsets: IndexSet) {
        foodItems.remove(atOffsets: offsets)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy/MM/dd"
        return formatter.string(from: date)
    }
}

struct CalendarView: View {
    @Binding var foodItems: [FoodItem]
    let calendar = Calendar.current
    
    var body: some View {
        VStack {
            Text("만료 날짜별 음식들")
                .font(.title)
                .padding()
            
            CalendarGrid(foodItems: $foodItems)
        }
    }
}

struct CalendarGrid: View {
    @Binding var foodItems: [FoodItem]
    let calendar = Calendar.current
    let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    @State private var currentMonth: Date = Date()

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? Date()
                }) {
                    Image(systemName: "chevron.left")
                }
                
                Spacer()
                
                Text(monthFormatter.string(from: currentMonth))
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? Date()
                }) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding()
            
            let days = generateDaysInMonth(for: currentMonth)
            let rows = days.chunked(into: 7)
            
            ForEach(rows, id: \.self) { row in
                HStack {
                    ForEach(row, id: \.self) { date in
                        VStack {
                            Text("\(calendar.component(.day, from: date))")
                                .frame(maxWidth: .infinity)

                            if let items = itemsForDate(date) {
                                ForEach(items, id: \.id) { item in
                                    Text(item.name)
                                        .font(.caption)
                                }
                            }
                        }
                        .padding(4)
                        .background(date.isInCurrentMonth(currentMonth) ? Color.white : Color.gray.opacity(0.3))
                        .cornerRadius(4)
                    }
                }
            }
        }
    }

    private func generateDaysInMonth(for date: Date) -> [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: date),
              let firstWeekInterval = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) else {
            return []
        }
        
        var dates = [Date]()
        var current = firstWeekInterval.start
        
        while current < monthInterval.end {
            dates.append(current)
            current = calendar.date(byAdding: .day, value: 1, to: current) ?? Date()
        }
        
        return dates
    }
    
    private func itemsForDate(_ date: Date) -> [FoodItem]? {
        let items = foodItems.filter {
            calendar.isDate($0.expirationDate, inSameDayAs: date)
        }
        
        return items.isEmpty ? nil : items
    }
}

struct MyListView_Previews: PreviewProvider {
    static var previews: some View {
        MyListView()
    }
}

extension Date {
    func isInCurrentMonth(_ date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(self, equalTo: date, toGranularity: .month)
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        var chunks: [[Element]] = []
        for index in stride(from: 0, to: count, by: size) {
            let chunk = Array(self[index..<Swift.min(index + size, count)])
            chunks.append(chunk)
        }
        return chunks
    }
}
