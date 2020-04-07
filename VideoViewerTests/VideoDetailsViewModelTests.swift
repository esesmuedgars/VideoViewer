//
// Copyright © 2020 @esesmuedgars.
//

import XCTest
import Combine
@testable import VideoViewer

class VideoDetailsViewModelTests: XCTestCase {
    
    private var cancellable: Cancellable?
    
    private func makeViewModel(useCase: VideoUseCase = VideoUseCase(),
                               url: URL? = nil) -> (viewModel: VideoDetails.ViewModel, hlsService: HLSServiceMockProtocol) {
        let hlsService: HLSServiceMockProtocol = HLSServiceMock()
        hlsService.url = url
        
        let viewModel = VideoDetails.ViewModel(
            video: useCase,
            hlsService: hlsService as! HLSServiceProtocol
        )
        
        return (viewModel, hlsService)
    }
    
    override func tearDownWithError() throws {
        cancellable?.cancel()
        
        try super.tearDownWithError()
    }
    
    func testButtonIsOpaqueWithoutLocalAsset() throws {
        let expectation = self.expectation(
            description: "VideoDetails.ViewModel.$isOpaqueBarButton"
        )
        let (viewModel, _) = makeViewModel()
        
        XCTAssertTrue(viewModel.isOpaqueBarButton)
        
        cancellable = viewModel.$isOpaqueBarButton
            .dropFirst()
            .sink { output in
                XCTAssertTrue(output)
                
                expectation.fulfill()
            }
        
        waitForExpectations(timeout: 1)
    }
    
    func testButtonIsTranslucentWithLocalAsset() throws {
        let expectation = self.expectation(
            description: "VideoDetails.ViewModel.$isOpaqueBarButton output"
        )
        let (viewModel, _) = makeViewModel(url: URL(string: "path/to/file"))
        
        XCTAssertTrue(viewModel.isOpaqueBarButton)
        
        cancellable = viewModel.$isOpaqueBarButton
            .dropFirst()
            .sink { output in
                XCTAssertFalse(output)
                
                expectation.fulfill()
            }
        
        waitForExpectations(timeout: 1)
    }
    
    func testAssetDownloadProgressNotificationPublishedOutput() throws {
        let expectation = self.expectation(
            description: "VideoDetails.ViewModel.$downloadProgress output"
        )
        
        let useCase = VideoUseCase(id: 1)
        let (viewModel, _) = makeViewModel(useCase: useCase)
        
        XCTAssertEqual(viewModel.downloadProgress, 0)
        
        let debugPercetange = 0.5
        
        cancellable = viewModel.$downloadProgress
            .dropFirst()
            .sink { output in
                XCTAssertEqual(output, CGFloat(debugPercetange))
                
                expectation.fulfill()
            }
                
        let userInfo: [String: Any] = [
            Asset.Keys.id: String(useCase.id),
            Asset.Keys.percentDownloaded: debugPercetange
        ]

        NotificationCenter.default.post(name: .AssetDownloadProgress,
                                        object: nil,
                                        userInfo: userInfo)
        
        waitForExpectations(timeout: 1)
    }
    
    func testNotificationPublishedDownloadInProgress() throws {
        let expectation = self.expectation(
            description: "VideoDetails.ViewModel.$isDownloading inProgress"
        )
        
        let useCase = VideoUseCase(id: 1)
        let (viewModel, _) = makeViewModel(useCase: useCase)
        
        XCTAssertFalse(viewModel.isDownloading)
                
        cancellable = viewModel.$isDownloading
            .dropFirst()
            .sink { output in
                XCTAssertTrue(output)
                
                expectation.fulfill()
            }
        
        let userInfo = [
            Asset.Keys.id: String(useCase.id),
            Asset.Keys.downloadState: HLSService.DownloadState.inProgress.rawValue
        ]

        NotificationCenter.default.post(name: .AssetDownloadStateChanged,
                                        object: nil,
                                        userInfo: userInfo)
        
        waitForExpectations(timeout: 1)
    }
    
    func testNotificationPublishedDownloadComplete() throws {
        let expectation = self.expectation(
            description: "VideoDetails.ViewModel.$avAsset output"
        )
        
        let useCase = VideoUseCase(id: 1)
        let (viewModel, hlsService) = makeViewModel(useCase: useCase)
        
        XCTAssertNil(viewModel.avAsset)
        
        hlsService.url = URL(string: "path/to/file")
                
        cancellable = viewModel.$avAsset
            .dropFirst()
            .sink { output in
                XCTAssertNotNil(output, "Expected to receive some AVAsset")
                
                expectation.fulfill()
            }
        
        let userInfo = [
            Asset.Keys.id: String(useCase.id),
            Asset.Keys.downloadState: HLSService.DownloadState.completed.rawValue
        ]

        NotificationCenter.default.post(name: .AssetDownloadStateChanged,
                                        object: nil,
                                        userInfo: userInfo)
        
        waitForExpectations(timeout: 1)
    }
    
    func testToggleVideoDownloadPublishedDownloadState() throws {
        let expectation = self.expectation(
            description: "VideoDetails.ViewModel.toggleVideoDownload calls HLSService methods"
        )
        expectation.expectedFulfillmentCount = 2
        
        let useCase = VideoUseCase(id: 1)
        let (viewModel, _) = makeViewModel(useCase: useCase)
        
        var inProgress = false
        
        XCTAssertFalse(viewModel.isDownloading)
        
        cancellable = viewModel.$isDownloading
            .dropFirst()
            .handleEvents(receiveOutput: { output in
                if inProgress {
                    XCTAssertFalse(output)
                } else {
                    XCTAssertTrue(output)
                }
                
                expectation.fulfill()
            })
            .delay(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink { _ in
                guard !inProgress else {
                    return
                }
                
                inProgress = true
                    
                viewModel.toggleVideoDownload()
            }
        
        viewModel.toggleVideoDownload()
        
        waitForExpectations(timeout: 1)
    }
}

fileprivate extension VideoUseCase {
    init(id: Int = 0,
         name: String = "Name",
         thumbnail thumbnailURL: URL = URL(string: "thumbnail")!,
         description: String = "Description",
         video videoURL: URL = URL(string: "video")!) {
        self.init(id: id,
                  name: name,
                  thumbnailURL: thumbnailURL,
                  description: description,
                  videoURL: videoURL)
    }
}
