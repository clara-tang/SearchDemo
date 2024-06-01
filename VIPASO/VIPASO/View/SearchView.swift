import Foundation
import SwiftUI

struct SearchView: View {
    @ObservedObject private var viewModel = SearchViewModel(searchText: "", viewState: .empty)
    
    var body: some View {
        NavigationStack {
            switch viewModel.viewState {
            case .loading:
                ProgressView()
            case .loaded(let users):
                List(users) { UserCell(user: $0) }
            case .empty:
                EmptyView(title: Constants.emptyStateTitle)
            case .error(let error):
                ErrorView(title: Constants.errorStateTitle, error: error)
            }
        }
        .searchable(text: $viewModel.searchText, prompt: Constants.prompt)
        .onChange(of: viewModel.searchText, { _, newText in
            Task {
                await viewModel.fetchUsers(searchText: newText) {}
            }
        })
    }
}

private extension SearchView {
    enum Constants {
        static let prompt: String = "Type something to search"
        static let emptyStateTitle: String = "No search results"
        static let errorStateTitle: String = "Fetch users error: "
    }
}

// MARK: - UserCell

struct UserCell: View {
    let user: User
    
    var body: some View {
        HStack(alignment: .center, spacing: Constants.spacing) {
            AsyncImage(url: user.avatorURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: Constants.width, maxHeight: Constants.height)
            } placeholder: {
                Image(uiImage: Constants.placeholderImage)
                    .resizable()
                    .frame(maxWidth: Constants.width, maxHeight: Constants.height)
            }
            .clipShape(.circle)
    
            Text(user.name)
                .font(.subheadline)
        }
    }
}

extension UserCell {
    enum Constants {
        static let spacing: CGFloat = 16.0
        static let width: CGFloat = 44.0
        static let height: CGFloat = 44.0
        static let placeholderImage: UIImage = UIImage(named: "placeholder")!
    }
}

// MARK: - EmptyView

struct EmptyView: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.subheadline)
    }
}

// MARK: - ErrorView

struct ErrorView: View {
    let title: String
    let error: RequestError

    var body: some View {
        Text("\(title)\(String(describing: error))")
            .font(.callout)
    }
}
