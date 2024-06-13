import SwiftUI

// CalendarView는 캘린더를 표시하는 메인 뷰
struct CalendarView: View {
    @Binding var foodItems: [FoodItem] // 바인딩된 foodItems 배열
    let calendar = Calendar.current // 현재 달력 인스턴스
    
    var body: some View {
            ScrollView {
                VStack {
                    CalendarGrid(foodItems: $foodItems, width: .infinity) // CalendarGrid 뷰 생성
                }
            }
    }
}

// CalendarGrid는 캘린더의 그리드 레이아웃을 담당하는 뷰입니다.
struct CalendarGrid: View {
    @Binding var foodItems: [FoodItem] // 바인딩된 foodItems 배열
    let calendar = Calendar.current // 현재 달력 인스턴스
    let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MMMM" // 월 표시 형식 설정
        return formatter
    }()
    
    let dayOfWeekFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EE" // 요일 표시 형식 설정
        return formatter
    }()
    
    @State private var currentMonth: Date = Date() // 현재 월을 상태로 저장
    var width: CGFloat

    var body: some View {
        VStack {
            HStack {
                // 이전 달로 이동하는 버튼
                Button(action: {
                    currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? Date()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color(.lightGray))
                }
                
                Spacer()//여백 지정
                
                // 현재 월을 표시하는 텍스트
                Text(monthFormatter.string(from: currentMonth))
                    .font(.headline)
                
                Spacer()
                
                // 다음 달로 이동하는 버튼
                Button(action: {
                    currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? Date()
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color(.lightGray))
                }
            }
            .padding()
            
            HStack {
                // 요일 표시
                ForEach(calendar.shortWeekdaySymbols, id: \.self) { day in
                    Text(day)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(height: 30)
            }
            .padding(.bottom, 5)
           
            // 현재 월의 날짜들을 생성하고 7일씩 묶음
            let days = generateDaysInMonth(for: currentMonth)
            let rows = days.chunked(into: 7)
            
            // 각 주를 HStack으로 표시
            ForEach(rows, id: \.self) { row in
                HStack {
                    // 각 날짜를 VStack으로 표시
                    ForEach(row, id: \.self) { date in
                        VStack {
                            if calendar.isDate(date, equalTo: currentMonth, toGranularity: .month) {
                                Text("\(calendar.component(.day, from: date))")
                                    .frame(maxWidth: .infinity)
                                    .foregroundColor(date.isInCurrentMonth(currentMonth) ? .black : .gray)
                                
                                // 해당 날짜에 foodItems가 있으면 표시
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

    // 주어진 날짜의 월에 해당하는 날짜 목록을 생성
    private func generateDaysInMonth(for date: Date) -> [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: date),
              let firstWeekInterval = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) else {
            return []
        }
        
        var dates = [Date]()
        var current = firstWeekInterval.start
        
        // 월의 마지막 날짜까지 날짜 추가
        while current < monthInterval.end {
            dates.append(current)
            current = calendar.date(byAdding: .day, value: 1, to: current) ?? Date()
        }
        
        // 마지막 줄의 남은 셀을 채우기 위해 빈 날짜 추가
        let additionalDays = 7 - (dates.count % 7)
        if (dates.count % 7) != 0 {
            for _ in 0..<additionalDays {
                dates.append(Date.distantPast) // 과거의 임의 날짜로 채움
            }
        }
        
        return dates
    }
    
    // 주어진 날짜에 해당하는 foodItems를 반환
    private func itemsForDate(_ date: Date) -> [FoodItem]? {
        let items = foodItems.filter {
            calendar.isDate($0.expirationDate, inSameDayAs: date)
        }
        
        return items.isEmpty ? nil : items
    }
}

// Date 확장: 주어진 날짜가 현재 월에 속하는지 확인
extension Date {
    func isInCurrentMonth(_ date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(self, equalTo: date, toGranularity: .month)
    }
}

// Array 확장: 배열을 주어진 크기로 나누기
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
