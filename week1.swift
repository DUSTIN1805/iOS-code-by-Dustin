//
//  ContentView.swift
//  Hello world
//
//  Created by DattPhann on 14/9/26.
//


import SwiftUI

struct ContentView: View {
    let name = "Datt Phann"
    let studentID = "SESEIU24006"
    let message = "My iOS journey starts today!"
   
    var body: some View {
            VStack( spacing: 16 ){
                Image("Screenshot 2026-09-13 at 14.44.58")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40,height :40)
                
                Text("Hello,SWift!👋")
                    .font(.largeTitle)
                    .bold()
                
                Text("My name is \(name)")
                    .font(.title2)
                Text("student ID: \(studentID)")
                    .font(.title3)
                Text("\(message)")
                    .font(.title3)
                
            }
            .padding()
        }
        
    }
#Preview {
    ContentView()
}
