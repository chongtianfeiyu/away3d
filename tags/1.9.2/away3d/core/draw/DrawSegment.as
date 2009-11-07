package away3d.core.draw
{
    import away3d.core.*;
    import away3d.core.material.*;
    import away3d.core.mesh.*;
    import away3d.core.render.*;
    import away3d.core.scene.*;

    /** Line segment drawing primitive */
    public class DrawSegment extends DrawPrimitive
    {
        public var v0:ScreenVertex;
        public var v1:ScreenVertex;

        public var length:Number;

        public var material:ISegmentMaterial;
		
        public override function clear():void
        {
            v0 = null;
            v1 = null;
        }

        public override function render():void
        {
            material.renderSegment(this);
        }

        public override function contains(x:Number, y:Number):Boolean
        {   
            if (Math.abs(v0.x*(y - v1.y) + v1.x*(v0.y - y) + x*(v1.y - v0.y)) > 0.001*1000*1000)
                return false;

            if (distanceToCenter(x, y)*2 > length)
                return false;

            return true;
        }

        public override function riddle(another:DrawTriangle, focus:Number):Array
        {
            if (another.minZ > maxZ)
                return null;
            if (another.maxZ < minZ)
                return null;
            if (another.minX > maxX)
                return null;
            if (another.maxX < minX)
                return null;
            if (another.minY > maxY)
                return null;
            if (another.maxY < minY)
                return null;

            var av0z:Number = another.v0.z;
            var av0p:Number = 1 + av0z / focus;
            var av0x:Number = another.v0.x * av0p;
            var av0y:Number = another.v0.y * av0p;

            var av1z:Number = another.v1.z;
            var av1p:Number = 1 + av1z / focus;
            var av1x:Number = another.v1.x * av1p;
            var av1y:Number = another.v1.y * av1p;

            var av2z:Number = another.v2.z;
            var av2p:Number = 1 + av2z / focus;
            var av2x:Number = another.v2.x * av2p;
            var av2y:Number = another.v2.y * av2p;

            //var ap:Plane3D = Plane3D.from3points(av0, av1, av2);
                                      
            var ad1x:Number = av1x - av0x;
            var ad1y:Number = av1y - av0y;
            var ad1z:Number = av1z - av0z;

            var ad2x:Number = av2x - av0x;
            var ad2y:Number = av2y - av0y;
            var ad2z:Number = av2z - av0z;

            var apa:Number = ad1y*ad2z - ad1z*ad2y;
            var apb:Number = ad1z*ad2x - ad1x*ad2z;
            var apc:Number = ad1x*ad2y - ad1y*ad2x;
            var apd:Number = - (apa*av0x + apb*av0y + apc*av0z);

            if (apa*apa + apb*apb + apc*apc < 1)
                return null;

            var tv0z:Number = v0.z;
            var tv0p:Number = 1 + tv0z / focus;
            var tv0x:Number = v0.x * tv0p;
            var tv0y:Number = v0.y * tv0p;

            var tv1z:Number = v1.z;
            var tv1p:Number = 1 + tv1z / focus;
            var tv1x:Number = v1.x * tv1p;
            var tv1y:Number = v1.y * tv1p;

            var sv0:Number = apa*tv0x + apb*tv0y + apc*tv0z + apd;
            var sv1:Number = apa*tv1x + apb*tv1y + apc*tv1z + apd;

            if (sv0*sv1 >= 0)                                           
                return null;

            //var tv0:Vertex = v0.deperspective(focus);
            //var tv1:Vertex = v1.deperspective(focus);

            var d:Number = sv1 - sv0;
            var k0:Number = sv1 / d;
            var k1:Number = -sv0 / d;

            var tv01z:Number = (tv0z*k0 + tv1z*k1);
            var tv01p:Number = 1 / (1 + tv01z /  focus);
            var tv01x:Number = (tv0x*k0 + tv1x*k1) * tv01p;
            var tv01y:Number = (tv0y*k0 + tv1y*k1) * tv01p;

            if (!another.contains(tv01x, tv01y))
                return null;

            var v01:ScreenVertex = new ScreenVertex(tv01x, tv01y, tv01z);

            return [create(material, projection, v0, v01), create(material, projection, v01, v1)];
        }

        public override function getZ(x:Number, y:Number):Number
        {
            if (projection == null)
                return screenZ;

            var focus:Number = projection.focus;
              
            var ax:Number = v0.x;
            var ay:Number = v0.y;
            var az:Number = v0.z;
            var bx:Number = v1.x;
            var by:Number = v1.y;
            var bz:Number = v1.z;

            if ((ax == x) && (ay == y))
                return az;

            if ((bx == x) && (by == y))
                return bz;

            var dx:Number = bx - ax;
            var dy:Number = by - ay;

            var azf:Number = az / focus;
            var bzf:Number = bz / focus;

            var faz:Number = 1 + azf;
            var fbz:Number = 1 + bzf;

            var xfocus:Number = x;
            var yfocus:Number = y;

            var axf:Number = ax*faz - x*azf;
            var bxf:Number = bx*fbz - x*bzf;
            var ayf:Number = ay*faz - y*azf;
            var byf:Number = by*fbz - y*bzf;

            var det:Number = dx*(axf - bxf) + dy*(ayf - byf);
            var db:Number = dx*(axf - x) + dy*(ayf - y);
            var da:Number = dx*(x - bxf) + dy*(y - byf);

            return (da*az + db*bz) / det;
        }

        public override function quarter(focus:Number):Array
        {
            if (length < 5)
                return null;

            var v01:ScreenVertex = ScreenVertex.median(v0, v1, focus);

            return [create(material, projection, v0, v01), create(material, projection, v01, v1)];
        }

        public function distanceToCenter(x:Number, y:Number):Number
        {   
            var centerx:Number = (v0.x + v1.x) / 2;
            var centery:Number = (v0.y + v1.y) / 2;

            return Math.sqrt((centerx-x)*(centerx-x) + (centery-y)*(centery-y));
        }

        public function calc():void
        {
        	if (v0.z < v1.z) {
        		minZ = v0.z;
        		maxZ = v1.z + 1;
        	} else {
        		minZ = v1.z;
        		maxZ = v0.z + 1;
        	}
            screenZ = (v0.z + v1.z) / 2;
            
            if (v0.x < v1.x) {
        		minX = v0.x;
        		maxX = v1.x + 1;
        	} else {
        		minX = v1.x;
        		maxX = v0.x + 1;
        	}
        	
        	if (v0.y < v1.y) {
        		minY = v0.y;
        		maxY = v1.y + 1;
        	} else {
        		minY = v1.y;
        		maxY = v0.y + 1;
        	}
            
            length = Math.sqrt((maxX - minX)*(maxX - minX) + (maxY - minY)*(maxY - minY));
        }

        public override function toString():String
        {
            return "S{ screenZ = " + screenZ + ", minZ = " + minZ + ", maxZ = " + maxZ + " }";
        }
    }
}