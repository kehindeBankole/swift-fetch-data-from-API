//
//  ContentView.swift
//  fetch
//
//  Created by kehinde on 21/12/2023.
//

import SwiftUI
struct Post: Codable, Identifiable {
    let id: Int
    let title: String
    let body: String
}

enum MyError: Error {
case badParsing
case badRequest
}

struct ContentView: View {
    @State private var posts: [Post] = []
    @State private var isLoading = false
    @State private var isError = false

    private func fetchData() async throws -> Any {
        // Parse URL
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else {
            throw MyError.badParsing
        
        }
        
        let request = URLRequest(url: url)
        do {
            isLoading = true
            let (data, _) = try await URLSession.shared.data(for: request)
            // Parse JSON
            let decodedData = try JSONDecoder().decode([Post].self, from: data)
            posts = decodedData
            
            isLoading = false
            
            return decodedData
        } catch {
            // Print errors
          isError = true
            isLoading = false
            throw MyError.badRequest
        }
    }
    
    var body: some View {
        VStack {
            if(isLoading){
              
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
                
            }else if(isError){
                Text("Error getting data")
            } else{
                List(posts){post in
                    Text(post.title).padding(.vertical,20).swipeActions(content: {
                        Button(role: .destructive, action: {
                            print(post)
                        }, label: {
                            
                            Image(systemName: "trash.circle")
                        })
                    })
                }.listStyle(.plain).listRowInsets(EdgeInsets()).scrollIndicators(.hidden)
            }
        }.task(priority: .background) {
            
            _ = try? await fetchData()
            
        }
        .padding()
    }
    
}
