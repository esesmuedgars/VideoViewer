//
// Copyright © 2020 @esesmuedgars.
//

import XCTest
import Combine
@testable import VideoViewer

final class VideoListViewModelTests: XCTestCase {
    
    private var apiService: APIServiceMockProtocol!
    private var coreDataService: CoreDataServiceMockProtocol!
    private var viewModel: VideoList.ViewModel!
    
    private var cancellable: Cancellable?
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        let apiService = APIServiceMock()
        self.apiService = apiService
        
        let coreDataService = CoreDataServiceMock()
        self.coreDataService = coreDataService
        
        viewModel = VideoList.ViewModel(apiService: apiService, coreDataService: coreDataService)
    }

    override func tearDownWithError() throws {
        cancellable?.cancel()
        
        apiService = nil
        coreDataService = nil
        viewModel = nil
        
        try super.tearDownWithError()
    }

    func testFetchVideosPublishedOutput() throws {
        let expectation = self.expectation(description: "VideoList.ViewModel.$videos output")
        
        let videoA = Response.Video(id: 1,
                                    name: "Video A",
                                    thumbnailURL: URL(string: "thumbnail/1")!,
                                    description: "Description A",
                                    videoURL: URL(string: "video/1")!)
        
        let videoB = Response.Video(id: 2,
                                    name: "Video B",
                                    thumbnailURL: URL(string: "thumbnail/2")!,
                                    description: "Description B",
                                    videoURL: URL(string: "video/2")!)
        
        let videoC = Response.Video(id: 3,
                                    name: "Video C",
                                    thumbnailURL: URL(string: "thumbnail/3")!,
                                    description: "Description C",
                                    videoURL: URL(string: "video/3")!)
        
        let debugOutput = [videoA, videoB, videoC]
        
        apiService.videos = debugOutput
        
        cancellable = viewModel.$videos
            .dropFirst()
            .sink { output in
                let o = output.map({
                    Response.Video(id: $0.id,
                                   name: $0.name,
                                   thumbnailURL: $0.thumbnailURL,
                                   description: $0.description,
                                   videoURL: $0.videoURL)
                }).sorted(by: { $0.id < $1.id })
                
                XCTAssertEqual(o, debugOutput, "Published output did not match expected video list")
                
                expectation.fulfill()
            }
        
        viewModel.fetchVideos()
        
        waitForExpectations(timeout: 1)
    }
    
    func testFetchVideosUpdatesVideoItem() throws {
        let expectation = self.expectation(
            description: "VideoList.ViewModel.fetchVideos updates VideoItem values"
        )
        expectation.expectedFulfillmentCount = 2
        
        let videoA = Response.Video(id: 1,
                                    name: "Video A",
                                    thumbnailURL: URL(string: "thumbnail/1")!,
                                    description: "Description A",
                                    videoURL: URL(string: "video/1")!)
        
        let videoB = Response.Video(id: 1,
                                    name: "Video A",
                                    thumbnailURL: URL(string: "thumbnail/1")!,
                                    description: "Description B",
                                    videoURL: URL(string: "video/1")!)
        
        var isUpdated = false
        
        cancellable = viewModel.$videos
            .dropFirst()
            .handleEvents(receiveOutput: { output in
                if isUpdated {
                    XCTAssertEqual(output[0].id, videoB.id)
                    XCTAssertEqual(output[0].description, videoB.description)
                } else {
                    XCTAssertEqual(output[0].id, videoA.id)
                    XCTAssertEqual(output[0].description, videoA.description)
                }

                expectation.fulfill()
            })
            .sink { _ in
                isUpdated = true
                
                self.apiService.videos = [videoB]
                self.viewModel.fetchVideos()
            }
        
        apiService.videos = [videoA]
        
        viewModel.fetchVideos()
        
        waitForExpectations(timeout: 1)
    }
}
