import SwiftUI

struct BoundingBoxSetupView: View {
    @Binding var boundingBox: BoundingBox
    @Binding var boundingBoxOrientation: Coord4
    
    let step: CGFloat = 0.005
    
    var body: some View {
        Text("Box")
            .font(.headline)
        
        VStack(alignment: .trailing) {
            InputView(
                title: "Top",
                value: $boundingBox.max.y,
                increaseValue: {
                    boundingBox.max.y += step
                }, decreaseValue: {
                    boundingBox.max.y -= step
                })
            
            InputView(
                title: "Bottom",
                value: $boundingBox.min.y,
                increaseValue: {
                    boundingBox.min.y += step
                }, decreaseValue: {
                    boundingBox.min.y -= step
                })
            
            InputView(
                title: "Width",
                value: .constant(boundingBox.width),
                increaseValue: {
                    boundingBox.min.x -= step
                    boundingBox.max.x += step
                }, decreaseValue: {
                    boundingBox.min.x += step
                    boundingBox.max.x -= step
                })
            
            InputView(
                title: "Length",
                value: .constant(boundingBox.length),
                increaseValue: {
                    boundingBox.min.z -= step
                    boundingBox.max.z += step
                }, decreaseValue: {
                    boundingBox.min.z += step
                    boundingBox.max.z -= step
                })
            
            Text("Rotation")
                .font(.headline)
                .padding(.top, 20)
            SingleValueView(title: "X", value: $boundingBoxOrientation.x)
            SingleValueView(title: "Y", value: $boundingBoxOrientation.y)
            SingleValueView(title: "Z", value: $boundingBoxOrientation.z)
            
        }.padding(.bottom, 40)
    }
}
