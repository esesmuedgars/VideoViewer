//
// Copyright © 2020 @esesmuedgars.
//

import Foundation

final class Dependencies {
    
    static var shared = Dependencies()
    
    private init() {}
    
    let apiService: APIServiceProtocol = APIService()
    
    let coreDataService: CoreDataServiceProtocol = CoreDataService()
    
    let hlsService: HLSServiceProtocol = HLSService()
}
