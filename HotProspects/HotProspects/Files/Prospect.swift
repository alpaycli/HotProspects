//
//  Prospect.swift
//  HotProspects
//
//  Created by Alpay Calalli on 05.10.22.
//

import SwiftUI

class Prospect: Codable, Identifiable{
    var id = UUID()
    var name = "Anonymous"
    var emailAdress = ""
    fileprivate(set) var isContacted = false

}

@MainActor class Prospects: ObservableObject{
    @Published private(set) var people: [Prospect]
    let saveKey = "SavedData"
    
    let savePath = FileManager.documentsDirectory.appendingPathComponent("SavedPlaces")
    
    
    init(){
        
        do{
            let data = try Data(contentsOf: savePath)
            people = try JSONDecoder().decode([Prospect].self, from: data)
        }catch{
            people = []
        }
    
    }

    func add(_ prospect: Prospect){
        people.append(prospect)
        saveData()
    }
    
    func toggle(_ prospect: Prospect){
        objectWillChange.send()
        prospect.isContacted.toggle()
        saveData()
    }

    
    func saveData(){
        do{
            let data = try JSONEncoder().encode(people)
            try data.write(to: savePath, options: [.atomicWrite, .completeFileProtection])
        }catch{
            print("Unable to save data")
        }
    }
}
