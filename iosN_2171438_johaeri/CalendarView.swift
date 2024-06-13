import SwiftUI

struct CalendarView: View {
    @Binding var foodItems: [FoodItem]
    let calendar = Calendar.current
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack {
                    CalendarGrid(foodItems: $foodItems, width: geometry.size.width)
                }
            }
        }
    }
}

struct CalendarGrid: View {
    @Binding var foodItems: [FoodItem]
    let calendar = Calendar.current
    let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MMMM"
        return formatter
    }()
    
    let dayOfWeekFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EE"
        return formatter
    }()
    
    @State private var currentMonth: Date = Date()
    var width: CGFloat

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? Date()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color(.lightGray))
                }
                
                Spacer()
                
                Text(monthFormatter.string(from: currentMonth))
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? Date()
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color(.lightGray))
                }
            }
            .padding()
            
            HStack {
                ForEach(calendar.shortWeekdaySymbols, id: \.self) { day in
                    Text(day)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(height: 30)
            }
            .padding(.bottom, 5)
           
            
            let days = generateDaysInMonth(for: currentMonth)
            let rows = days.chunked(into: 7)
            
            ForEach(rows, id: \.self) { row in
                HStack {
                    ForEach(row, id: \.self) { date in
                        VStack {
                            if calendar.isDate(date, equalTo: currentMonth, toGranularity: .month) {
                                Text("\(calendar.component(.day, from: date))")
                                    .frame(maxWidth: .infinity)
                                    .foregroundColor(date.isInCurrentMonth(currentMonth) ? .black : .gray)
                                
                                if let items = itemsForDate(date) {
                                    ForEach(items, id: \.id) { item in
                                        Text(item.name)
                                            .font(.caption)
                                    }
                                }
                            } else {
                                Text("")
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(5)
                        .frame(height: 100)
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
        
        // 마지막 줄의 남은 셀을 채우기 위해 빈 날짜 추가
        let additionalDays = 7 - (dates.count % 7)
        if additionalDays < 7 {
            for _ in 0..<additionalDays {
                dates.append(Date.distantPast) // 과거의 임의 날짜로 채움
            }
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
