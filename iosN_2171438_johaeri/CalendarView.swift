import SwiftUI

struct CalendarView: View {
    // foodItems 배열을 바인딩 변수로 선언
    @Binding var foodItems: [FoodItem]
    // 현재 캘린더를 calendar 상수로 선언
    let calendar = Calendar.current
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack {
//                    Text("만료 날짜별 음식들")
//                        .font(.title)
//                        .padding()
                    
                    CalendarGrid(foodItems: $foodItems, width: geometry.size.width)
                }
            }
        }
    }
}

struct CalendarGrid: View {
    // foodItems 배열을 바인딩 변수로 선언
    @Binding var foodItems: [FoodItem]
    // 현재 캘린더를 calendar 상수로 선언
    let calendar = Calendar.current
    // monthFormatter를 설정, 월과 연도를 표시하기 위한 포맷터
    let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MMMM"
        return formatter
    }()
    
    // 요일 포맷터를 설정, 요일을 표시하기 위한 포맷터
    let dayOfWeekFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EE" // 요일을 축약하여 표시 (예: Mon, Tue, ...)
        return formatter
    }()
    
    // 현재 월을 상태 변수로 선언
    @State private var currentMonth: Date = Date()
    // 뷰의 너비를 width 변수로 선언
    var width: CGFloat

    var body: some View {
        VStack {
            HStack {
                // 이전 달로 이동하는 버튼
                Button(action: {
                    // currentMonth를 이전 달로 변경
                    currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? Date()
                }) {
                    Image(systemName: "chevron.left")
                }
                
                Spacer()
                
                // 현재 월과 연도를 표시하는 텍스트
                Text(monthFormatter.string(from: currentMonth))
                    .font(.headline)
                
                Spacer()
                
                // 다음 달로 이동하는 버튼
                Button(action: {
                    // currentMonth를 다음 달로 변경
                    currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? Date()
                }) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding()
            
            // 요일을 표시하는 HStack 추가
            HStack {
                ForEach(calendar.shortWeekdaySymbols, id: \.self) { day in
                    Text(day)
                        .frame(maxWidth: .infinity)
                        .font(.subheadline)
                }
            }
            .padding(.bottom, 5)
            
            // 현재 월의 날짜들을 생성하고 7일씩 나누어 rows로 선언
            let days = generateDaysInMonth(for: currentMonth)
            let rows = days.chunked(into: 7)
            
            // 각 행을 ForEach로 반복
            ForEach(rows, id: \.self) { row in
                HStack {
                    // 각 날짜를 ForEach로 반복
                    ForEach(row, id: \.self) { date in
                        VStack {
                            // 날짜를 표시하는 텍스트
                            Text("\(calendar.component(.day, from: date))")
                                .frame(maxWidth: .infinity)
                                .foregroundColor(date.isInCurrentMonth(currentMonth) ? .black : .gray)
                            
                            // 해당 날짜에 있는 음식 아이템들을 표시
                            if let items = itemsForDate(date) {
                                ForEach(items, id: \.id) { item in
                                    Text(item.name)
                                        .font(.caption)
                                }
                            }
                        }
                        .padding(5)
                    }
                }
            }
        }
    }

    // 주어진 날짜의 월에 해당하는 모든 날짜를 생성하는 함수
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
    
    // 주어진 날짜에 해당하는 음식 아이템들을 반환하는 함수
    private func itemsForDate(_ date: Date) -> [FoodItem]? {
        let items = foodItems.filter {
            calendar.isDate($0.expirationDate, inSameDayAs: date)
        }
        
        return items.isEmpty ? nil : items
    }
}

// 미리보기 구조체 선언
struct MyListView_Previews: PreviewProvider {
    static var previews: some View {
        MyListView()
    }
}

// Date 확장, 주어진 날짜가 현재 월에 속하는지 확인하는 함수
extension Date {
    func isInCurrentMonth(_ date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(self, equalTo: date, toGranularity: .month)
    }
}

// Array 확장, 배열을 지정된 크기로 나누는 함수
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
