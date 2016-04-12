//
// Figure8.as - Path animation around a 3d figure 8 (Lemniscate of Bernoulli in a plane).
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
  import org.papervision3d.objects.Cube;
  import org.papervision3d.scenes.Scene3D;
	
  // Singularity
  import Singularity.Events.SingularityEvent;
  import Singularity.Events.Dispatcher;
  
  import Singularity.Numeric.Consts;
  import Singularity.Geom.P3D.CatmullRom;
  import Singularity.Geom.P3D.Composite;

  public class Figure8
  {
  	// core
  	private var __plane:String;             // denote plane of figure-8 (XY, XZ, or YZ)
  	
    // path animation
    private var __markers:Array;            // array of animated markers
    private var __controlPoints:Array;      // array of control points
    private var __s:Array;                  // arc length value for each marker
    private var __deltaS:Number;            // increment in arc length per frame
    private var __spline:CatmullRom;        // spline used for path animation
    private var __r:Number;                 // radius
    
    private var __finished:Boolean;         // true if animation finished across all markers
    private var __counter:Number;           // marker counter
    
    // dispatcher implemented via composition (something different for a change)
    private var __dispatcher:Dispatcher;
    private var __complete:SingularityEvent;
 
    public function Figure8(_plane:String)
    {
      if( _plane == Composite.XY || _plane == Composite.XZ || _plane == Composite.YZ )
        __plane = _plane;
      else
        __plane = Composite.XY;
      
	  __dispatcher = new Dispatcher();
	  
	  __markers       = new Array();
	  __controlPoints = new Array();
	  __s             = new Array();
	  
	  __spline              = new CatmullRom();
	  __spline.closed       = true;
	  __spline.parameterize = Consts.ARC_LENGTH;  // Arc-length parameterization for unifom velocity along the 3D curve
	  
	  __deltaS   = 0.025;
	  __counter  = 0;
	  __complete = new SingularityEvent(SingularityEvent.COMPLETE);
	  __complete.classname = "Figure8";
    }
    
    // define figure-8 control points in the specified plane and add markers to scene (call *only* once)
    public function addToScene(_xC:Number, _yC:Number, _a:Number, _scene:Scene3D, _material:ColorMaterial):void
    {
      // _xC and _yC are the 'center' coordinates in the specified plane (zero for this demo)
      var asQ:Number = _a*_a;
      
      // principal range [0,pi/4]
      __controlPoints[0] = {X:_xC+_a, Y:_yC};
      	
      var theta:Number = Math.PI/16;
      __r              = Math.sqrt(asQ*Math.cos(2*theta));
      var x:Number     = _xC + __r*Math.cos(theta);
      var y:Number     = _yC + __r*Math.sin(theta);
      	
      __controlPoints[1] = {X:x, Y:y};
      	
      theta = Math.PI/6;
      __r   = Math.sqrt(asQ*Math.cos(2*theta));
      x     = _xC + __r*Math.cos(theta);
      y     = _yC + __r*Math.sin(theta);
      	
      __controlPoints[2] = {X:x, Y:y};
        
      theta = Math.PI/4.5;
      __r   = Math.sqrt(asQ*Math.cos(2*theta));
      x     = _xC + __r*Math.cos(theta);
      y     = _yC + __r*Math.sin(theta);
      	
      __controlPoints[3] = {X:x, Y:y};   	
      __controlPoints[4] = {X:_xC, Y:_yC};
        
      // generate remaining markers from principal set
      var p:Object       = __controlPoints[3];
      __controlPoints[5] = {X:2*_xC - p.X, Y:2*_yC - p.Y};
        
      p                  = __controlPoints[2];
      __controlPoints[6] = {X:2*_xC - p.X, Y:2*_yC - p.Y};
        
      p                  = __controlPoints[1];
      __controlPoints[7] = {X:2*_xC - p.X, Y:2*_yC - p.Y};
      	
      __controlPoints[8] = {X:_xC - _a, Y:_yC};
     	
      p                  = __controlPoints[7];
      __controlPoints[9] = {X:p.X, Y:2*_yC - p.Y};
      	
      p                   = __controlPoints[6];
      __controlPoints[10] = {X:p.X, Y:2*_yC - p.Y};
      	
      p                   = __controlPoints[5];
      __controlPoints[11] = {X:p.X, Y:2*_yC - p.Y};
      	
      __controlPoints[12] = {X:_xC, Y:_yC};
      	
      p                   = __controlPoints[3];
      __controlPoints[13] = {X:p.X, Y:2*_yC - p.Y};
      	
      p                   = __controlPoints[2];
      __controlPoints[14] = {X:p.X, Y:2*_yC - p.Y};
      	
	  p                   = __controlPoints[1];
      __controlPoints[15] = {X:p.X, Y:2*_yC - p.Y};
      
      // assign control points based on specified plane (XY, XZ, YZ)
      switch( __plane )
      {
        case Composite.XY :
          for( var i:uint=0; i<16; ++i )
          {
            p = __controlPoints[i];
            __spline.addControlPoint(p.X, p.Y, 0);
          }
        break;
        
        case Composite.XZ :
          for( i=0; i<16; ++i )
          {
            p = __controlPoints[i];
            __spline.addControlPoint(p.X, 0, p.Y);
          }
        break;
        
        case Composite.YZ :
          for( i=0; i<16; ++i )
          {
            p = __controlPoints[i];
            __spline.addControlPoint(0, p.X, p.Y);
          }
        break;
      }
      
      // add ten markers to the scene, all initially placed at the same point
      var initX:Number = __spline.getX(0);
      var initY:Number = __spline.getY(0);
      var initZ:Number = __spline.getZ(0);
      
      for( i=0; i<10; ++i )
      {
        var cube:Cube = new Cube(_material,20,20,20);
        cube.x        = initX;
        cube.y        = initY;
        cube.z        = initZ;
        __markers[i]  = cube;
        _scene.addChild(cube, "Cube"+__plane+i.toString());
      }
    }
    
    public function addEventListener(_type:String, _listener:Function):void 
    {
      __dispatcher.addEventListener(_type, _listener);
    }

    public function removeEventListener(_type:String, _listener:Function):void 
    {
      __dispatcher.removeEventListener(_type, _listener);
    }
    
    public function initAnimation():void
	{
	  var initX:Number = __spline.getX(0);
      var initY:Number = __spline.getY(0);
      var initZ:Number = __spline.getZ(0);
      
	  for( var i:uint=0; i<10; ++i )
      {
        __s[i]      = 0;
      	  
        var c:Cube  = __markers[i];
      	c.x         = initX;
      	c.y         = initY;
      	c.z         = initZ;
      	c.visible   = true;
      } 
      	
      __counter  = 0;
      __finished = false;
	}
	
	public function updateAnimation():void
    {
      if( __finished )
        return;
        
      if( __counter < 10 )
      {
        // prime the pump - use this loop to control the initial placement and alpha out of the starting point.
      	for( var i:uint=0; i<=__counter; ++i )
      	{
      	  var c:Cube   = __markers[i];
      	  var s:Number = __s[i];
      	  s           += __deltaS;
          c.x          = __spline.getX(s);
          c.y          = __spline.getY(s);
          c.z          = __spline.getZ(s);
            
          __s[i] = s;
        }
          
        __counter++;
      }
      else
      {
        // complete the motion here.  Lots of flexibility to experiment or even merge the two paths if you desire
        for( i=0; i<10; ++i )
        {
          c = __markers[i];
      	  s = __s[i];
      	  if( s <= 1 )
      	  {
      	    s   += __deltaS;
            c.x  = __spline.getX(s);
            c.y  = __spline.getY(s);
            c.z  = __spline.getZ(s);
            
            __s[i] = s;
          }
          else
          {
            c.visible = false;
              
            // last marker finished?
            if( i == 9 )
            {
              __finished = true;
              __complete.methodname = "__pathAnimate()";
	          __complete.message    = "Animation complete";
	          __dispatcher.dispatchEvent(__complete);
            }
          }
        }
      }
    }
    
  }
}
