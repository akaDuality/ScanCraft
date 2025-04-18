import SwiftUI

struct TransformSetupView: View {
    @Binding var transform: PhotogrammetryFolder.Transform
    
    var exportAction: () -> Void
    var convertToGlbAction: () -> Void
    
    @State private var isConvertingGlb = false
    
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
            
            Text("Scale")
                .font(.headline)
                .padding(.top, 20)
            InputView(title: "Scale", value: $transform.scale.x) {
                transform.scale.x += .step
                transform.scale.y += .step
                transform.scale.z += .step
            } decreaseValue: {
                transform.scale.x -= .step
                transform.scale.y -= .step
                transform.scale.z -= .step
            }
            
            HStack {
                Button("Export") {
                    exportAction()
                }
                .padding(.trailing, 16)
                .padding(.bottom, 16)
                
                Button {
                    isConvertingGlb = true
                    Task {
                        convertToGlbAction()
                        await MainActor.run {
                            isConvertingGlb = false
                        }
                    }
                } label: {
                    if isConvertingGlb {
                         ProgressView()
                            .progressViewStyle(.circular)
                            .controlSize(.small)
                    } else {
                        Text("Convert to Glb")
                    }
                }
                .padding(.trailing, 16)
                .padding(.bottom, 16)
            }
        }
    }
}
