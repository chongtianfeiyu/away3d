package away3d.test;

import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFormat;


/**
 * Simple rounded rectangle button
 */
class Button extends SimpleButton  {
	
	public var selected:Bool;
	

	public function new(text:String, ?pwidth:Int=80, ?pheight:Int=20) {
		// autogenerated
		super();
		this.selected = false;
		
		OPPOSITE_OR[X | X] = N;
		OPPOSITE_OR[XY | X] = Y;
		OPPOSITE_OR[XZ | X] = Z;
		OPPOSITE_OR[XYZ | X] = YZ;
		OPPOSITE_OR[Y | Y] = N;
		OPPOSITE_OR[XY | Y] = X;
		OPPOSITE_OR[XYZ | Y] = XZ;
		OPPOSITE_OR[YZ | Y] = Z;
		OPPOSITE_OR[Z | Z] = N;
		OPPOSITE_OR[XZ | Z] = X;
		OPPOSITE_OR[XYZ | Z] = XY;
		OPPOSITE_OR[YZ | Z] = Y;
		SCALINGS[1] = [1, 1, 1];
		SCALINGS[2] = [-1, 1, 1];
		SCALINGS[4] = [-1, 1, -1];
		SCALINGS[8] = [1, 1, -1];
		SCALINGS[16] = [1, -1, 1];
		SCALINGS[32] = [-1, -1, 1];
		SCALINGS[64] = [-1, -1, -1];
		SCALINGS[128] = [1, -1, -1];
		
		upState = Type.createInstance(ButtonState, []);
		overState = Type.createInstance(ButtonState, []);
		downState = Type.createInstance(ButtonState, []);
		hitTestState = Type.createInstance(ButtonState, []);
	}

}

