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
    @State private var pixels: [Double] = Array(repeating: 1, count: 28 * 28)
    @State private var eraserOn = false
    @State private var showingAlert = false
    
    let columns = Array(repeating: GridItem(spacing: 0), count: 28)
    let buttonColor = Color(red: 250 / 255, green: 240 / 255, blue: 230 / 255)
    
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
        VStack {
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
            
            HStack(alignment: .center, spacing: 20) {
                Button(action: {
                    showingAlert = true
                }) {
                    Image(systemName: "questionmark.diamond")
                        .resizable()
                        .frame(width: 35, height: 35)
                }
                .buttonStyle(AppButton(color: buttonColor))
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Prediction from Image"), message: Text("\(predictNumber(from: pixels))"), dismissButton: .default(Text("Okay!")))
                }
                
                Button(action: {
                    eraserOn.toggle()
                }) {
                    Image(systemName: "pencil.slash")
                        .resizable()
                        .frame(width: 35, height: 35)
                }
                .buttonStyle(AppButton(color: eraserOn ? Color(red: 209 / 255, green: 190 / 255, blue: 168 / 255) : buttonColor))
                
                Button(action: {
                    for index in 0..<pixels.count {
                        pixels[index] = 1
                    }
                }) {
                    Image(systemName: "trash")
                        .resizable()
                        .frame(width: 35, height: 35)
                }
                .buttonStyle(AppButton(color: buttonColor))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(
            Image("backgroundImage")
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        )
        .ignoresSafeArea()
    }
    
    private func predictNumber(from pixels: [Double]) -> Int {
        let model = MNIST_IMG_Recognizer()
        guard let tensorInput = try? MLMultiArray(shape: [1, 28, 28, 1], dataType: .float32) else {
            print("Could not create tensorInput")
            return -1
        }
        // Populate the array with the image data
        for i in 1..<pixels.count {
            tensorInput[i] = NSNumber(value: Float32(1 - pixels[i]))
        }
        do {
            let prediction = try model.prediction(input_1: tensorInput)
            return findMax(of: prediction.Identity)
        } catch {
            print("Error making prediction")
            return -1
        }
    }
    
    private func findMax(of tensor: MLMultiArray) -> Int {
        var max: Float = 0
        var maxIndex: Int = 0
        for i in 0..<tensor.count {
            if tensor[i].floatValue > max {
                max = tensor[i].floatValue
                maxIndex = i
            }
        }
        return maxIndex
    }
}

struct AppButton: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(color)
            .foregroundColor(Color(red: 128 / 255, green: 0, blue: 0))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding()
    }
}
