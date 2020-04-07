//
// Copyright © 2020 @esesmuedgars.
//

import Foundation
import Combine

protocol APIServiceProtocol: class {
    func fetchVideos() -> AnyPublisher<[Response.Video], Never>
}

final class APIService: APIServiceProtocol {
    func fetchVideos() -> AnyPublisher<[Response.Video], Never> {
        guard let url = URL(endpoint: .videos) else {
            return Just([])
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { (data, _) in
                try JSONDecoder().decode(Response.self, from: data).videos
            }
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
}
