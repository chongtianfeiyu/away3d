﻿package away3d.sprites{    import away3d.containers.*;    import away3d.core.*;    import away3d.core.base.*;    import away3d.core.draw.*;    import away3d.core.render.*;    import away3d.core.utils.*;        import flash.display.DisplayObject;		/**	 * Spherical billboard (always facing the camera) sprite object that uses a movieclip as it's texture.	 * Draws individual display objects inline with z-sorted triangles in a scene.	 */    public class MovieClipSprite extends Object3D implements IPrimitiveProvider    {        private var _center:Vertex = new Vertex();		private var _sc:ScreenVertex;		private var _persp:Number;		private var _ddo:DrawDisplayObject;				/**		 * Defines the displayobject to use for the sprite texture.		 */        public var movieclip:DisplayObject;                /**        * Defines the overall scaling of the sprite object        */        public var scaling:Number;                /**        * An optional offset value added to the z depth used to sort the sprite        */        public var deltaZ:Number;                /**        * Defines whether the sprite should scale with distance from the camera. Defaults to false        */		public var rescale:Boolean;    			/**		 * Creates a new <code>MovieClipSprite</code> object.		 * 		 * @param	movieclip			The displayobject to use as the sprite texture.		 * @param	init	[optional]	An initialisation object for specifying default instance properties.		 */        public function MovieClipSprite(movieclip:DisplayObject, init:Object = null)        {            super(init);            this.movieclip = movieclip;            scaling = ini.getNumber("scaling", 1);            deltaZ = ini.getNumber("deltaZ", 0);			rescale = ini.getBoolean("rescale", false);        }        		/**		 * @inheritDoc    	 *     	 * @see	away3d.core.traverse.PrimitiveTraverser    	 * @see	away3d.core.draw.DrawDisplayObject		 */        override public function primitives(view:View3D, consumer:IPrimitiveConsumer):void        {        	super.primitives(view, consumer);        				_sc = consumer.createScreenVertex(this);			            _center.project(_sc, projection);            _persp = projection.zoom / (1 + _sc.z / projection.focus);            _sc.z += deltaZ;            _sc.x -= movieclip.width/2;            _sc.y -= movieclip.height/2;			 			if(rescale)				movieclip.scaleX = movieclip.scaleY = _persp*scaling;						_ddo = consumer.createDrawDisplayObject(view, session, movieclip, _sc);			            consumer.primitive(_ddo);        }    }}