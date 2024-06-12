//
//  CalenreView.swift
//  iosN_2171438_johaeri
//
//  Created by mac029 on 2024/06/12.
//

import SwiftUI

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
