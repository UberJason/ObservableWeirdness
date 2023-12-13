# Observable Weirdness

In an @Observable object like a ViewModel, if you so much as *reference* your own data in the initializer, and that data is used in a SwiftUI View, then mutating that data causes the entire view's identity to be changed and the ViewModel is re-initialized. 

*But only once!*

```
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

@Observable
class ViewModel {
    var amount = 75.0
    
    init() {
        print("ViewModel.init")
        
        randomFunction(amount: amount)
    }
    
    // Just a random function that doesn't even do anything.
    func randomFunction(amount: Double? = nil) {}
    
    func mutate() {
        amount = Double.random(in: 0...100)
    }
}
```

In the above code, the first time "Mutate" is tapped, the console logs:


```
ContentView: @dependencies changed.
ViewModel.init
ChildView: @dependencies, @self changed.
```

This indicates the ContentView's identity was changed (despite it having no dependencies at all) and a fresh copy of ViewModel was initialized. In a real-life scenario, this causes ViewModel's state to be thrown away (ask me how I know). But again, this only happens on the *first* tap of Mutate. Subsequent taps only print `ChildView: @dependencies changed.` as you would expect.