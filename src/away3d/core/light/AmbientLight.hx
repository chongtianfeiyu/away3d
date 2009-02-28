package away3d.core.light;

import flash.display.BitmapData;
import away3d.lights.AmbientLight3D;


/**
 * Ambient light primitive
 */
class AmbientLight extends LightPrimitive  {
	
	/**
	 * A reference to the <code>AmbientLight3D</code> object used by the light primitive.
	 */
	public var light:AmbientLight3D;
	

	/**
	 * Updates the bitmapData object used as the lightmap for ambient light shading.
	 * 
	 * @param	ambient		The coefficient for ambient light intensity.
	 */
	public function updateAmbientBitmap(ambient:Float):Void {
		
		this.ambient = ambient;
		ambientBitmap = new BitmapData(256, 256, false, Std.int(ambient * red << 16) | Std.int(ambient * green << 8) | Std.int(ambient * blue));
		ambientBitmap.lock();
	}

	// autogenerated
	public function new () {
		super();
		
	}

	

}

