import SwiftUI

struct SingleValueView: View {
    let title: String
    @Binding var value: CGFloat
    
    var body: some View {
        InputView(
            title: title,
            value: $value,
            increaseValue: {
                value += 0.01
            }, decreaseValue: {
                value -= 0.01
            })
    }
}

struct InputView: View {
    let title: String
    @Binding var value: CGFloat
    
    var increaseValue: () -> Void
    var decreaseValue: () -> Void
    
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    var body: some View {
        HStack() {
            Text(title)
            
            TextField(title, value: $value, formatter: formatter)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 100)
            
            Button("+") {
                increaseValue()
            }
            Button("-") {
                decreaseValue()
            }
        }
    }
}
