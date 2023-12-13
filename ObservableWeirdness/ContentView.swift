//
//  ContentView.swift
//  ObservableWeirdness
//
//  Created by Jason Ji on 12/12/23.
//

import SwiftUI

// Strangeness:
// On first tap of "Mutate", we see in the console that ContentView changes due to "@dependencies changed" (despite ContentView having no data dependencies at all)
// and ViewModel is re-initialized (which is bad, it throws away the state in ViewModel if this were a real-life scenario).
//
// On subsequent taps, that doesn't happen.
//
// And in the memory debugger, there persist two copies of ViewModel from here on.
// If `randomFunction(amount: amount)` is not called in the initializer, this doesn't occur.
// It seems like calling randomFunction in the ViewModel initializer and passing a reference to its own data is creating an Observable dependency somewhere,
// but only the first time.

// This has to be a bug, right? Or am I holding it wrong?


// MARK: - Views

struct ContentView: View {
    var body: some View {
        let _ = Self._printChanges()
        ChildView()
    }
}

@MainActor
struct ChildView: View {
    @State var viewModel = ViewModel()
    
    var body: some View {
        let _ = Self._printChanges()
        
        Button("Mutate") { [weak viewModel] in
            viewModel?.mutate()
        }
        
        Text("\(viewModel.amount)")
    }
}

// MARK: - Data

@Observable
class ViewModel {
    var amount = 75.0
    
    init() {
        print("ViewModel.init")
        
        // Removing this method call prevents ContentView's identity from changing and prevents ViewModel from being re-initialized.
        randomFunction(amount: amount)
    }
    
    // Just a random function that doesn't even do anything.
    func randomFunction(amount: Double? = nil) {}
    
    func mutate() {
        amount = Double.random(in: 0...100)
    }
}
