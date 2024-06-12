import Foundation

// API 응답을 위한 모델
struct RecipeResponse: Decodable {
    let recipes: [Recipe]
    
    enum CodingKeys: String, CodingKey {
        case recipes = "row"
    }
}

struct RecipeContainer: Decodable {
    let COOKRCP01: RecipeResponse
}

struct Recipe: Identifiable, Decodable {
    var id: UUID = UUID()
    let RCP_SEQ: String //일련번호
    let RCP_NM: String  //메뉴명
    let RCP_PAT2:String // 요리 종류
    let RCP_PARTS_DTLS: String //재료 정보
    let INFO_ENG: String? // 열량
    let INFO_CAR: String? // 탄수화물
    let INFO_PRO: String? // 단백질
    let INFO_FAT: String? // 지방
    let INFO_NA: String? // 나트륨
    let ATT_FILE_NO_MAIN: String? // 이미지경로(소)

    // 만드는 법과 그 이미지들
    var MANUALS: [String] = []
    var MANUAL_IMGS: [String] = []

    // Decodable 프로토콜을 준수하기 위한 CodingKeys
    enum CodingKeys: String, CodingKey {
        case RCP_SEQ, RCP_NM, RCP_PARTS_DTLS, INFO_ENG, INFO_CAR, INFO_PRO, INFO_FAT, INFO_NA, ATT_FILE_NO_MAIN, RCP_PAT2
        case MANUAL01, MANUAL02, MANUAL03, MANUAL04, MANUAL05, MANUAL06, MANUAL07, MANUAL08, MANUAL09, MANUAL10, MANUAL11, MANUAL12, MANUAL13, MANUAL14, MANUAL15, MANUAL16, MANUAL17, MANUAL18, MANUAL19, MANUAL20
        case MANUAL_IMG01, MANUAL_IMG02, MANUAL_IMG03, MANUAL_IMG04, MANUAL_IMG05, MANUAL_IMG06, MANUAL_IMG07, MANUAL_IMG08, MANUAL_IMG09, MANUAL_IMG10, MANUAL_IMG11, MANUAL_IMG12, MANUAL_IMG13, MANUAL_IMG14, MANUAL_IMG15, MANUAL_IMG16, MANUAL_IMG17, MANUAL_IMG18, MANUAL_IMG19, MANUAL_IMG20
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        RCP_SEQ = try container.decode(String.self, forKey: .RCP_SEQ)
        RCP_NM = try container.decode(String.self, forKey: .RCP_NM)
        RCP_PAT2 = try container.decode(String.self, forKey: .RCP_PAT2)
        RCP_PARTS_DTLS = try container.decode(String.self, forKey: .RCP_PARTS_DTLS)
        INFO_ENG = try? container.decode(String.self, forKey: .INFO_ENG)
        INFO_CAR = try? container.decode(String.self, forKey: .INFO_CAR)
        INFO_PRO = try? container.decode(String.self, forKey: .INFO_PRO)
        INFO_FAT = try? container.decode(String.self, forKey: .INFO_FAT)
        INFO_NA = try? container.decode(String.self, forKey: .INFO_NA)
        ATT_FILE_NO_MAIN = try? container.decode(String.self, forKey: .ATT_FILE_NO_MAIN)
        
        for i in 1...20 {
            let manualKey = CodingKeys(rawValue: String(format: "MANUAL%02d", i))!
            let manualImgKey = CodingKeys(rawValue: String(format: "MANUAL_IMG%02d", i))!
            
            if let manual = try? container.decode(String.self, forKey: manualKey), !manual.isEmpty {
                MANUALS.append(manual)
            }
            if let manualImg = try? container.decode(String.self, forKey: manualImgKey), !manualImg.isEmpty {
                MANUAL_IMGS.append(manualImg)
            }
        }

    }
}

// URL 생성을 위한 Helper 함수
func createRecipeURL(start: Int, end: Int) -> URL? {
    let base = "http://openapi.foodsafetykorea.go.kr/api/1dba55b5f8df42a29903/COOKRCP01/json/\(start)/\(end)/"
    return URL(string: base)
}

// API 호출 및 데이터 처리
func fetchRecipes(matching ingredients: [String], completion: @escaping ([Recipe]) -> Void) {
    var allRecipes: [Recipe] = []
    let batchSize = 1000
    var start = 1
    var end = batchSize
    
    func fetchBatch() {
        guard let url = createRecipeURL(start: start, end: end) else {
            print("Invalid URL")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data, error == nil else {
                print("Error fetching data")
                return
            }

            do {
                let container = try JSONDecoder().decode(RecipeContainer.self, from: data)
                let recipes = container.COOKRCP01.recipes
                allRecipes.append(contentsOf: recipes)

                if recipes.count == batchSize {
                    // 아직 더 많은 데이터가 남아있음. 다음 배치를 가져옴.
                    start += batchSize
                    end += batchSize
                    fetchBatch()
                } else {
                    // 모든 데이터를 다 가져왔음.
                    DispatchQueue.main.async {
                        print("Total recipes fetched: \(allRecipes)")
                        completion(allRecipes)
                    }

                }
            } catch {
                print("Error decoding data: \(error)")
            }
        }

        task.resume()
    }
    
    fetchBatch()
}

//메뉴추천로직
func compareIngredients(_ recipeIngredients: String, recipeName: String, userIngredients: [String]) -> Bool {
    let recipeIngredientsArray = recipeIngredients.split(separator: ",").map(String.init).map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    
    // 사용자의 재료가 레시피 재료명에 포함되어 있는지 검사
    let matches = userIngredients.filter { userIngredient in
        recipeIngredientsArray.contains { recipeIngredient in
            recipeIngredient.lowercased().contains(userIngredient.lowercased())
        }
    }
    
    // 레시피 이름에 사용자의 재료가 포함되어 있는지 검사
    let nameMatches = userIngredients.filter { userIngredient in
        recipeName.lowercased().contains(userIngredient.lowercased())
    }
    
    // 사용자의 재료가 3개 이상 레시피의 재료명에 포함되어 있거나, 레시피 이름에 사용자의 재료가 포함되어 있는 경우
    return matches.count >= 5 || !nameMatches.isEmpty
}


