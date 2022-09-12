// Copyright (c) 2022 Mark Horgan
//
// This source code is for individual learning purposes only. You may not copy,
// modify, merge, publish, distribute, create a derivative work or sell copies
// of the software in any work that is intended for pedagogical or
// instructional purposes.

import RealityKit
import ARKit

enum AnimationType {
    case none
    case fromToBy
    case sampled
    case orbit
    case blendTree
    case animationView
    case animationGroup
}

class CustomARView: ARView {
    private var anchorEntity: AnchorEntity!
    
    required init(frame: CGRect) {
        super.init(frame: frame)
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        session.run(config, options: [])
        
        anchorEntity = AnchorEntity(plane: .horizontal)
        anchorEntity.name = "anchor"
        scene.addAnchor(anchorEntity)
        
        addCoaching()
    }
    
    public func runAnimation(_ animationType: AnimationType) {
        switch animationType {
        case .none: return
        case .fromToBy: fromToBy()
        case .sampled: sampled()
        case .orbit: orbit()
        case .blendTree: blendTree()
        case .animationView: animationView()
        case .animationGroup: animationGroup()
        }
    }
    
    @objc required dynamic init?(coder decorder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func fromToBy() {
        let animationDefinition = FromToByAnimation(to: Transform(translation: [0.1, 0, 0]), duration: 1.0, bindTarget: .transform)
        let animationResource = try! AnimationResource.generate(with: animationDefinition)
        
        anchorEntity.children.removeAll()
        let boxEntity = createBoxEntity()
        boxEntity.playAnimation(animationResource)
    }
    
    private func sampled() {
        var transforms:[Transform] = []
        for _ in 1...10 {
            transforms.append(Transform(translation: [Float.random(in: -0.1..<0.1), 0, Float.random(in: -0.1..<0.1)]))
        }
        let animationDefinition = SampledAnimation(frames: transforms, frameInterval: 0.75, bindTarget: .transform)
        let animationResource = try! AnimationResource.generate(with: animationDefinition)
        
        anchorEntity.children.removeAll()
        let boxEntity = createBoxEntity()
        boxEntity.playAnimation(animationResource)
    }
    
    private func orbit() {
        let animationDefinition = OrbitAnimation(duration: 2, axis: [0, 1, 0], startTransform: Transform(translation: [0.1, 0, 0]),
                                                                                                         bindTarget: .transform)
        let animationResource = try! AnimationResource.generate(with: animationDefinition)
        
        anchorEntity.children.removeAll()
        let boxEntity = createBoxEntity()
        boxEntity.playAnimation(animationResource)
    }
    
    private func blendTree() {
        let animationDefinition1 = FromToByAnimation(to: Transform(translation: [0.2, 0, 0]), duration: 1.0, bindTarget: .transform)
        let animationDefinition2 = FromToByAnimation(to: Transform(translation: [0, 0, -0.1]), duration: 1.0, bindTarget: .transform)
        let blendTreeDefinition = BlendTreeAnimation<Transform>(
            BlendTreeBlendNode(sources: [
                BlendTreeSourceNode(source: animationDefinition1, weight: .value(0.25)),
                BlendTreeSourceNode(source: animationDefinition2, weight: .value(0.75))
            ])
        )
        let animationResource = try! AnimationResource.generate(with: blendTreeDefinition)
        
        anchorEntity.children.removeAll()
        let boxEntity = createBoxEntity()
        boxEntity.playAnimation(animationResource)
    }
    
    private func animationView() {
        let animationDefinition = FromToByAnimation(to: Transform(translation: [0.1, 0, 0]), duration: 1.0, bindTarget: .transform)
        let animationViewDefinition = AnimationView(source: animationDefinition, delay: 1, speed: 0.5)
        let animationResource = try! AnimationResource.generate(with: animationViewDefinition)
        
        anchorEntity.children.removeAll()
        let boxEntity = createBoxEntity()
        boxEntity.playAnimation(animationResource)
    }
    
    private func animationGroup() {
        let animationDefinition1 = FromToByAnimation(to: Transform(translation: [0.1, 0, 0]), bindTarget: .transform)
        let animationDefinition2 = FromToByAnimation(to: Transform(translation: [0, 0, -0.1]), bindTarget: .anchorEntity("anchor").entity("blueBox").transform)
        let animationGroupDefinition = AnimationGroup(group: [animationDefinition1, animationDefinition2])
        let animationResource = try! AnimationResource.generate(with: animationGroupDefinition)
        
        anchorEntity.children.removeAll()
        let redBox = createBoxEntity(color: .red, name: "redBox")
        createBoxEntity(color: .blue, name: "blueBox", position: [0.1, 0, -0.1])
        redBox.playAnimation(animationResource)
    }
    
    // MARK: Helper methods
    
    @discardableResult private func createBoxEntity(color: UIColor = .red, name: String? = nil, position: SIMD3<Float>? = nil) -> ModelEntity {
        let size: Float = 0.05
        let boxEntity = ModelEntity(mesh: .generateBox(size: size), materials: [SimpleMaterial(color: color, isMetallic: false)])
        if let name = name {
            boxEntity.name = name
        }
        if let position = position {
            boxEntity.position = position
        }
        anchorEntity.addChild(boxEntity)
        return boxEntity
    }
    
    private func addCoaching() {
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.session = session
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coachingOverlay.goal = .horizontalPlane
        self.addSubview(coachingOverlay)
    }
}
