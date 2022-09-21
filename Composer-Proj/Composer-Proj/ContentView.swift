//
//  ContentView.swift
//  Composer-Proj
//
//  Created by Rafael Carvalho on 19/09/22.
//

import SwiftUI
import RealityKit

class ViewModel: ObservableObject {
    @Published var objectName: String = ""
    
    var onStartBoxSpinNotification: () -> Void = { }
}

struct ContentView : View {
    
    @StateObject var vm = ViewModel()
    
    var body: some View {
        VStack {
            ARViewContainer(vm: vm).edgesIgnoringSafeArea(.all)
            VStack {
                Text(vm.objectName)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                
                // Botão para dar um POST em uma action lá no [Box Behavior] Reality Composer
                Button("Spin Box") {
                    vm.onStartBoxSpinNotification()
                }.padding()
                    .background(.blue)
                    .clipShape(Capsule())
                
            }.frame(maxWidth: .infinity, maxHeight: 100)
                .background(.brown)
                .foregroundColor(.white)
            
        }
        
    }
}

struct ARViewContainer: UIViewRepresentable {
    
    let vm: ViewModel
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        
        // Load the "Box" scene from the "Experience" Reality File
        let mainSceneAnchor = try! Experience.loadMainScene()
        
        // Aqui eu dou um "override" na função do meu ViewModel
        vm.onStartBoxSpinNotification = {
            mainSceneAnchor.notifications.boxSpinNotification.post()
        }
        
        
        // Captura todos os actions que contenham "display" no nome.
        // O robô possúi um Action chanado "DisplayRobotDetails"
        // e o planeta possúi um action chamado "DisplayEarthDetais"
        let allDisplayActions = mainSceneAnchor.actions.allActions.filter {
            $0.identifier.hasPrefix("Display")
        }
        
        // Itera sobre esse compilado de actions
        for displayAction in allDisplayActions {
            displayAction.onAction = { entity in
                
                // Popula
                if let entity = entity {
                    vm.objectName = entity.name
                }
            }
        }

        // Add the box anchor to the scene
        arView.scene.anchors.append(mainSceneAnchor)
        
        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
