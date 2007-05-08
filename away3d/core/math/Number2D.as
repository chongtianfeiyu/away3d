package away3d.core.math
{
    //The Number3D class represents a value in a three-dimensional coordinate system.
    public class Number2D
    {
        //The horizontal coordinate value.
        public var x:Number;
    
        //The vertical coordinate value.
        public var y:Number;
    
        public function Number2D(x:Number = 0, y:Number = 0)
        {
            this.x = x;
            this.y = y;
        }
    
        public function clone():Number2D
        {
            return new Number2D(x, y);
        }
    
        public function get modulo():Number
        {
            return Math.sqrt(x*x + y*y);
        }
    
    	public static function scale( v:Number2D, s:Number ):Number2D
		{
			return new Number2D
			(
				v.x * s,
				v.y * s
			);
		}  
		
        public static function add(v:Number3D, w:Number3D):Number2D
        {
            return new Number2D
            (
                v.x + w.x,
                v.y + w.y
           );
        }
    
        public static function sub(v:Number2D, w:Number2D):Number2D
        {
            return new Number2D
            (
                v.x - w.x,
                v.y - w.y
           );
        }
    
        public static function dot(v:Number2D, w:Number2D):Number
        {
            return (v.x * w.x + v.y * w.y);
        }
    /*
        public static function cross(v:Number2D, w:Number2D):Number2D
        {
            return new Number2D
            (
                (w.y * v.z) - (w.z * v.y),
                (w.z * v.x) - (w.x * v.z)
           );
        }
    */
        public function normalize():void
        {
            var mod:Number = modulo;
    
            if (mod != 0 && mod != 1)
            {
                this.x /= mod;
                this.y /= mod;
            }
        }
    /*
        public function rotate(m:Matrix):Number2D
        {
            var x:Number = this.x;
            var y:Number = this.y;
            var z:Number = this.z;
            var v:Number3D = new Number3D(
                    x * m.n11 + y * m.n12 + z * m.n13,
                    x * m.n21 + y * m.n22 + z * m.n23,
                    x * m.n31 + y * m.n32 + z * m.n33);
            v.normalize();
            return v;
        }
        */
        // Relative directions.
        public static var LEFT    :Number2D = new Number2D(-1,  0);
        public static var RIGHT   :Number2D = new Number2D( 1,  0);
        public static var UP      :Number2D = new Number2D( 0,  1);
        public static var DOWN    :Number2D = new Number2D( 0, -1);
    
        public function toString(): String
        {
            return 'x:' + x + ' y:' + y;
        }
    }
}