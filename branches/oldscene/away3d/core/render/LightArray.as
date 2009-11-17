package away3d.core.render
{
    import away3d.core.*;
    import away3d.core.proto.*;
    import away3d.core.draw.*;
    import away3d.core.math.*;
    import away3d.core.render.*;
    import flash.geom.*;
	
	/** Array of light sources */
    public class LightArray implements ILightConsumer
    {
        private var ambients:Array = [];
        private var directed:Array = [];
        public var points:Array = [];

        public function ambientLight(color:int, ambient:Number):void
        {
            throw new Error("Not implemented");
        }

        public function directedLight(direction:Number3D, color:int, diffuse:Number):void
        {
            throw new Error("Not implemented");
        }

        public function pointLight(projection:Projection, color:int, ambient:Number, diffuse:Number, specular:Number):void
        {
        	var source:Matrix3D = projection.view;
            var point:PointLightSource = new PointLightSource();
            point.x = source.n14;
            point.y = source.n24;
            point.z = source.n34;
            point.red = (color & 0xFF0000) >> 16;
            point.green = (color & 0xFF00) >> 8;
            point.blue  = (color & 0xFF);
            point.ambient = ambient;
            point.diffuse = diffuse;
            point.specular = specular;
            points.push(point);
        }
    }
}
