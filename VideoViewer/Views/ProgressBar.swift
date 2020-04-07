//
// Copyright © 2020 @esesmuedgars.
//

import SwiftUI

struct ProgressBar: View {
    @Binding var value: CGFloat

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(Color(.systemGray4))

                Rectangle()
                    .frame(width: self.progressWidth(geometry))
                    .foregroundColor(Color(.systemBlue))
                    .animation(.linear, value: self.value)
            }
            .mask(Capsule())
        }
    }
    
    private func progressWidth(_ geometry: GeometryProxy) -> CGFloat {
        guard !value.isNaN, !value.isInfinite else {
            return .zero
        }

        return min(self.value * geometry.size.width, geometry.size.width)
    }
}
