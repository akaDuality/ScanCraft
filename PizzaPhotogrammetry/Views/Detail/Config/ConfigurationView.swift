import SwiftUI

struct ConfigurationView: View {
    
    @Binding var position: PhotogrammetryFolder.ModelPosition
    
    var renderAction: () -> Void
    var previewAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            BoundingBoxSetupView(
                boundingBox: $position.boundingBox,
                boundingBoxOrientation: $position.boundingBoxOrientation)
            .onChange(of: position.boundingBox) { oldValue, newValue in
                position.transform.translation.y = -newValue.min.y
            }
            
            TransformSetupView(transform: $position.transform)
                .padding(.bottom, 40)
                .onChange(of: position.transform) { oldValue, newValue in
                    position.boundingBox.min.y = -newValue.translation.y
                }
            
            Button(action: previewAction) {
                Text("Preview")
                    .frame(width: 160)
            }
            .controlSize(.extraLarge)
            .buttonStyle(.borderedProminent)
            
            Button(action: renderAction) {
                Text("Render")
                    .frame(width: 160)
            }
            .controlSize(.extraLarge)
            .buttonStyle(.borderedProminent)
        }
    }
}
