import SwiftUI

struct TransformSetupView: View {
    @Binding var transform: PhotogrammetryFolder.Transform
    var body: some View {
        VStack(alignment: .leading) {
            Text("Translation")
                .font(.headline)
            
            SingleValueView(title: "X", value: $transform.translation.x)
            SingleValueView(title: "Y", value: $transform.translation.y)
            SingleValueView(title: "Z", value: $transform.translation.z)
            
            Text("Rotation")
                .font(.headline)
                .padding(.top, 20)
            SingleValueView(title: "X", value: $transform.rotation.x)
            SingleValueView(title: "Y", value: $transform.rotation.y)
            SingleValueView(title: "Z", value: $transform.rotation.z)
        }
    }
}
