//
//  LocationDetailView_ViewModel.swift
//  HongdaeDate
//
//  Created by 최준영 on 2023/03/06.
//

import Foundation

@MainActor
class UserEnvironment: ObservableObject {
    @Published private(set) var userData: UserData

    let userDataFileName = "userData.json"
    
    init() {
        userData = UserData(isFirstAccess: true)
        if let data: UserData = loadData(file: userDataFileName) {
            userData = data
        }
    }
    
    
    private func loadData<T>(file: String) -> T? where T: Decodable {
        let url = getDocumentDirectory().appendingPathComponent(file)
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(T.self, from: data)
            return decoded
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func changeAccessState(_ state: Bool) {
        userData.isFirstAccess = false
        saveData(file: userDataFileName, data: userData)
    }
    
    private func saveData<T>(file: String, data: T) where T: Encodable {
        let url = getDocumentDirectory().appendingPathComponent(file)
        do {
            let encoded = try JSONEncoder().encode(data)
            try encoded.write(to: url, options: [.atomic])
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    private func getDocumentDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}


struct UserData: Codable {
    var isFirstAccess: Bool
}
