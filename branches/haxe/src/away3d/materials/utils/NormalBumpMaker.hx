package away3d.materials.utils;

import away3d.core.math.Matrix3D;
import away3d.core.math.Number3D;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BitmapDataChannel;
import flash.display.BlendMode;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;


/**
 * Utility class, principally to transform bump map data into normal map data. Can be used also to add bumps to an existing normal map.
 * 
 * Additional numerically quick function to rotate the normals in a normal map by 90 or 180 degrees.
 */
class NormalBumpMaker  {
	
	

	public function new() {
		
		
	}

	/**
	 * Returns a positional vector for (ui, vi), taking into account bump map displacement.
	 * Calls external function if geometrical relationship known between (ui, vi) and (x, y, z)
	 * 
	 * @param bumpMapData 			BitmapData. The bumpmap bitmapdata;
	 * @param i 								uint. pixel x position
	 * @param j 								uint. pixel y position
	 * @param amplitude 					Number. Factor to scale the bumps.
	 * @param u 							Number. u coordinate.
	 * @param v 								Number. v coordinate.
	 * @param geometryFunction 		[optional] Function. Mapping function to convert from uv to xyz in real space
	 *
	 * @return A Number3D for the position vector
	 * 
	 */
	private function getPosition(bumpMapData:BitmapData, i:Int, j:Int, amplitude:Float, u:Float, v:Float, geometryFunction:Dynamic):Number3D {
		
		var bump:Float = amplitude * getDisplacement(bumpMapData, i, j);
		var position:Number3D;
		if (geometryFunction != null) {
			position = geometryFunction.call(this, u, v, bump);
		} else {
			position = new Number3D(u, v, bump);
		}
		return position;
	}

	/**
	 * Converts a pixel value into a displacement between 0 and 1. Assumes greyscale data so only uses the blue channel.
	 * 
	 * @param bumpMapData 			BitmapData. The bumpmap bitmapdata;
	 * @param i 					uint. pixel x position
	 * @param j 					uint. pixel y position
	 *
	 * @return A Number for the displacement size between 0 and 1
	 */
	private function getDisplacement(bumpMapData:BitmapData, i:Int, j:Int):Float {
		
		return (bumpMapData.getPixel(i, j) & 0xFF) / 255.0;
	}

	/**
	 * Converts a pixel from raw normal map data into a normal vector. 
	 *  
	 * @param pixel					unit: The pixel value containing normal vector data
	 *
	 * @return 						Number3D: The normal vector				
	 * 
	 */
	private function convertToVector(pixel:Int):Number3D {
		
		var x:Float = ((pixel & 0xFF0000) >> 16) / 255.0 - 0.5;
		var y:Float = ((pixel & 0x00FF00) >> 8) / 255.0 - 0.5;
		var z:Float = ((pixel & 0x0000FF)) / 255.0 - 0.5;
		return new Number3D(x, y, z);
	}

	/**
	 * Calculates normal from cross product between two vectors on the bump surface.
	 * Each vector on surface calculated from two positional vectors
	 *
	 * @param pvp1					Number. Position vector a uv coordinate (u, v+1)
	 * @param pvm1					Number. Position vector a uv coordinate (u, v-1)
	 * @param pup1					Number. Position vector a uv coordinate (u+1, v)
	 * @param pum1					Number. Position vector a uv coordinate (u-1, v)
	 *
	 * @return A Number3D for the calculated normal vector
	 */
	private function calculateNormal(pvp1:Number3D, pvm1:Number3D, pup1:Number3D, pum1:Number3D):Number3D {
		// calculate directional vectors between the points
		
		var vv:Number3D = new Number3D();
		vv.sub(pvp1, pvm1);
		var vu:Number3D = new Number3D();
		vu.sub(pup1, pum1);
		// calculate normal from cross product. If the vectors are too small then
		// just use an average of the positional vectors. This removes some badly
		// calculated cross products.
		var normal:Number3D = new Number3D();
		if (vu.modulo < 0.001 || vv.modulo < 0.001) {
			normal.add(pum1, pup1);
			normal.add(normal, pvm1);
			normal.add(normal, pvp1);
			normal.scale(normal, 0.25);
		} else {
			normal.cross(vv, vu);
		}
		return normal;
	}

