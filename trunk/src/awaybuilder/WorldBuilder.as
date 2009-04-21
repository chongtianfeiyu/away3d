package awaybuilder{	import away3d.containers.View3D;		import awaybuilder.abstracts.AbstractBuilder;	import awaybuilder.abstracts.AbstractCameraController;	import awaybuilder.abstracts.AbstractGeometryController;	import awaybuilder.abstracts.AbstractParser;	import awaybuilder.camera.AnimationControl;	import awaybuilder.camera.CameraController;	import awaybuilder.camera.CameraFocus;	import awaybuilder.camera.CameraZoom;	import awaybuilder.collada.ColladaParser;	import awaybuilder.events.CameraEvent;	import awaybuilder.events.GeometryEvent;	import awaybuilder.events.SceneEvent;	import awaybuilder.events.WorldBuilderEvent;	import awaybuilder.geometry.GeometryController;	import awaybuilder.interfaces.IAssetContainer;	import awaybuilder.interfaces.ICameraController;	import awaybuilder.interfaces.ISceneContainer;	import awaybuilder.parsers.Cinema4DParser;	//import awaybuilder.parsers.MaxParser;	import awaybuilder.parsers.SceneXMLParser;	import awaybuilder.utils.CoordinateCopy;	import awaybuilder.vo.SceneCameraVO;	import awaybuilder.vo.SceneGeometryVO;	import awaybuilder.vo.SceneSectionVO;		import flash.display.BitmapData;	import flash.display.DisplayObject;	import flash.display.Sprite;	import flash.events.Event;				public class WorldBuilder extends Sprite implements IAssetContainer , ISceneContainer , ICameraController	{		public var source : String = SceneSource.MAYA ;		public var data : * ;		public var precision : uint ;		public var startCamera : String ;		public var update : String = SceneUpdate.CONTINUOUS ;		public var cameraZoom : Number ;		public var cameraFocus : Number ;		public var animationControl : String = AnimationControl.INTERNAL ;		public var autoBuild : Boolean = true ;				protected var builder : AbstractBuilder ;		protected var cameraController : AbstractCameraController ;		protected var geometryController : AbstractGeometryController ;		protected var _parser : AbstractParser ;		protected var _view : View3D ;						public function WorldBuilder ( )		{			this.builder = new SceneBuilder ( ) ;			this.addEventListener ( Event.ADDED_TO_STAGE , this.onAddedToDisplayList ) ;		}								////////////////////////////////////////////////////////////////////////////////		//		// Public Methods		//		////////////////////////////////////////////////////////////////////////////////								public function build ( ) : void		{			this.createView ( ) ;			this.createParser ( ) ;			this.parser.parse ( this.data ) ;		}								public function continueBuild ( ) : void		{			this.setupBuilder ( ) ;		}								public function addBitmapDataAsset ( id : String , data : BitmapData ) : void		{			this.builder.addBitmapDataAsset ( id , data ) ;		}						public function addDisplayObjectAsset ( id : String , data : DisplayObject ) : void		{			this.builder.addDisplayObjectAsset ( id , data ) ;		}						public function addColladaAsset ( id : String , data : XML ) : void		{			this.builder.addColladaAsset ( id , data ) ;		}								public function getCameras ( ) : Array		{			return this.builder.getCameras ( ) ;		}						public function getGeometry ( ) : Array		{			return this.builder.getGeometry ( ) ;		}						public function getSections ( ) : Array		{			return this.builder.getSections ( ) ;		}						public function getCameraById ( id : String ) : SceneCameraVO		{			return this.builder.getCameraById ( id ) ;		}						public function getGeometryById ( id : String ) : SceneGeometryVO		{			return this.builder.getGeometryById ( id ) ;		}								public function getSectionById ( id : String ) : SceneSectionVO		{			return this.builder.getSectionById ( id ) ;		}						public function navigateTo ( vo : SceneCameraVO ) : void		{			this.cameraController.navigateTo ( vo ) ;		}								public function teleportTo ( vo : SceneCameraVO ) : void		{			this.cameraController.teleportTo ( vo ) ;		}								////////////////////////////////////////////////////////////////////////////////		//		// Protected Methods		//		////////////////////////////////////////////////////////////////////////////////								protected function createView ( ) : void		{			this._view = new View3D ( ) ;			this.addChild ( this._view ) ;		}								protected function createParser ( ) : void		{			switch ( this.source )			{				case SceneSource.CINEMA4D :				{					this._parser = new Cinema4DParser ( ) ;					break ;				}				/*				case SceneSource.MAX :				{					this._parser = new MaxParser ( ) ;					break ;				}				*/				case SceneSource.MAYA :				{					this._parser = new ColladaParser ( ) ;					break ;				}				case SceneSource.NATIVE :				{					this._parser = new SceneXMLParser ( ) ;					break ;				}			}						this.parser.addEventListener ( Event.COMPLETE , this.onParsingComplete ) ;		}								protected function setupCamera ( ) : void		{			switch ( this.source )			{				case SceneSource.CINEMA4D :				//case SceneSource.MAX :				case SceneSource.MAYA :				{					if ( ! this.cameraFocus ) this.cameraFocus = CameraFocus.MAYA ;					if ( ! this.cameraZoom ) this.cameraZoom = CameraZoom.MAYA_W720_H502 ;					break ;				}				case SceneSource.NATIVE :				{					if ( ! this.cameraFocus ) this.cameraFocus = CameraFocus.DEFAULT ;					if ( ! this.cameraZoom ) this.cameraZoom = CameraZoom.DEFAULT ;					break ;				}			}						this.worldView.camera.zoom = this.cameraZoom ;			this.worldView.camera.focus = this.cameraFocus ;						if ( this.startCamera )			{				var vo : SceneCameraVO = this.builder.getCameraById ( this.startCamera ) ;								CoordinateCopy.position ( vo.camera , this.worldView.camera ) ;				CoordinateCopy.rotation ( vo.camera , this.worldView.camera ) ;			}		}								protected function setupBuilder ( ) : void		{			var builder : SceneBuilder = this.builder as SceneBuilder ;						switch ( this.source )			{				case SceneSource.CINEMA4D :				{					builder.coordinateSystem = CoordinateSystem.CINEMA4D ;					if ( ! this.precision ) this.precision = ScenePrecision.RAW ;					break ;				}				/*				case SceneSource.MAX :				{					builder.coordinateSystem = CoordinateSystem.MAX ;					if ( ! this.precision ) this.precision = ScenePrecision.RAW ;					break ;				}				*/				case SceneSource.MAYA :				{					builder.coordinateSystem = CoordinateSystem.MAYA ;					if ( ! this.precision ) this.precision = ScenePrecision.PERFECT ;					break ;				}				case SceneSource.NATIVE :				{					builder.coordinateSystem = CoordinateSystem.NATIVE ;					if ( ! this.precision ) this.precision = ScenePrecision.RAW ;					break ;				}			}						builder.precision = this.precision ;			builder.addEventListener ( SceneEvent.RENDER , this.render ) ;			builder.addEventListener ( Event.COMPLETE , this.onBuildingComplete ) ;			builder.addEventListener ( GeometryEvent.COLLADA_COMPLETE , this.onGeometryEvent ) ;			builder.build ( this.worldView , this.parser.sections ) ;		}								protected function createCameraController ( ) : void		{			this.cameraController = new CameraController ( this.worldView.camera ) ;			this.cameraController.update = this.update ;			this.cameraController.animationControl = this.animationControl ;						if ( this.startCamera )			{				var startCamera : SceneCameraVO = this.builder.getCameraById ( this.startCamera ) ;								this.cameraController.startCamera = startCamera ;				this.cameraController.teleportTo ( startCamera ) ;			}						this.cameraController.addEventListener ( SceneEvent.RENDER , this.render ) ;			this.cameraController.addEventListener ( CameraEvent.ANIMATION_START , this.onCameraEvent ) ;			this.cameraController.addEventListener ( CameraEvent.ANIMATION_COMPLETE , this.onCameraEvent ) ;		}								protected function createGeometryController ( ) : void		{			this.geometryController = new GeometryController ( this.builder.getGeometry ( ) ) ;			this.geometryController.addEventListener ( GeometryEvent.DOWN , this.onGeometryEvent ) ;			this.geometryController.addEventListener ( GeometryEvent.MOVE , this.onGeometryEvent ) ;			this.geometryController.addEventListener ( GeometryEvent.OUT , this.onGeometryEvent ) ;			this.geometryController.addEventListener ( GeometryEvent.OVER , this.onGeometryEvent ) ;			this.geometryController.addEventListener ( GeometryEvent.UP , this.onGeometryEvent ) ;			this.geometryController.enableInteraction ( ) ;		}								protected function setupSceneUpdate ( ) : void		{			switch ( this.update )			{				/* NOTE: Render events dispatched by the camera controller.				case SceneUpdate.ON_CAMERA_UPDATE :				*/				case SceneUpdate.CONTINUOUS :				{					this.addEventListener ( Event.ENTER_FRAME , this.render ) ;					break ;				}			}		}								protected function render ( event : Event = null ) : void		{			switch ( this.update )			{				/* NOTE: Render events handled externally.				case SceneUpdate.MANUAL :				*/				case SceneUpdate.CONTINUOUS :				case SceneUpdate.ON_CAMERA_UPDATE :				{					this.worldView.render ( ) ;					break ;				}			}						this.dispatchEvent ( new SceneEvent ( SceneEvent.RENDER ) ) ;		}								////////////////////////////////////////////////////////////////////////////////		//		// Event Handlers		//		////////////////////////////////////////////////////////////////////////////////								protected function onAddedToDisplayList ( event : Event ) : void		{			this.removeEventListener ( Event.ADDED_TO_STAGE , this.onAddedToDisplayList ) ;			this.visible = false ;		}						protected function onParsingComplete ( event : Event ) : void		{			this.dispatchEvent ( new WorldBuilderEvent ( WorldBuilderEvent.PARSER_COMPLETE ) ) ;			if ( this.autoBuild ) this.setupBuilder ( ) ;		}						protected function onBuildingComplete ( event : Event ) : void		{			this.setupCamera ( ) ;			this.createCameraController ( ) ;			this.createGeometryController ( ) ;			this.setupSceneUpdate ( ) ;			this.render ( ) ;						this.visible = true ;			this.dispatchEvent ( new Event ( Event.COMPLETE ) ) ;		}						protected function onGeometryEvent ( event : GeometryEvent ) : void		{			var type : String = event.type ;			var geometry : SceneGeometryVO = event.data as SceneGeometryVO ;			var geometryEvent : GeometryEvent = new GeometryEvent ( type ) ;						switch ( type )			{				case GeometryEvent.UP :				{					if ( geometry.targetCamera ) this.cameraController.navigateTo ( this.builder.getCameraById ( geometry.targetCamera ) ) ;					break ;				}				case GeometryEvent.COLLADA_COMPLETE :				{					this.geometryController.enableGeometryInteraction ( geometry ) ;					this.render ( ) ;					break ;				}			}						geometryEvent.data = geometry ;			this.dispatchEvent ( geometryEvent ) ;		}								protected function onCameraEvent ( event : CameraEvent ) : void		{			var cameraEvent : CameraEvent = new CameraEvent ( event.type ) ;						cameraEvent.targetCamera = event.targetCamera ;			this.dispatchEvent ( cameraEvent ) ;		}								////////////////////////////////////////////////////////////////////////////////		//		// Getters and Setters		//		////////////////////////////////////////////////////////////////////////////////								public function get worldView ( ) : View3D		{			return this._view ;		}								public function get parser ( ) : AbstractParser		{			return this._parser ;		}	}}