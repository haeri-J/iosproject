//
//  ContentView.swift
//  iosN_2171438_johaeri
//
//  Created by mac029 on 2024/06/04.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            MyListView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("냉장고")
                }
            
            RecipeRecommendationView() // 레시피 추천 뷰를 추가합니다.
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("레시피 추천")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
