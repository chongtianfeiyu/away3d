package away3d.primitives
{
	import away3d.core.base.Mesh;
	import away3d.core.base.Shape3D;
	import away3d.core.project.ShapeProjector;
	import away3d.materials.ColorMaterial;
	import away3d.materials.IShapeMaterial;
	
	public class Sprite3D extends Mesh
	{
		private var _extrudeMaterial:IShapeMaterial;
		
		public function Sprite3D(init:Object)
		{
			init.projector = new ShapeProjector(this);
			
			super(init);
			
			extrudeMaterial = IShapeMaterial(ini.getMaterial("extrudeMaterial")); 
		}
		
		public function set extrudeMaterial(value:IShapeMaterial):void
		{
			_extrudeMaterial = value;
		}
		
		public function extrude(value:Number):void
		{
			var i:uint;
			var j:uint;
			var aX:Number = 0;
			var aY:Number = 0;
			var bX:Number = 0;
			var bY:Number = 0;
			var currentVertex:uint = 0;
			var memX:Number = 0;
			var memY:Number = 0;
			var lastX:Number = 0;
			var lastY:Number = 0;
			var addQueue:Array = [];
			var shape:Shape3D;
			var instruction:uint;
			for(i = 0; i<shapes.length; i++)
			{
				shape = shapes[i];
				currentVertex = 0;
				for(j = 0; j<shape.drawingCommands.length; j++)
				{
					instruction = shape.drawingCommands[j];
					if(instruction == 0)
					{
						memX = shape.vertices[currentVertex].x;
						memY = shape.vertices[currentVertex].y;
						currentVertex++;
					}
					else
					{
						var extShp:Shape3D = new Shape3D();
						extShp.layerOffset = this.layerOffset + value;
						
						if(_extrudeMaterial == null)
							extShp.material = new ColorMaterial(0x000000);
						else
							extShp.material = _extrudeMaterial; 
						
						extShp.graphicsMoveTo(memX, memY, 0);
						extShp.graphicsLineTo(memX, memY, value);
						
						aX = shape.vertices[currentVertex].x;
						aY = shape.vertices[currentVertex].y;
						lastX = aX;
						lastY = aY;
						currentVertex++;
						
						switch(instruction)
						{	
							case 1:
								extShp.graphicsLineTo(aX, aY, value);
								break;
							case 2:
								bX = shape.vertices[currentVertex].x;
								bY = shape.vertices[currentVertex].y;
								lastX = bX;
								lastY = bY;
								currentVertex++;
								extShp.graphicsCurveTo(aX, aY, value, bX, bY, value);  
								break;
						}
						
						extShp.graphicsLineTo(lastX, lastY, 0);
						
						switch(instruction)
						{	
							case 1:
								extShp.graphicsLineTo(aX, aY, 0);
								break;
							case 2:
								extShp.graphicsCurveTo(aX, aY, 0, memX, memY, 0);  
								break;
						}
						
						memX = lastX;
						memY = lastY;
						
						addQueue.push(extShp);
					}
				}
			}
			
			for(i = 0; i<addQueue.length; i++)
				addChild(addQueue[i]);
		}
		
		public function addChild(shp:Shape3D):void
		{
			addShape(shp);
		}
		
		public function removeChild(shp:Shape3D):void
		{
			removeShape(shp);
		}
	}
}