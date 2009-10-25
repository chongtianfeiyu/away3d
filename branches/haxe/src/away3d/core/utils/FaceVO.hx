package away3d.core.utils;

import away3d.materials.ITriangleMaterial;
import flash.geom.Rectangle;
import away3d.core.base.Face;
import away3d.core.base.UV;
import away3d.core.base.Vertex;
import away3d.haxeutils.Hashable;


class FaceVO extends Hashable {
	public var maxU(getMaxU, null) : Float;
	public var minU(getMinU, null) : Float;
	public var maxV(getMaxV, null) : Float;
	public var minV(getMinV, null) : Float;
	
	public var v0:Vertex;
	public var v1:Vertex;
	public var v2:Vertex;
	public var uv0:UV;
	public var uv1:UV;
	public var uv2:UV;
	public var material:ITriangleMaterial;
	public var back:ITriangleMaterial;
	public var generated:Bool;
	public var face:Face;
	public var bitmapRect:Rectangle;
	
	

	/**
	 * Returns the maximum u value of the face
	 * 
	 * @see	away3d.core.base.UV#u
	 */
	public function getMaxU():Float {
		
		if (uv0.u > uv1.u) {
			if (uv0.u > uv2.u) {
				return uv0.u;
			} else {
				return uv2.u;
			}
		} else {
			if (uv1.u > uv2.u) {
				return uv1.u;
			} else {
				return uv2.u;
			}
		}
		
		// autogenerated
		return 0;
	}

	/**
	 * Returns the minimum u value of the face
	 * 
	 * @see away3d.core.base.UV#u
	 */
	public function getMinU():Float {
		
		if (uv0.u < uv1.u) {
			if (uv0.u < uv2.u) {
				return uv0.u;
			} else {
				return uv2.u;
			}
		} else {
			if (uv1.u < uv2.u) {
				return uv1.u;
			} else {
				return uv2.u;
			}
		}
		
		// autogenerated
		return 0;
	}

	/**
	 * Returns the maximum v value of the face
	 * 
	 * @see away3d.core.base.UV#v
	 */
	public function getMaxV():Float {
		
		if (uv0.v > uv1.v) {
			if (uv0.v > uv2.v) {
				return uv0.v;
			} else {
				return uv2.v;
			}
		} else {
			if (uv1.v > uv2.v) {
				return uv1.v;
			} else {
				return uv2.v;
			}
		}
		
		// autogenerated
		return 0;
	}

	/**
	 * Returns the minimum v value of the face
	 * 
	 * @see	away3d.core.base.UV#v
	 */
	public function getMinV():Float {
		
		if (uv0.v < uv1.v) {
			if (uv0.v < uv2.v) {
				return uv0.v;
			} else {
				return uv2.v;
			}
		} else {
			if (uv1.v < uv2.v) {
				return uv1.v;
			} else {
				return uv2.v;
			}
		}
		
		// autogenerated
		return 0;
	}

	// autogenerated
	public function new () {
		super();
	}

	

}
