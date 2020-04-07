//
// Copyright © 2020 @esesmuedgars.
//

import Foundation
import Combine
@testable import VideoViewer

protocol APIServiceMockProtocol: class {
    var videos: [Response.Video] { get set }
}

final class APIServiceMock: APIServiceProtocol, APIServiceMockProtocol {
    @Published var videos = [Response.Video]()
    
    func fetchVideos() -> AnyPublisher<[Response.Video], Never> {
        $videos
            .delay(for: .milliseconds(100), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
