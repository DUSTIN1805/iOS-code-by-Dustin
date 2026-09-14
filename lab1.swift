//
//  ContentView.swift
//  Hello world
//
//  Created by DattPhann on 14/9/26.
//


import SwiftUI

struct ContentView: View {
    var body: some View {
        var gpa  = 4
        var age = 20
        var student = true
        
        
        VStack {
            let Name = "DATTPHANN"
            let StudentID = "SESEIU24006"
            ZStack {
                VStack {
                    Image("Screenshot 2026-09-13 at 14.44.58")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40,height :40)
                    Text("Student Profile").font(.largeTitle).bold().foregroundStyle(.red)
                    Text("Name:\(Name)").foregroundStyle(.red)
                    Text("StudentID:\(StudentID)").foregroundStyle(.red)
                    Text("Age: \(age)").foregroundStyle(.red)
                    Text("GPA: \(gpa)").foregroundStyle(.red)
                    Text("Is Student:\(student)")
                        .foregroundStyle(.red)
                }
            }
            .padding()
        }
    }
    
    
}
