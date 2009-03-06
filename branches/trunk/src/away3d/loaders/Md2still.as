package away3d.loaders
{
    import away3d.arcane;
    import away3d.core.base.*;
    import away3d.core.utils.*;
    
    import flash.utils.*;

	use namespace arcane;
	
    /**
    * File loader for the Md2 file format (non-animated version).
    * 
    * @author Philippe Ajoux (philippe.ajoux@gmail.com)
    */
    public class Md2still extends AbstractParser
    {
    	private var ini:Init;
        private var ident:int;
        private var version:int;
        private var skinwidth:int;
        private var skinheight:int;
        private var framesize:int;
        private var num_skins:int;
        private var num_vertices:int;
        private var num_st:int;
        private var num_tris:int;
        private var num_glcmds:int;
        private var num_frames:int;
        private var offset_skins:int;
        private var offset_st:int;
        private var offset_tris:int;
        private var offset_frames:int;
        private var offset_glcmds:int;
        private var offset_end:int;
        private var mesh:Mesh;
        private var scaling:Number;
    
        private function parseMd2still(data:ByteArray):void
        {
            data.endian = Endian.LITTLE_ENDIAN;

            var vertices:Array = [];
            var uvs:Array = [];
            
            ident = data.readInt();
            version = data.readInt();

            // Make sure it is valid MD2 file
            if (ident != 844121161 || version != 8)
                throw new Error("Error loading MD2 file: Not a valid MD2 file/bad version");
                
            skinwidth = data.readInt();
            skinheight = data.readInt();
            framesize = data.readInt();
            num_skins = data.readInt();
            num_vertices = data.readInt();
            num_st = data.readInt();
            num_tris = data.readInt();
            num_glcmds = data.readInt();
            num_frames = data.readInt();
            offset_skins = data.readInt();
            offset_st = data.readInt();
            offset_tris = data.readInt();
            offset_frames = data.readInt();
            offset_glcmds = data.readInt();
            offset_end = data.readInt();

            var i:int;
            // Vertice setup
            //      Be sure to allocate memory for the vertices to the object
            //      These vertices will be updated each frame with the proper coordinates
            for (i = 0; i < num_vertices; i++)
                vertices.push(new Vertex());

            // UV coordinates
            data.position = offset_st;
            for (i = 0; i < num_st; i++)
                uvs.push(new UV(data.readShort() / skinwidth, 1 - ( data.readShort() / skinheight) ));

            // Faces
            data.position = offset_tris;
            for (i = 0; i < num_tris; i++)
            {
                var a:int = data.readUnsignedShort();
                var b:int = data.readUnsignedShort();
                var c:int = data.readUnsignedShort();
                var ta:int = data.readUnsignedShort();
                var tb:int = data.readUnsignedShort();
                var tc:int = data.readUnsignedShort();
                
                mesh.addFace(new Face(vertices[a], vertices[b], vertices[c], null, uvs[ta], uvs[tb], uvs[tc]));
            }
            
            // Frame animation data
            //      This part is a little funky.
            data.position = offset_frames;
            readFrames(data, vertices, num_frames);
            
            mesh.type = ".Md2";
        }
        
        private function readFrames(data:ByteArray, vertices:Array, num_frames:int):void
        {
            for (var i:int = 0; i < num_frames; i++)
            {
                var frame:Object = {name:""};
                
                var sx:Number = data.readFloat();
                var sy:Number = data.readFloat();
                var sz:Number = data.readFloat();
                
                var tx:Number = data.readFloat();
                var ty:Number = data.readFloat();
                var tz:Number = data.readFloat();

                for (var j:int = 0; j < 16; j++)
                {
                    var char:int = data.readUnsignedByte();
                    if (char != 0)
                        frame.name += String.fromCharCode(char);
                }
                
                for (var h:int = 0; h < vertices.length; h++)
                {
                    vertices[h].x = -((sx * data.readUnsignedByte()) + tx) * scaling;
                    vertices[h].z = ((sy * data.readUnsignedByte()) + ty) * scaling;
                    vertices[h].y = ((sz * data.readUnsignedByte()) + tz) * scaling;
                    data.readUnsignedByte(); // "vertex normal index"
                }
                break; // only 1st frame for now
            }
        }
        
		/**
		 * Creates a new <code>Md2Still</code> object. Not intended for direct use, use the static <code>parse</code> or <code>load</code> methods.
		 * 
		 * @param	data				The binary data of a loaded file.
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 * 
		 * @see away3d.loaders.Md2Still#parse()
		 * @see away3d.loaders.Md2Still#load()
		 */
        public function Md2still(data:*, init:Object = null)
        {
            ini = Init.parse(init);

            scaling = ini.getNumber("scaling", 1) * 100;

            mesh = (container = new Mesh(ini)) as Mesh;

            parseMd2still(Cast.bytearray(data));
        }

		/**
		 * Creates a 3d mesh object from the raw xml data of an md2 file.
		 * 
		 * @param	data				The binary data of a loaded file.
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 * 
		 * @return						A 3d mesh object representation of the md2 file.
		 */
        public static function parse(data:*, init:Object = null):Mesh
        {
            return Object3DLoader.parseGeometry(data, Md2still, init).handle as Mesh;
        }
    	
    	/**
    	 * Loads and parses an md2 file into a 3d mesh object.
    	 * 
    	 * @param	url					The url location of the file to load.
    	 * @param	init	[optional]	An initialisation object for specifying default instance properties.
    	 * @return						A 3d loader object that can be used as a placeholder in a scene while the file is loading.
    	 */
        public static function load(url:String, init:Object = null):Object3DLoader
        {
            return Object3DLoader.loadGeometry(url, Md2still, true, init);
        }
    }
}