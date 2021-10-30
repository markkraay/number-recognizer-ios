//
//  ContentView.swift
//  NumberRecognizer2.0
//
//  Created by M Kraay on 10/28/21.
//

import SwiftUI
import CoreGraphics

struct ContentView: View {
    @State var drawings: [CGPoint] = []
    @State var lineWidth: CGFloat = 1.0
    
    var body: some View {
//        DrawingArea(lineWidth: $lineWidth)
        DrawingArea()
    }
}

