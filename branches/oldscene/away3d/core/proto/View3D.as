package away3d.core.proto
{
    import away3d.core.*;
    import away3d.core.draw.*;
    import away3d.core.proto.*;
    import away3d.core.geom.*;
    import away3d.core.render.*;
    import away3d.core.material.*;
    
    import flash.display.Sprite;
    import flash.utils.getTimer;
    import flash.utils.Dictionary;
    import flash.events.MouseEvent;
    import flash.events.Event;

    /** Repesent the drawing surface for the scene, that can be used to render 3D graphics */ 
    public class View3D extends Sprite
    {
        /** Background under the rendered scene */
        public var background:Sprite;
        /** Sprite that contains last rendered frame */
        public var canvas:Sprite;
        /** Head up display over the scene */
        public var hud:Sprite;

        /** Scene to be rendered */
        public var scene:Scene3D;
        /** Camera to render from */
        public var camera:Camera3D;
        /** Clipping area for the view */
        public var clip:Clipping;
        /** Renderer that is used for rendering <br> @see away3d.core.render.Renderer */
        public var renderer:IRenderer;

        /** Object for subscribing to events */
        public var events:Object3DEvents;

        /** Create new View3D */
        public function View3D(scene:Scene3D = null, camera:Camera3D = null, renderer:IRenderer = null)
        {
            this.scene = scene || new Scene3D();
            this.camera = camera || new Camera3D({x:1000, y:1000, z:1000, lookat:new Object3D()});
            this.renderer = renderer || new BasicRenderer();
            
            events = new Object3DEvents();

            background = new Sprite();
            addChild(background);
            canvas = new Sprite();
            addChild(canvas);
            hud = new Sprite();
            addChild(hud);
            
            addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
            addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
            addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
            mouseChildren = false;
        }

        /** Clear rendering area */
        public function clear():void
        {
            if (canvas != null)
                removeChild(canvas);

            canvas = new Sprite();
            addChildAt(canvas, 1);
        }

        /** Render frame */
        public function render():void
        {
            Init.checkUnusedArguments();

            clear();

            var oldclip:Clipping = clip;

            clip = clip || Clipping.screen(this);

            renderer.render(this);

            clip = oldclip;

            fireMouseMoveEvent();
        }

        protected var mousedown:Boolean;

        protected function onMouseDown(e:MouseEvent):void
        {
            mousedown = true;
            fireMouseEvent(MouseEvent.MOUSE_DOWN, e.localX, e.localY, e.ctrlKey, e.shiftKey);
        }

        private function onMouseUp(e:MouseEvent):void
        {
            mousedown = false;
            fireMouseEvent(MouseEvent.MOUSE_UP, e.localX, e.localY, e.ctrlKey, e.shiftKey);
        }

        private function onMouseOut(e:MouseEvent):void
        {
            if (mousedown)
            {
                mousedown = false;
                fireMouseEvent(MouseEvent.MOUSE_UP, e.localX, e.localY, e.ctrlKey, e.shiftKey);
            }
        }

        /** Manually fire mouse move event */
        public function fireMouseMoveEvent():void
        {
            fireMouseEvent(MouseEvent.MOUSE_MOVE, mouseX, mouseY);
        }

        /** Manually fire custom mouse event */
        public function fireMouseEvent(type:String, x:Number, y:Number, ctrlKey:Boolean = false, shiftKey:Boolean = false):void
        {
            var findhit:FindHitTraverser = new FindHitTraverser(this, x, y);
            scene.traverse(findhit);
            var event:MouseEvent3D = findhit.getMouseEvent(type);
            event.ctrlKey = ctrlKey;
            event.shiftKey = shiftKey;

            events.dispatchEvent(event);

            var target:Object3D = event.object;
            while (target != null)
            {
                if (target.hasEvents)
                    target.events.dispatchEvent(event);
                target = target.parent;
            }
        }

        public function screen(object:Object3D, vertex:Vertex3D = null):Vertex2D
        {
            if (vertex == null)
                vertex = new Vertex3D(0,0,0);

            // return vertex.project(new Projection(Matrix3D.multiply(getView(), object.relative()), focus, zoom));
            return vertex.project(new Projection(this, object.relative()));
        }

        /*
        public function findHit(x:Number, y:Number):Object3D
        {
            var callback:OldFindHitCallback = new OldFindHitCallback(x, y, 0);
            renderCamera(camera, callback);
            return callback;
        }

        public function findNearest(x:Number, y:Number):Object3D
        {
            var callback:OldFindHitCallback = new OldFindHitCallback(x, y);
            renderCamera(camera, callback);
            return callback;
        }
        */
    }
}