	/**
	 * Converts the calculated normal vector into RGB values and sets the pixel value. 
	 * Takes into account different coordinate systems. For example "xyz" is traditional left-handed coordinate system
	 * "xzy" is a righthanded coordinate system (such as in Away3D)
	 * 
	 * For a bump map on a plane, the first two axes are the u-v coordinates, the last being the displacement direction
	 * 
	 * @param normalMapData 		BitmapData. The normalmap bitmapdata;
	 * @param i 					uint. pixel x position
	 * @param j 					uint. pixel y position
	 * @param normal 				Number3D. Calculated normal vector
	 * @param coordinates			String. Decides how pixel colours should be ordered
	 */
	private function setNormal(normalMapData:BitmapData, i:Int, j:Int, normal:Number3D, coordinates:String):Void {
		
		normal.normalize();
		var nx:Float;
		var ny:Float;
		var nz:Float;
		// Map normal components from [-1, 1] to [0, 255]
		if (coordinates == "xyz") {
			nx = (normal.x / 2) + 0.5;
			ny = (normal.y / 2) + 0.5;
			nz = (normal.z / 2) + 0.5;
		} else if (coordinates == "xzy") {
			nx = (normal.x / 2) + 0.5;
			ny = (normal.z / 2) + 0.5;
			nz = (normal.y / 2) + 0.5;
		}
		// ensure that vectors are within limits
		if (nx > 1) {
			nx = 1;
		}
		if (ny > 1) {
			ny = 1;
		}
		if (nz > 1) {
			nz = 1;
		}
		// Set components into RGB pixel values
		var color:Int = nx * 0xFF << 16 | ny * 0xFF << 8 | nz * 0xFF;
		normalMapData.setPixel(i, j, color);
	}

	/**
	 * Method to change normal directions by 90 or 180 degrees so that, for example, a normal map created for a plane in the
	 * xy plane can be used in an xz plane for which the rotation produces a mapping (x, y, z) -> (x, z, -y)
	 * 
	 * Quick method: rather than recalculating the normals just modify the red, green and blue channels of the normal map data.
	 * In the above example, the blue channel is copied to the green channel.
	 * 
	 * To account for vector components which are negated we use a inverted bitmap (255 - original value). In the above example
	 * we copy the inverted green channel to the blue channel. 
	 * 
	 *
	 * @param sourceData 			BitmapData. The source bitmapdata;
	 * @param redSource 			[optional] uint. The uint representing the red channel. Default is BitmapDataChannel.RED.
	 * @param greenSource 			[optional] uint. The uint representing the green channel. Default BitmapDataChannel.GREEN.
	 * @param blueSource 			[optional] uint. The uint representing the blue channel. Default BitmapDataChannel.BLUE.
	 * @param invertRed 			[optional] Boolean. If the red channel needs to be inverted. Default false.
	 * @param invertGreen 			[optional] Boolean. If the green channel needs to be inverted. Default false.
	 * @param invertBlue 			[optional] Boolean. If the blue channel needs to be inverted. Default false.
	 *
	 * @return A bitmapdata for the rotated normal map
	 */
	public function convertNormalChannels(sourceData:BitmapData, ?redSource:Int=1, ?greenSource:Int=2, ?blueSource:Int=4, ?invertRed:Bool=false, ?invertGreen:Bool=false, ?invertBlue:Bool=false):BitmapData {
		
		var width:Float = sourceData.width;
		var height:Float = sourceData.height;
		var rect:Rectangle = new Rectangle(0, 0, width, height);
		var point:Point = new Point(0, 0);
		// Create new bitmapData for return result
		var destData:BitmapData = new BitmapData(width, height, false, 0x000000);
		var inverseSourceData:BitmapData;
		if (invertRed || invertGreen || invertBlue) {
			inverseSourceData = new BitmapData(width, height, false, 0xFFFFFF);
			inverseSourceData.copyPixels(sourceData, rect, point);
			inverseSourceData.draw(new Bitmap(new BitmapData(width, height, false, 0x000000)), null, null, BlendMode.INVERT);
		}
		// Copy destination vector component to red channel, negating if necessary
		if (invertRed) {
			destData.copyChannel(inverseSourceData, new Rectangle(0, 0, width, height), new Point(0, 0), redSource, BitmapDataChannel.RED);
		} else {
			destData.copyChannel(sourceData, new Rectangle(0, 0, width, height), new Point(0, 0), redSource, BitmapDataChannel.RED);
		}
		// Copy destination vector component to green channel, negating if necessary
		if (invertGreen) {
			destData.copyChannel(inverseSourceData, new Rectangle(0, 0, width, height), new Point(0, 0), greenSource, BitmapDataChannel.GREEN);
		} else {
			destData.copyChannel(sourceData, new Rectangle(0, 0, width, height), new Point(0, 0), greenSource, BitmapDataChannel.GREEN);
		}
		// Copy destination vector component to blue channel, negating if necessary
		if (invertBlue) {
			destData.copyChannel(inverseSourceData, new Rectangle(0, 0, width, height), new Point(0, 0), blueSource, BitmapDataChannel.BLUE);
		} else {
			destData.copyChannel(sourceData, new Rectangle(0, 0, width, height), new Point(0, 0), blueSource, BitmapDataChannel.BLUE);
		}
		return destData;
	}

