struct Coord: Codable, Equatable {
    var x: CGFloat
    var y: CGFloat
    var z: CGFloat
    
    static var zero: Self { Self(x: 0, y: 0, z: 0) }
}

struct Coord4: Codable, Equatable {
    var x: CGFloat
    var y: CGFloat
    var z: CGFloat
    var r: CGFloat
    
    static var zero: Self { Self(x: 0, y: 0, z: 0, r: 0) }
}

struct BoundingBox: Codable, Equatable {
    var min: Coord
    var max: Coord
    
    static var zero: Self {
        Self(min: .zero, max: .zero)
    }
    
    var height: CGFloat {
        max.y - min.y
    }
}

import SceneKit
extension BoundingBox {
    var sceneKitBoundingBox: (min: SCNVector3, max: SCNVector3) {
        (min: min.vector3, max: max.vector3)
    }
}

extension Coord {
    var vector3: SCNVector3 {
        SCNVector3(x: x, y: y, z: z)
    }
}

import RealityKit
extension BoundingBox {
    var realityKit: RealityKit.BoundingBox {
        .init(min: min.simd3, max: max.simd3)
    }
    
    static func from(_ boundingBox: RealityKit.BoundingBox) -> Self {
        Self(min: .from(boundingBox.min),
             max: .from(boundingBox.max))
    }
}

extension Coord {
    var simd3: SIMD3<Float> {
        SIMD3(Float(x), Float(y), Float(z))
    }
    
    static func from(_ coord: SIMD3<Float>) -> Self {
        Self(x: CGFloat(coord.x), y: CGFloat(coord.y), z: CGFloat(coord.z))
    }
}

extension Coord4 {
    var simd4: simd_quatf {
        simd_quatf(ix: Float(x), iy: Float(y), iz: Float(z), r: Float(r))
    }
}

// MARK: - Trasform

extension Item {
    struct Transform: Codable, Equatable {
        var translation: Coord
        var rotation: Coord4
        var scale: Coord
        
        static var zero: Self {
            Self(translation: .zero, rotation: .zero, scale: .zero)
        }
    }
}
