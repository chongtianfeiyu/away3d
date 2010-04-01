package
{
	import away3dlite.loaders.OBJ;
	import away3dlite.lights.Light;
	import away3dlite.materials.shaders.PBBitmapShader;
	import away3dlite.primitives.Sphere;
	import away3dlite.templates.BasicTemplate;

	import flash.display.Bitmap;

	[SWF(backgroundColor="#000000", frameRate="30", width="800", height="600")]
	/**
	 * ExSphereNormalMapTest
	 * @author kris@neuroproductions.be
	 */
	public class ExSphereNormalMap extends BasicTemplate
	{
		[Embed(source="assets/stars.jpg")]
		private var BackgroundMap:Class;


		[Embed(source="assets/Earth2.jpg")]
		private var DiffMap:Class;

		[Embed(source="assets/normalmap.jpg")]
		private var NormalMap:Class;

		[Embed(source="assets/moon.jpg")]
		private var DiffMap2:Class;

		[Embed(source="assets/MoonNormal.jpg")]
		private var NormalMap2:Class;

		private var sphere:OBJ;

		private var step:Number = 0;
		private var light:Light;

		private var dfBack:Bitmap

		override protected function onInit():void
		{
			title += " : Light, not optimize yet ;p";

			// prep bitmapdata
			var dfBm:Bitmap = new DiffMap() as Bitmap;
			var normBm:Bitmap = new NormalMap() as Bitmap;

			var dfBm2:Bitmap = new DiffMap2() as Bitmap;
			var normBm2:Bitmap = new NormalMap2() as Bitmap;

			dfBack = new BackgroundMap() as Bitmap;
			dfBack.alpha = 0.5
			addChildAt(dfBack, 0)

			var segment:uint = 20;

			light = new Light();
			light.x = 0;
			light.y = 0;

			var mat2:PBBitmapShader = new PBBitmapShader(light, dfBm.bitmapData.clone(), normBm.bitmapData.clone());

			sphere = new OBJ("assets/25_SPHERE.obj", mat2, 1);
			scene.addChild(sphere);
			var mat:PBBitmapShader = new PBBitmapShader(light, dfBm2.bitmapData.clone(), normBm2.bitmapData.clone());
			mat.drawSprite.x = 400;
			this.addChild(mat.drawSprite);

			scene.addChild(light);
		}

		override protected function onPreRender():void
		{
			dfBack.x = (-dfBack.width / 2 + stage.stageWidth / 2)
			dfBack.y = (-dfBack.height / 2 + stage.stageHeight / 2)
			sphere.rotationY += 5;
			light.x = Math.cos(step * 5) * 150;
			light.y = Math.sin(step * 5) * 150;

			step += 0.03;

			camera.rotationY = (mouseX - stage.stageWidth / 2) / 100;
			camera.rotationX = -(mouseY - stage.stageHeight / 2) / 100;
		}
	}
}