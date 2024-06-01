import Combine
import XCTest
@testable import VIPASO

final class SearchViewModelTests: XCTestCase {
    var subject: SearchViewModel!
    var cancellables: Set<AnyCancellable> = .init()

    override func setUp() async throws {
        subject = SearchViewModel(searchText: "", viewState: .empty)
        cancellables = .init()
    }
    
    override func tearDown() {
        super.tearDown()
        subject = nil
        cancellables = []
    }
    
    func test_initialViewState_correct() {
        let state = subject.viewState
        XCTAssertEqual(state, SearchViewModel.ViewState.empty)
    }
    
    func test_fetchUsers_successfully() async {
        let expectation = XCTestExpectation(description: "")
        let expectedUsers: [User] = [makeUser()]
        var states: [SearchViewModel.ViewState] = []
        let response: Response = .init(users: expectedUsers)
        let service: ServiceType = MockService(response: response)
        subject = SearchViewModel(searchText: "", viewState: .empty, service: service)
    
        subject.$viewState
            .sink(receiveValue: { state in
                states.append(state)
            })
            .store(in: &cancellables)

        // when
        await subject.fetchUsers(searchText: "lol") {
            expectation.fulfill()
            XCTAssertEqual(states, [.empty, .loading, .loaded(expectedUsers)])
        }
        
        // then
        await fulfillment(of: [expectation])
    }
    
    
    func test_fetchUsers_failedWithBadRequestError() async {
        let expectation = XCTestExpectation(description: "")
        var states: [SearchViewModel.ViewState] = []
        let expectedError: RequestError = .clientBadRequest
        let service: ServiceType = MockService(error: expectedError)
        subject = SearchViewModel(searchText: "", viewState: .empty, service: service)
    
        subject.$viewState
            .sink(receiveValue: { state in
                states.append(state)
            })
            .store(in: &cancellables)

        // when
        await subject.fetchUsers(searchText: "lol") {
            expectation.fulfill()
            XCTAssertEqual(states, [.empty, .loading, .error(expectedError)])
        }
        
        // then
        await fulfillment(of: [expectation])
    }
    
    
    func test_displaysEmptyState_whenMinimalSearchTermLengthNotSatisfied() async {
        let expectation = XCTestExpectation(description: "")
        var states: [SearchViewModel.ViewState] = []
        subject = SearchViewModel(searchText: "", viewState: .empty)
    
        subject.$viewState
            .sink(receiveValue: { state in
                states.append(state)
            })
            .store(in: &cancellables)

        // when
        await subject.fetchUsers(searchText: "l") {
            expectation.fulfill()
            XCTAssertEqual(states, [.empty, .empty])
        }
        
        // then
        await fulfillment(of: [expectation])
    }
}

private func makeUser(id: Int = 00,
                      name: String = "user0",
                      avatorURL: URL? = nil) -> User {
    User(id: id, name: name, avatorURL: avatorURL)
}

private func makeService(response: Decodable? = nil,
                         error: RequestError? = nil) -> ServiceType {
    MockService(response: response, error: error)
}
