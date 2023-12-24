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


extension Image{
    func ImageModifier() -> some View{
        self.resizable().scaledToFit()
    }
}

struct ContentView: View {
    @State private var posts: [Post] = []
    @State private var isLoading = false
    @State private var isError = false
  private let imageURL = "https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/564ce718-2b81-46ca-800d-fe48cc091e46/df9jywd-5c22ac40-b70c-46d0-a739-719f72c4ae64.jpg/v1/fill/w_1280,h_720,q_75,strp/satoru_gojo_jujutsu_kaisen_4k_pc_wallpaper_by_volt783_df9jywd-fullview.jpg?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsIm9iaiI6W1t7ImhlaWdodCI6Ijw9NzIwIiwicGF0aCI6IlwvZlwvNTY0Y2U3MTgtMmI4MS00NmNhLTgwMGQtZmU0OGNjMDkxZTQ2XC9kZjlqeXdkLTVjMjJhYzQwLWI3MGMtNDZkMC1hNzM5LTcxOWY3MmM0YWU2NC5qcGciLCJ3aWR0aCI6Ijw9MTI4MCJ9XV0sImF1ZCI6WyJ1cm46c2VydmljZTppbWFnZS5vcGVyYXRpb25zIl19.Nhd3-2XkRngJCHJbdeQIbCLJ1SgLfBJHTXFLhvSpMcQ"
    
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
                AsyncImage(url: URL(string:imageURL), content: {image in
                    image.ImageModifier()
                }, placeholder: {
                    Image(systemName: "photo").ImageModifier()
                } ).edgesIgnoringSafeArea(.all)
                
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

    }
    
}
