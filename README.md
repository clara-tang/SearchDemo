# SearchDemo
* A sample project uses `GitHub` public API (`https://api.github.com/search/users`) to perform searching of GitHub users

### Tech Stack
* **Coding language**: Swift
* **UI framework**: SwiftUI
* **Async data handling**:
    1. `async/await`: flatten data fetching
    2. `Combine`: uses `@Published` properties in viewModel, to achieve automatic data binding and UI updates in SwiftUI

### Architecture:
* **MVVM**: hosts `SearchViewModel` in `View`. Uses `@Publishe viewState` in viewModel as the centralized source of truth to updates UI status accordingly
* **Data fetching**: creates a utility class `Service` to handle data fetching & decoding
* **Error handling**: creates our own enum `RequestError` to represents our own custom error handling. This helps us to triage different types of errors
* **Dependencies**: injects dependencies in the form of abstract protocols (ex: `ServiceType` in the viewModel) instead of concrete classes. This helps decouple the responsibilities of each class and allows for proper testing of each class


### Difficulties & Potential Improvements in Future Iterations
* In the current approach, we are using SwiftUI native built-in `.searchable(text:...)` and `.onChange(of: viewModel.searchText, ...)`. However, due to the constraints of these two methods, it would be challenging to implement throttle on the search events
* We are currently using two asynchronous data handling frameworks. Since they serve different benefits (`async/await` to achieve flattening data fetching; `Combine` to achieve automatic view updates). We may want to consider unifying this in the future.
* Testing: since we are using two asynchronous data handling frameworks (`async/await` and `Combine`), to test all the updates on `@Publishe viewState`, we need to insert a completion handler `completion: @escaping () -> Void` to `fetchUsers(...)` simply for the testing purpose
* We may also want to consider creating a utility class to host all `URL`s as the App scales
