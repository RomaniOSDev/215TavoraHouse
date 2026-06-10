import SwiftUI

struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 8
    var shakes: CGFloat = 0

    var animatableData: CGFloat {
        get { shakes }
        set { shakes = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = amount * sin(shakes * .pi * 2)
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}