	/**
	 * Add bumps to a normal Map. Bumps are initially converted to normal vectors (assuming that they are on a plane originally) and
	 * then a rotation is applied to align them with the original normal map data.
	 * 
	 * @param normalMapData				BitmapData. Original normal map.
	 * @param bumpMapData				BitmapData. Original bump map.
	 * @param amplitude					[optional] Number. Amplitude of bumps. Default is 0.05
	 * @param uRepeat 					[optional] Boolean. If the U coordinate should be repeated. Default false;
	 * @param vRepeat 					[optional] Boolean. If the V coordinate should be repeated. Default false;
	 * @return 							BitmapData. Bumps applied to normal map.
	 * 
	 */
	public function addBumpsToNormalMap(normalMapData:BitmapData, bumpMapData:BitmapData, ?amplitude:Float=0.05, ?uRepeat:Bool=false, ?vRepeat:Bool=false):BitmapData {
		// scale the bump map data to the same dimensions as the normal map data.
		
		var newBumpData:BitmapData = new BitmapData(normalMapData.width, normalMapData.height, false, 0x00000);
		if (normalMapData.width != bumpMapData.width || normalMapData.height != bumpMapData.height) {
			var matrix:Matrix = new Matrix();
			matrix.scale(normalMapData.width / bumpMapData.width, normalMapData.height / bumpMapData.height);
			newBumpData.draw(bumpMapData, matrix, null, BlendMode.NORMAL, null, true);
		} else {
			newBumpData = bumpMapData.clone();
		}
		// Convert the bump map data to normal map. For simplicity ignores the geometry function, assumes bumps are on a plane
		// in the xy direction.
		var bumpNormalData:BitmapData = convertToNormalMap(newBumpData, null, amplitude, uRepeat, vRepeat, "xyz");
		// defines the zaxis vector
		var zAxis:Number3D = new Number3D(0, 0, 1);
		// loop over normal map data. Calculate rotation necessary to align bumps correctly.
		var i:Float = 0;
		while (i < normalMapData.width) {
			var j:Float = 0;
			while (j < normalMapData.height) {
				var baseNormal:Number3D = convertToVector(normalMapData.getPixel(i, j));
				var bumpNormal:Number3D = convertToVector(bumpNormalData.getPixel(i, j));
				// Calculate rotation matrix necessary to rotate the zaxis onto the normal.
				// First of all calcualte axis of rotation from cross product of normal and zaxis
				var rotationAxis:Number3D = new Number3D();
				rotationAxis.cross(baseNormal, zAxis);
				// determine angle of rotation
				var theta:Float = baseNormal.getAngle(zAxis);
				// Create rotation matrix.
				var rotationMatrix:Matrix3D = new Matrix3D();
				rotationMatrix.rotationMatrix(rotationAxis.x, rotationAxis.y, rotationAxis.z, theta);
				// Apply rotation matrix to bump map normal
				var correctedBump:Number3D = new Number3D();
				correctedBump.rotate(bumpNormal, rotationMatrix);
				// Store the bump normal, mapped to the original normal, in the bitmap data
				setNormal(bumpNormalData, i, j, correctedBump, "xyz");
				
				// update loop variables
				j++;
			}

			
			// update loop variables
			i++;
		}

		return bumpNormalData;
	}

