//
//  ProspectVIew.swift
//  HotProspects
//
//  Created by Alpay Calalli on 05.10.22.
//

import CodeScanner
import SwiftUI
import UserNotifications

struct ProspectsView: View {
    enum FilterType{
        case none, contacted, uncontacted
    }
    
    @EnvironmentObject var prospects: Prospects
    @State private var isShowingScanner = false
    @State private var showSortOptions = false
    
    let filter: FilterType
    
    var body: some View {
        NavigationView{
            List{
                ForEach(filteredProspects){ prospect in
                    HStack{
                        VStack(alignment: .leading){
                            Text(prospect.name)
                                .font(.headline)
                            
                            Text(prospect.emailAdress)
                                .foregroundColor(.secondary )
                        }
                        
                        Spacer()
                        
                        Label("", systemImage: prospect.isContacted ? "person.fill.checkmark" : "person.fill.xmark")
                    }
                    .swipeActions{
                        if prospect.isContacted{
                            Button{
                                prospects.toggle(prospect)
                            }label: {
                                Label("Mark Uncontacted", systemImage: "person.crop.circle.badge.xmark")
                            }
                            .tint(.blue)
                        }else{
                            Button{
                                prospects.toggle(prospect)
                            }label: {
                                Label("Mark Contacted", systemImage: "person.crop.circle.fill.badge.checkmark")
                            }
                            .tint(.green)
                            
                            Button{
                                addNotification(for: prospect)
                            }label: {
                                Label("Remind me", systemImage: "bell")
                            }
                            .tint(.orange)
                        }
                    }
                }
            }
            .navigationTitle(title)
            .toolbar{
                Button{
                    isShowingScanner = true
                }label: {
                    Label("Scan", systemImage: "qrcode.viewfinder")
                }
             }
            .toolbar{
                Button{
                    showSortOptions = true
                }label: {
                    Label("Sort", systemImage: "ellipsis")
                }
            }
            .sheet(isPresented: $isShowingScanner){
                CodeScannerView(codeTypes: [.qr], simulatedData: "Alpaycli\nalpay@gmail.com", completion: handleScan)
            }
            .confirmationDialog("Sort names", isPresented: $showSortOptions){
                
            }
        }
    }
    
    
    
    func addNotification(for prospect: Prospect){
        let center = UNUserNotificationCenter.current()
        
        let addRequest = {
            let content = UNMutableNotificationContent()
            content.title = "Contact \(prospect.name)"
            content.subtitle = prospect.emailAdress
            content.sound = UNNotificationSound.default
            
            var dateComponents = DateComponents()
            dateComponents.hour = 9
//            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            
            center.add(request)
        }
        
        center.getNotificationSettings{ settings in
            if settings.authorizationStatus == .authorized{
                addRequest()
            }else{
                center.requestAuthorization(options: [.sound, .badge, .alert]){ success, error in
                    if success{
                        addRequest()
                    }else{
                        print("Some kind of error")
                    }
                }
            }
        }
        
    }
    
    func handleScan(result: Result<ScanResult, ScanError>){
        isShowingScanner = false
        
        switch result {
        case .success(let result):
            let details = result.string.components(separatedBy: "\n")
            guard details.count == 2 else { return }
            
            let person = Prospect()
            person.name = details[0]
            person.emailAdress = details[1]
            prospects.add(person)
        case .failure(let error):
            print("Some error occured: \(error.localizedDescription)")
        }
    }
    
    var title: String{
        switch filter{
        case .none:
            return "Everyone😶‍🌫️"
        case .contacted:
            return "Contacted People🫂"
        case .uncontacted:
            return "Uncontacted People🥶"
        }
    }
    
    var filteredProspects: [Prospect]{
        switch filter {
        case .none:
            return prospects.people
        case .contacted:
            return prospects.people.filter{ $0.isContacted }
        case .uncontacted:
            return prospects.people.filter{ !$0.isContacted }
        }
    }
}

struct ProspectVIew_Previews: PreviewProvider {
    static var previews: some View {
        ProspectsView(filter: .none)
            .environmentObject(Prospects())
    }
}
