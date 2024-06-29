import SwiftUI

struct ConfigurationView: View {
    
    @Binding var boundingBox: BoundingBox
    @Binding var transform: Item.Transform
    @Binding var boundingBoxOrientation: Coord4
    
    var renderAction: () -> Void
    var previewAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            BoundingBoxSetupView(
                boundingBox: $boundingBox,
                boundingBoxOrientation: $boundingBoxOrientation)
            .onChange(of: boundingBox) { oldValue, newValue in
                transform.translation.y = -newValue.min.y
            }
            
            TransformSetupView(transform: $transform)
                .padding(.bottom, 40)
            
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
