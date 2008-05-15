package away3d.core.base
{
    import away3d.core.*;
    import away3d.materials.*;
    import away3d.core.math.*;
    import away3d.core.base.*;
    
    import flash.geom.Matrix;
    import flash.events.Event;
    import flash.utils.*;
	
	/**
	 * Holds information about a sequence of animation frames.
	 */
    public class AnimationSequence
    {
    	/**
    	 * The prefix string defining frames in the sequence.
    	 */
        public var prefix:String;
        
        /**
        * Determines if the animation should be smoothed (interpolated) between frames.
        */
        public var smooth:Boolean;
        
        /**
        * Determines whether the animation sequence should loop.
        */
        public var loop:Boolean;
    	
        /**
        * Determines the speed of playback in frames per second.
        */
        public var fps:uint;
        
		/**
		 * Creates a new <code>AnimationSequence</code> object.
		 * 
		 * @param	prefix		The prefix string defining frames in the sequence.
		 * @param	smooth		Determines if the animation should be smoothed (interpolated) between frames.
		 * @param	loop		Determines whether the animation sequence should loop.
		 * @param	fps			Determines the speed of playback in frames per second.
		 */
        public function AnimationSequence(prefix:String, smooth:Boolean = false, loop:Boolean = false, fps:uint = 24)
        {
            this.prefix = prefix;
            this.smooth = smooth;
            this.loop = loop;
            this.fps = fps;
        }
    }
}