	/**
	 * Function to convert bump map displacements into a normal map
	 * 
	 * Calculations are performed to calculate the vectors on the original bump map and from these the 
	 * normal is obtained. 
	 * 
	 * Conversion utility allows for a geometrical function to map from the (u, v) coordinates of the bump map
	 * to (x, y, z) coordinates of a particular model. The amplitude of the bump can also be specified with relation
	 * to the maximum u and v values of the bumpmap (being equal to 1). If the bump map has repeated boundaries (for
	 * example with a sphere or torus) this can be specified as well.
	 * 
	 * By default bump displacements are assumed to be in the "y" direction (for planes) but this can be specifying
	 * a coordinate value, for example "xyz" assumes u and v are in the x and y direction, displacements in the z.
	 * 
	 * For example, for a sphere the geometry function would be:
	 * 
	 * 		public function convertToSpherical(ui:Number, vi:Number, disp:Number):Number3D {
	 *			var theta:Number = ui * 2 * Math.PI;
	 *			var phi:Number = vi * Math.PI;
	 *			var p:Number3D = new Number3D(Math.cos(theta)*Math.sin(phi), Math.sin(theta)*Math.sin(phi), Math.cos(phi));
	 *	
	 *			var pScaled:Number3D = new Number3D();
	 *			pScaled.scale(p, 1 + disp);
	 *	
	 *			return pScaled;
	 *		}
	 * 
	 * The call to create a spherical normal map with bump map data having a max amplitude of 0.1, that is 
	 * repeated along the u direction would be:
	 * 
	 * 		convertToNormal(bumpMapData, convertToSpherical, 0.1, true, false);
	 *
	 *
	 * @param bumpMapData 			BitmapData. The bitmapdata with the bump information.
	 * @param geometryFunction 		[optional] Function. The geometrical function to apply. Default null.
	 * @param amplitude 			[optional] Number. The amount of amplitude. Default 0.05.
	 * @param uRepeat 				[optional] Boolean. If the U coordinate should be repeated. Default false;
	 * @param vRepeat 				[optional] Boolean. If the V coordinate should be repeated. Default false;
	 * @param coordinates 			[optional] String. Decides how pixel colours should be ordered. Default "xzy";
	 *
	 * @return A bitmapdata
	 */
	public function convertToNormalMap(bumpMapData:BitmapData, ?geometryFunction:Dynamic=null, ?amplitude:Float=0.05, ?uRepeat:Bool=false, ?vRepeat:Bool=false, ?coordinates:String="xzy"):BitmapData {
		
		if (bumpMapData == null) {
			return null;
		}
		var ui:Float;
		var uim1:Float;
		var uip1:Float;
		var vi:Float;
		var vim1:Float;
		var vip1:Float;
		var p_uivim1:Number3D;
		var p_uivip1:Number3D;
		var p_uim1vi:Number3D;
		var p_uip1vi:Number3D;
		var normal:Number3D;
		var width:Float = bumpMapData.width;
		var height:Float = bumpMapData.height;
		// Create new bitmap data to store normal map
		var normalMapData:BitmapData = new BitmapData(width, height, false, 0x000000);
		// Copy bump map into a larger bitmap data so that we can more easily account for boundary conditions
		var extendedBumpMapData:BitmapData = new BitmapData(width + 2, height + 2, false, 0xFFFFFF);
		extendedBumpMapData.copyPixels(bumpMapData, new Rectangle(0, 0, width, height), new Point(1, 1));
		// Copy the left and right edges to the opposite sides if bump map is repeated in the u direction
		if (uRepeat) {
			extendedBumpMapData.copyPixels(bumpMapData, new Rectangle(0, 0, 1, height), new Point(width + 1, 1));
			extendedBumpMapData.copyPixels(bumpMapData, new Rectangle(width - 1, 0, 1, height), new Point(0, 1));
		} else {
			extendedBumpMapData.copyPixels(bumpMapData, new Rectangle(0, 0, 1, height), new Point(0, 1));
			extendedBumpMapData.copyPixels(bumpMapData, new Rectangle(width - 1, 0, 1, height), new Point(width + 1, 1));
		}
		// Copy the top and bottom edges to the opposite sides if bump map is repeated in the v direction
		if (vRepeat) {
			extendedBumpMapData.copyPixels(bumpMapData, new Rectangle(0, 0, width, 1), new Point(1, height + 1));
			extendedBumpMapData.copyPixels(bumpMapData, new Rectangle(0, height - 1, width, 1), new Point(1, 0));
		} else {
			extendedBumpMapData.copyPixels(bumpMapData, new Rectangle(0, 0, width, 1), new Point(1, 0));
			extendedBumpMapData.copyPixels(bumpMapData, new Rectangle(0, height - 1, width, 1), new Point(1, height + 1));
		}
		// Calculate normals over entire surface
		var i:Float = 0;
		while (i < width) {
			ui = i / (width - 1);
			uim1 = (i - 1) / (width - 1);
			uip1 = (i + 1) / (width - 1);
			var j:Float = 0;
			while (j < height) {
				vi = j / (height - 1);
				vim1 = (j - 1) / (height - 1);
				vip1 = (j + 1) / (height - 1);
				// Get positional vectors for points around position (ui, vi)
				p_uivim1 = getPosition(extendedBumpMapData, i + 1, j, amplitude, ui, vim1, geometryFunction);
				p_uivip1 = getPosition(extendedBumpMapData, i + 1, j + 2, amplitude, ui, vip1, geometryFunction);
				p_uim1vi = getPosition(extendedBumpMapData, i, j + 1, amplitude, uim1, vi, geometryFunction);
				p_uip1vi = getPosition(extendedBumpMapData, i + 2, j + 1, amplitude, uip1, vi, geometryFunction);
				// Calculate normal from positional vectors
				normal = calculateNormal(p_uivip1, p_uivim1, p_uip1vi, p_uim1vi);
				// set the pixel in the normal map data taking into account the coordinate systems
				setNormal(normalMapData, i, j, normal, coordinates);
				
				// update loop variables
				j++;
			}

			
			// update loop variables
			i++;
		}

		return normalMapData;
	}

}
