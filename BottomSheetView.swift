//
//  DragGesture.swift
//  BottomSheet


import SwiftUI

fileprivate enum Constants {
    static let radius: CGFloat = 16
    static let indicatorHeight: CGFloat = 6
    static let indicatorWidth: CGFloat = 60
    static let snapRatio: CGFloat = 0.25
    static let minHeightRatio: CGFloat = 0.3
}

struct BottomSheetView<Content: View>: View {
    @Binding var isOpen: Bool
    
    enum Position {
        case minHeight
        case maxHeight
        case close
    }
    
    @State private var isDragging = false
    @GestureState private var dragOffset = CGSize.zero
    @State private var position = CGSize.zero
    
    
    var minHeight: CGFloat = 200
    var maxHeight: CGFloat = 700
    let content: Content
    
    var offset: CGFloat {
        return maxHeight - minHeight
    }
    
    private var indicator: some View {
        RoundedRectangle(cornerRadius: Constants.radius)
            .fill(Color.secondary)
            .frame(
                width: Constants.indicatorWidth,
                height: Constants.indicatorHeight
            ).onTapGesture {
                self.isOpen.toggle()
            }
    }
    
    
    init(isOpen: Binding<Bool>, minHeight: CGFloat, maxHeight: CGFloat, @ViewBuilder content: () -> Content) {
        
        self.minHeight = minHeight
        self.maxHeight = maxHeight
        self.content = content()
        self._isOpen = isOpen
        self._position = State(initialValue: CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height - minHeight))
    }
    
    var body: some View {
        
        VStack(spacing: 0) {
            self.indicator.padding()
            self.content
        }
        .frame(width: UIScreen.main.bounds.size.width, height: self.maxHeight, alignment: .top)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(Constants.radius)
        .offset(y: position.height + dragOffset.height)
        .animation(.interactiveSpring())
        .gesture(
            
            DragGesture()
                .updating($dragOffset, body: { (value, state, transaction) in
                    state = value.translation
                })
                .onEnded{ value in
                    
                    let value =  self.position.height + value.translation.height
                    offset(value: value)
                    
                }
            
        )
        
    }
    
    private func offset(value: CGFloat) {
        let bottomSheetHeight = UIScreen.main.bounds.size.height  - value
        if bottomSheetHeight >= (maxHeight - offset / 2) {
            setBottomSheet(at: .maxHeight)
        }else if bottomSheetHeight >= minHeight && bottomSheetHeight <= (minHeight + offset / 2){
            setBottomSheet(at: .minHeight)
        }else if bottomSheetHeight < minHeight / 2{
            isOpen = false
        }
    }
    
    private func setBottomSheet(at: Position){
        switch at {
        case .maxHeight:
            self.position.height = UIScreen.main.bounds.size.height  - maxHeight
        case .minHeight:
            self.position.height = UIScreen.main.bounds.size.height  - minHeight
        case .close:
            isOpen = false
        }
    }
}

struct DragGesture_Previews: PreviewProvider {
    static var previews: some View {
        BottomSheetView(isOpen: .constant(true), minHeight: 200, maxHeight: 700) {
            Text("saurabh")
        }
    }
}

struct CornerRadiusStyle: ViewModifier {
    var radius: CGFloat
    var corners: UIRectCorner
    
    struct CornerRadiusShape: Shape {
        
        var radius = CGFloat.infinity
        var corners = UIRectCorner.allCorners
        
        func path(in rect: CGRect) -> Path {
            let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            return Path(path.cgPath)
        }
    }
    
    func body(content: Content) -> some View {
        content
            .clipShape(CornerRadiusShape(radius: radius, corners: corners))
    }
}

extension View {
    func cornerRadius(radius: CGFloat, corners: UIRectCorner) -> some View {
        ModifiedContent(content: self, modifier: CornerRadiusStyle(radius: radius, corners: corners))
    }
}
