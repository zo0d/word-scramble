//
//  ContentView.swift
//  Shared
//
//  Created by Behzad Jahanzad on 2022-09-10.
//

import SwiftUI

struct ContentView: View {
    
    @State private var score = 0
    
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Enter your word", text: $newWord).autocapitalization(.none)
                }
                HStack {
                    Spacer()
                    Text("Score: \(score)").bold()
                    Spacer()
                }
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                            
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .toolbar(content: {
                ToolbarItemGroup {
//                    Text("Score: \(score)").bold()
//                    Spacer()
                    Button("Restart") {
                        startGame()
                    }
                }
            })
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                score = 0
                usedWords.removeAll()
                return
            }
        }
        
        fatalError("Could not load start.txt from bundle.")
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 3 else {
            wordError(title: "Word too short", message: "Try again")
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used alread", message: "Be more original")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "Don't be stupid")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "Don't be dumb")
            return
        }
        
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        score += 1 + newWord.count
        newWord = ""
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let missspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return missspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
