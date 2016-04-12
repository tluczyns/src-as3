//
// Simplesphere.as - Path animation of a simple sphere.
//
// copyright (c) 2007, Jim Armstrong.  All Rights Reserved.  
//
// This software program is supplied 'as is' without any warranty, express, implied, 
// or otherwise, including without limitation all warranties of merchantability or fitness
// for a particular purpose.  Jim Armstrong shall not be liable for any special incidental, or 
// consequential damages, including, without limitation, lost revenues, lost profits, or 
// loss of prospective economic advantage, resulting from the use or misuse of this software 
// program.
//
// programmed by Jim Armstrong, Singularity (www.algorithmist.net)
//
//

package org.papervision3d.examples
{
  // flash
  import flash.display.Sprite;
  import flash.display.Stage;
  import flash.events.Event;

  // Papervision
  import org.papervision3d.cameras.Camera3D;
  import org.papervision3d.materials.ColorMaterial;
  import org.papervision3d.objects.DisplayObject3D;
  import org.papervision3d.objects.Sphere;
  import org.papervision3d.objects.Cube;
  import org.papervision3d.scenes.Scene3D;
	
  // Singularity
  import Singularity.Events.SingularityEvent;
  import Singularity.Events.Dispatcher;
  
  import Singularity.Numeric.Consts;
  import Singularity.Geom.P3D.CatmullRom;

  public class SimpleSphere
  {
  	// core
  	private var __pv3dSprite:Sprite;        // main container for P3D Scene
    private var __camera:Camera3D;          // target camera for the scene
    private var __scene:Scene3D;            // our very simple scene :)
    private var __rootNode:DisplayObject3D; // root node of the scene
    
    // path animation
    private var __myObject:DisplayObject3D; // this is the object that animates
    private var __s:Number;                 // global parameter (arc length) value
    private var __deltaS:Number;            // increment in arc length per frame
    private var __spline:CatmullRom;        // spline used for path animation
    
    // dispatcher implemented via composition (something different for a change)
    private var __dispatcher:Dispatcher;
    private var __complete:SingularityEvent;
 
    public function SimpleSphere(_pv3dSprite:Sprite)
    {
      __pv3dSprite = _pv3dSprite;

	  __dispatcher = new Dispatcher();
	  
	  __spline              = new CatmullRom();
	  __spline.closed       = false;
	  __spline.parameterize = Consts.ARC_LENGTH;  // Arc-length parameterization for unifom velocity along the 3D curve
	  
	  __deltaS = 0.025;
	  __complete = new SingularityEvent(SingularityEvent.COMPLETE);
	  __complete.classname = "SimpleSphere";
    }

    public function setupScene(_knots:Array):void
    {
      __scene = new Scene3D(__pv3dSprite);

      __camera       = new Camera3D();
	  __camera.x     = 1000;
	  __camera.y     = 1000;
	  __camera.z     = 1400;
	  __camera.zoom  = 10;
	  __camera.focus = 100;

      // this is about a simple as it gets :)
      var sphereMaterial:ColorMaterial = new ColorMaterial( 0x0000ff );
      var knotMaterial:ColorMaterial   = new ColorMaterial( 0xff0000 );
      var animMaterial:ColorMaterial   = new ColorMaterial( 0x00ff00 );
	  var xAxisMaterial:ColorMaterial  = new ColorMaterial( 0xff9900 );
      var yAxisMaterial:ColorMaterial  = new ColorMaterial( 0x6699cc );
      var zAxisMaterial:ColorMaterial  = new ColorMaterial( 0xffffff );
			
      var sphere:Sphere = new Sphere( sphereMaterial, 50, 24, 24 );
      __rootNode = __scene.addChild( sphere, "root" );
			
      // display 'axes'
      var xAxis:Cube  = new Cube(xAxisMaterial, 1000, 5, 5);
      xAxis.rotationY = 90;
						
      var yAxis:Cube  = new Cube(yAxisMaterial, 1000, 5, 5);
      yAxis.rotationX = 90;
			
      var zAxis:Cube  = new Cube(zAxisMaterial, 1000, 5, 5);
			
      __scene.addChild(xAxis, "xAxis");
      __scene.addChild(yAxis, "yAxis");
      __scene.addChild(zAxis, "zAxis");

      // cubes function as 'markers' to indicate knot placement in 3D space
      for( var i:uint=0; i<_knots.length; ++i )
      {
        var cube:Cube = new Cube(knotMaterial,20,20,20);
        cube.x        = _knots[i].X;
        cube.y        = _knots[i].Y;
        cube.z        = _knots[i].Z;
        __scene.addChild(cube, "Cube"+i.toString());
      }
			
      __myObject = new Sphere( animMaterial, 20, 16, 16 );
      __myObject.x = _knots[0].X;
      __myObject.y = _knots[0].Y;
      __myObject.z = _knots[0].Z;
      __scene.addChild(__myObject, "AnimObject");
      
      __setupPath(_knots);
      
      __camera.target = sphere;
	  __scene.renderCamera(__camera);
    }
    
    public function addEventListener(_type:String, _listener:Function):void 
    {
      __dispatcher.addEventListener(_type, _listener);
    }

    public function removeEventListener(_type:String, _listener:Function):void 
    {
      __dispatcher.removeEventListener(_type, _listener);
    }
    
    public function animate():void
	{
	  var s:Stage = __pv3dSprite.stage;
	  __s         = 0;
	  
      s.addEventListener( Event.ENTER_FRAME, __onPathAnimate);
	}
	
	private function __setupPath(_knots:Array):void
	{
	  // note - no error handler for spline in this demo
	  for( var i:uint=0; i<_knots.length; ++i )
	  {
	  	var k:Object = _knots[i];
	    __spline.addControlPoint(k.X, k.Y, k.Z);  // add spline control points
	  }
	}
	
	private function __onPathAnimate(_e:Event):void
	{
      // increment arc length and sample the spline to move the green sphere
	  __s         += __deltaS;
	  __myObject.x = __spline.getX(__s);
	  __myObject.y = __spline.getY(__s);
	  __myObject.z = __spline.getZ(__s);
	  
	  __scene.renderCamera(__camera);
	  
	  if( __s >= 1.0 )
	  {
	    __complete.methodname = "__onPathAnimate()";
	    __complete.message    = "Animation complete";
	    __dispatcher.dispatchEvent(__complete);
	  }
	}
  }
}
