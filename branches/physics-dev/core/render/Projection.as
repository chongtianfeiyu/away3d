package away3d.core.render
{
    import away3d.core.*;
    import away3d.core.math.*;

    public class Projection
    {
		public var view:Matrix3D;
        public var focus:Number;
        public var zoom:Number;

        public function Projection(view:Matrix3D, focus:Number, zoom:Number)
        {
            this.view = view;
            this.focus = focus;
            this.zoom = zoom;
        }
    }
}