//
//  DrawingArea.swift
//  NumberRecognizer2.0
//
//  Created by M Kraay on 10/28/21.
//

import SwiftUI
import CoreML

struct DrawingArea: View {
    @State private var frames: [CGRect] = Array(repeating: CGRect(), count: 28 * 28)
    @Binding var pixels: [Double]
    @Binding var eraserOn: Bool
    @Binding var showingAlert: Bool
    
    let columns = Array(repeating: GridItem(spacing: 0), count: 28)
    
    var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .global)
            .onChanged { value in
                if let match = self.frames.firstIndex(where: { $0.contains(value.location) }) {
                    if eraserOn {
                        pixels[match] = 1
                    } else {
                        pixels[match] = max(pixels[match] - 0.25, 0)
                    }
                }
            }
    }
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 0) {
            ForEach(0..<pixels.count, id: \.self) { index in
               Rectangle()
                    .foregroundColor(Color(white: pixels[index]))
                    .overlay(
                        GeometryReader { geometry in
                            Color.clear
                                .onAppear {
                                    frames[index] = geometry.frame(in: .global)
                                }
                        }
                    )
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(maxWidth: .infinity, alignment: .center)
        .gesture(swipeGesture)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .foregroundColor(.white)
                .padding(.horizontal)
        )
        .padding(.bottom)
    }
}
