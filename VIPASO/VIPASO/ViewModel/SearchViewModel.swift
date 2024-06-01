import Foundation

final class SearchViewModel: ObservableObject {
    @Published var searchText: String
    @Published var viewState: ViewState
    private let service: ServiceType
    
    init(searchText: String,
         viewState: ViewState,
         service: ServiceType = Service()) {
        self.searchText = searchText
        self.viewState = viewState
        self.service = service
    }
    
    enum ViewState: Equatable {
        case empty
        case loading
        case loaded([User])
        case error(RequestError)
    }
    
    public func fetchUsers(searchText: String,
                           completion: @escaping () -> Void) async {
        guard searchText.count >= Constants.minimumSearchLength else {
            displayEmptyState()
            completion()
            return
        }
        
        viewState = .loading
        
        guard let url = URL(string: "\(Constants.urlString)\(searchText)") else {
            viewState = .error(.invalidURL)
            completion()
            return
        }
        
        Task { @MainActor in
            let result: Result<Response, RequestError> = await service.fetch(url)
            switch result {
            case .success(let response):
                viewState = .loaded(response.users)
                completion()
            case .failure(let error):
                viewState = .error(error)
                completion()
            }
        }
    }
    
    private func displayEmptyState() {
        viewState = .empty
    }
}

private extension SearchViewModel {
    enum Constants {
        static let minimumSearchLength: Int = 2
        static let urlString: String = "https://api.github.com/search/users?q="
    }
}
