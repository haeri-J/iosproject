//
//  ContentView.swift
//  iosN_2171438_johaeri
//
//  Created by mac029 on 2024/06/04.
//

import SwiftUI
import Combine

struct FoodItem: Identifiable {
    let id = UUID()
    var name: String
    var expirationDate: Date
    var memo: String
    var image: UIImage?
}

class FoodItems: ObservableObject {
    @Published var items: [FoodItem] = []
}

struct ContentView: View {
    @StateObject private var foodItems = FoodItems()
    
//    init() {
//           FirebaseApp.configure()
//       }
    
    var body: some View {
        TabView {
            MyListView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("냉장고")
                }
                .environmentObject(foodItems)
       
            RecipeRecommendationView() // 레시피 추천 뷰를 추가합니다.
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("레시피 추천")
                }
                .environmentObject(foodItems)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
