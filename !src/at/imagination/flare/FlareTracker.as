/****************************************************************************\
 *
 *  (C) 2009 by Imagination Computer Services GesmbH. All rights reserved.
 *
 *  Project: flare
 *
 *  @author Stefan Hynst
 *
 *  $Id: FlareTracker.as 95 2010-03-25 12:57:05Z imagination\stefan $
 *
\****************************************************************************/


package at.imagination.flare
{
import cmodule.libFlareTracker.CLibInit;

import flash.display.BitmapData;
import flash.display.Stage;
import flash.utils.ByteArray;

// ----------------------------------------------------------------------------

/**
 * FlareTracker is a wrapper class providing convenient methods to use the
 * functions provided by <b>libFlareTracker</b>.<br/> For an example on how to use it see
 * <code>samples/TestTracker</code>.
 */
public class FlareTracker implements IFlareTracker
{
	/**
	 * The FlareTracker.MARKER_UNDEFINED constant defines the value of the markerType
	 * property returned by getTrackerResults() when a marker of an unkown type is found.
	 */
	public static const MARKER_UNDEFINED:int  = 0;

	/**
	 * The FlareTracker.MARKER_SIMPLE_ID constant defines the value of the markerType
	 * property returned by getTrackerResults() when a simple-id marker is found.
	 */
	public static const MARKER_SIMPLE_ID:int = 1;

	/**
	 * The FlareTracker.MARKER_BCH constant defines the value of the markerType
	 * property returned by getTrackerResults() when a BCH marker is found.
	 */
	public static const MARKER_BCH:int = 2;

	/**
	 * The FlareTracker.MARKER_BCH2 constant defines the value of the markerType
	 * property returned by getTrackerResults() when a BCH2 marker is found.
	 */
	public static const MARKER_BCH2:int = 3;

	/**
	 * The FlareTracker.MARKER_FRAME constant defines the value of the markerType
	 * property returned by getTrackerResults() when a frame marker is found.
	 */
	public static const MARKER_FRAME:int = 4;

	/**
	 * The FlareTracker.MARKER_SPLIT constant defines the value of the markerType
	 * property returned by getTrackerResults() when a split marker is found.
	 */
	public static const MARKER_SPLIT:int = 5;

	/**
	 * The FlareTracker.MARKER_DATAMATRIX constant defines the value of the markerType
	 * property returned by getTrackerResults() when a data matrix marker is found.
	 */
	public static const MARKER_DATAMATRIX:int = 6;

	// ------------------------------------------------------------------------

	private var m_CLib:CLibInit;
	private var m_logFunc:Function;
	private var m_fileLoader:FilePreloader;
	private var m_trackerLib:Object;

	private var	m_stage:Stage;
	private var	m_camFile:String;
	private var m_camWidth:uint;
	private var m_camHeight:uint;
	private var m_initDoneCB:Function;

	private var m_alcMemory:ByteArray = null;
	private var m_alcImagePointer:uint;
	private var m_alcTrackerResultPointer:uint;
	private var m_alcTrackerResult2DPointer:uint;

	// ------------------------------------------------------------------------

	/**
	 *  constructor
	 */
	public function FlareTracker()
	{
		m_logFunc     = null;
		m_CLib       = new CLibInit();
		m_trackerLib = m_CLib.init();
	}

	// ------------------------------------------------------------------------

	/**
	 *  Returns the version of flareTracker
	 *
	 *  @return Version number as String formatted as <code>major.minor.build</code>
	 */
	public function getVersion():String
	{
		return (m_trackerLib.getVersion());
	}

	// ------------------------------------------------------------------------
	
	/**
	 *  Sets a logging function: Use this to display logging output from libFlareTracker.
	 *  
	 *  @param obj If the logging function is a method of an object, set this to
	 *  the method's object. Otherwise pass <code>null</code>
	 *
	 *  @param logger The logging function that will be called from libFlareTracker.<br/>
	 *  The function must be of type <code>function(int,&#xA0;String):void</code>
	 *
	 *  @param level Only produce logging output for log-levels &lt;= <code>level</code>
	 */
	public function setLogger(obj:Object, logger:Function, level:uint):void
	{
		m_logFunc = logger;
		m_trackerLib.setLogger(obj, logger, level);
	}

	// ------------------------------------------------------------------------

	/**
	 *  Initializes the tracker. This needs to be called before any other method is called
	 *  (with the exception of <code>getVersion()</code> amd <code>setLogger()</code>)
	 *
	 *  @param stage The application's stage.
	 *
	 *  @param dataPath Path were the datafiles (camera ini-file and license file) are located.
	 *
	 *  @param camFile Name of the camera initalization file.
	 *
	 *  @param camWidth Width of the camera input in pixels.
	 *
	 *  @param camHeight Height of the camera input in pixels.
	 *
	 *  @param initDoneCB Callback function to be invoked, when initialization has
	 *  finished. This is necessary, because all input files will be loaded
	 *  asynchronously before libFlareNFT can initialize the tracker.<br/>
	 *  The function must be of type <code>function():void</code>
	 */
	public function init(stage:Stage,
	                     dataPath:String, camFile:String, camWidth:uint, camHeight:uint,
	                     initDoneCB:Function):void
	{
		m_stage      = stage;
		m_camWidth   = camWidth;
		m_camHeight  = camHeight;
		m_camFile    = camFile;
		m_initDoneCB = initDoneCB;

		if (m_stage != null)
		{
			// get absolute path and replace backslashes with slashes
			var basePath:String = m_stage.loaderInfo.loaderURL.replace(/[\\]/g, "/");
			// cut off query part
			basePath = basePath.slice(0, basePath.indexOf("?"));
			// cut off file name, keep last slash
			basePath = basePath.slice(0, basePath.lastIndexOf("/") + 1);

			// create preloader:
			//   all files needed by libFlareTracker have to be preloaded and passed
			//   to alchemy via m_Clib.supplyFile()
			//
			m_fileLoader = new FilePreloader(fileLoadedCB);
			m_fileLoader.loadStart();
			m_fileLoader.load("flareTracker.lic", basePath);
			m_fileLoader.load(m_camFile         , dataPath);
			m_fileLoader.loadEnd();
		}
	}

	// ------------------------------------------------------------------------

	/**
	 *  Adds a marker detector to the tracker. The following marker types are
	 *  supported: simple&#xA0;id, BCH, BCH2, frame&#xA0;marker, split&#xA0;marker,
	 *  data&#xA0;matrix&#xA0;marker.
	 *  Call this method once for every marker type you want to track for.
	 *
	 *  @param markerType Type of marker to track for. Pass one of the following values:
	 *  <ul>
	 *    <li><code>FlareTracker::MARKER_SIMPLE_ID</code> to detect <b>simple id markers</b>.
	 *      <p>
	 *      <code>param1</code> specifies the border width of the marker -
	 *      more precisely this is the ratio <code>borderWidth/markerWidth</code>.
	 *      If this parameter is not passed, a default value of 0.125 is used.
	 *      </p>
	 * 		<p>
	 *      <code>param2</code> specifies the width of the marker in millimeters.
	 *      If this parameter is not passed, a default value of 80 is used.
	 *      </p>
	 *    </li>
	 *
	 *    <li><code>FlareTracker::MARKER_BCH</code> to detect <b>BCH markers</b>.
	 *      <p>
	 *      <code>param1</code> specifies the border width ratio (defaults to 0.125)
	 * 		</p>
	 *		<p>
	 *      <code>param2</code> specifies the width of the marker in millimeters (defaults to 80)
	 *      </p>
	 *    </li>
	 *
	 *    <li><code>FlareTracker::MARKER_BCH2</code> to detect <b>BCH2 markers</b>.
	 *      <p>
	 *      <code>param1</code> specifies the border width ratio (defaults to 0.1875)
	 *      </p>
	 *		<p>
	 *      <code>param2</code> specifies the width of the marker in millimeters (defaults to 80)
	 *      </p>
	 *    </li>
	 *
	 *    <li><code>FlareTracker::MARKER_FRAME</code> to detect <b>frame markers</b>.
	 *      <p>
	 *      <code>param1</code> specifies the border width ratio (defaults to 0.04545)
	 * 		</p>
	 * 		<p>
	 *      <code>param2</code> specifies the width of the marker in millimeters (defaults to 100)
	 *      </p>
	 *    </li>
	 *
	 *    <li><code>FlareTracker::MARKER_SPLIT</code> to detect <b>split markers</b>.
	 *      <p>
	 *      <code>param1</code> specifies the width of the marker in millimeters (defaults to 61)
	 *      </p>
	 * 		<p>
	 *      <code>param2</code> specifies the height of the marker in millimeters (defaults to 90)
	 *      </p>
	 *    </li>
	 *
	 *    <li><code>FlareTracker::MARKER_DATAMATRIX</code> to detect <b>data matrix markers</b>.
	 *      <p>
	 *      <code>param1</code> specifies the border width ratio (defaults to 0.035)
	 *      </p>
	 * 		<p>
	 *      <code>param2</code> is not used.
	 *      </p>
	 *    </li>
	 *  </ul>
	 * 
	 *  @param param1 The use of this parameter depends on the marker type (see description above).
	 * 
	 *  @param param2 The use of this parameter depends on the marker type (see description above).
	 *
	 *  @return <code>true</code> on success.
	 */
	public function addMarkerDetector(markerType:uint, param1:Number = 0, param2:Number = 0):Boolean
	{
		return m_trackerLib.addMarkerDetector(markerType, param1, param2);
	}

	// ------------------------------------------------------------------------

	/**
	 *  Returns the projection matrix. Since the camera doesn't move during tracking,
	 *  this needs to be called only once after <code>init()</code> to obtain the
	 *  projection matrix. 
	 *
	 *  @return The matrix is retured as a <code>ByteArray</code> containing 4x4 Numbers.
	 *
	 *  @example To set the projection matrix for a camera in
	 *  <a href="http://blog.papervision3d.org/">papervison3D</a>,
	 *  you would do the following:
	 *
	 *  <pre>
	 *    var mat:ByteArray = flareTrackerTracker.getProjectionMatrix();
	 *    var proj:Matrix3D = (_camera as Camera3D).projection;
	 *  &#xA0;
	 *    proj.n11 =  mat.readFloat();
	 *    proj.n21 = -mat.readFloat();
	 *    proj.n31 =  mat.readFloat();
	 *    proj.n41 =  mat.readFloat();
	 *  &#xA0;
	 *    proj.n12 =  mat.readFloat();
	 *    proj.n22 = -mat.readFloat();
	 *    proj.n32 =  mat.readFloat();
	 *    proj.n42 =  mat.readFloat();
	 *  &#xA0;
	 *    proj.n13 =  mat.readFloat();
	 *    proj.n23 = -mat.readFloat();
	 *    proj.n33 =  mat.readFloat();
	 *    proj.n43 =  mat.readFloat();
	 *  &#xA0;
	 *    proj.n14 =  mat.readFloat();
	 *    proj.n24 = -mat.readFloat();
	 *    proj.n34 =  mat.readFloat();
	 *    proj.n44 =  mat.readFloat();
	 *  </pre>
	 *
	 *  Note that the 2nd row is inverted, because we need to convert from a
	 *  right-handed coordinate system (used by flare) to a left-handed
	 *  coordinate system (used by
	 *  <a href="http://blog.papervision3d.org/">papervison3D</a>).
	 */
	public function getProjectionMatrix():ByteArray
	{
		if (! m_alcMemory) return null;

		m_alcMemory.position = m_trackerLib.getProjectionMatrixPtr();
		return m_alcMemory;
	}

	// ------------------------------------------------------------------------

	/**
	 *  This method needs to be called every frame to obtain the tracking results.
	 *  
	 *  @param image The bitmap grabbed from the camera.
	 *
	 *  @return Number of targets found.
	 */
	public function update(image:BitmapData):uint
	{
		if (! m_alcMemory) return 0;

		// write to "alchemy memory"	
		m_alcMemory.position = m_alcImagePointer;
		m_alcMemory.writeBytes(image.getPixels(image.rect));	

		// returns number of targets found
		return (m_trackerLib.update());
	}

	// ------------------------------------------------------------------------

	/**
	 *  Returns the tracking results. Call this method after <code>update()</code>
	 *  found one or more targets.
	 *  
	 *  @return The tracking results are returned as a <code>ByteArray</code> structure
	 *  of the following form:
	 *  <pre>
	 *    markerType:int;          // type of marker, can be one of the following:
	 *                             //   MARKER_SIMPLE_ID
	 *                             //   MARKER_BCH
	 *                             //   MARKER_BCH2
	 *                             //   MARKER_FRAME
	 *                             //   MARKER_SPLIT
	 *                             //   MARKER_DATAMATRIX
	 *    targetID:int;            // unique identifier of the target
	 *  &#xA0;
	 *    poseMatrix_11:Number;    // pose matrix: model view matrix of target in 3D space
	 *    poseMatrix_21:Number;
	 *    poseMatrix_31:Number;
	 *    poseMatrix_41:Number;
	 *  &#xA0;
	 *    poseMatrix_12:Number;
	 *    poseMatrix_22:Number;
	 *    poseMatrix_32:Number;
	 *    poseMatrix_42:Number;
	 *  &#xA0;
	 *    poseMatrix_13:Number;
	 *    poseMatrix_23:Number;
	 *    poseMatrix_33:Number;
	 *    poseMatrix_43:Number;
	 *  &#xA0;
	 *    poseMatrix_14:Number;
	 *    poseMatrix_24:Number;
	 *    poseMatrix_34:Number;
	 *    poseMatrix_44:Number;
	 *  </pre>
	 *  This structure is repeated in the <code>ByteArray</code> for every target found.
	 *
	 *  @example This example shows how the tracker results can be parsed.
	 *  <pre>
	 *    var markerType:int;
	 *    var targetID:int;
	 *    var mat:Matrix3D = new Matrix3D();
	 *    var numTargets:uint = flareTrackerTracker.update(bitmap);
	 *    var targetData:ByteArray = flareTrackerTracker.getTrackerResults();
     *  &#xA0;
	 *    // iterate over all visible targets
	 *    for (var i:uint = 0; i &lt; numTargets; i++)
	 *    {
	 *      markerType = targetData.readInt();
	 *      targetID   = targetData.readInt();
     *  &#xA0;
	 *      // read pose matrix (= model view matrix)
	 *      mat.n11 =  targetData.readFloat();
	 *      mat.n21 = -targetData.readFloat();
	 *      mat.n31 =  targetData.readFloat();
	 *      mat.n41 =  targetData.readFloat();
     *  &#xA0;
	 *      mat.n12 =  targetData.readFloat();
	 *      mat.n22 = -targetData.readFloat();
	 *      mat.n32 =  targetData.readFloat();
	 *      mat.n42 =  targetData.readFloat();
     *  &#xA0;
	 *      mat.n13 =  targetData.readFloat();
	 *      mat.n23 = -targetData.readFloat();
	 *      mat.n33 =  targetData.readFloat();
	 *      mat.n43 =  targetData.readFloat();
     *  &#xA0;
	 *      mat.n14 =  targetData.readFloat();
	 *      mat.n24 = -targetData.readFloat();
	 *      mat.n34 =  targetData.readFloat();
	 *      mat.n44 =  targetData.readFloat();
     *  &#xA0;
	 *      // show target object and apply transformation
	 *      showObject(markerType, targetID, mat);
	 *    }
	 *  </pre>
	 *
	 *  The 2nd row of the pose matrix is inverted to convert from a right-handed
	 *  coordinate system to a left-handed coordinate system.
	 */
	public function getTrackerResults():ByteArray
	{
		if (! m_alcMemory) return null;

		m_alcMemory.position = m_alcTrackerResultPointer;
		return m_alcMemory;
	}

	// ------------------------------------------------------------------------

	/**
	 *  Returns the 2d-tracking results. Call this method after <code>update()</code>
	 *  found one or more targets.
	 *  
	 *  @return The 2d-tracking results are returned as a <code>ByteArray</code> structure
	 *  of the following form:
	 *  <pre>
	 *    markerType:int;      // type of marker, can be one of the following:
	 *                         //   MARKER_SIMPLE_ID
	 *                         //   MARKER_BCH
	 *                         //   MARKER_BCH2
	 *                         //   MARKER_FRAME
	 *                         //   MARKER_SPLIT
	 *                         //   MARKER_DATAMATRIX
	 *    targetID:int;        // unique identifier of the target
	 *  &#xA0;
	 *  &#xA0;                 // corner points of the rectangular marker in image space
	 *    cornerUL_x:Number;   // upper left corner point
	 *    cornerUL_y:Number;
	 *  &#xA0;
	 *    cornerUR_x:Number;   // upper right corner point
	 *    cornerUR_y:Number;
	 *  &#xA0;
	 *    cornerLR_x:Number;   // lower right corner point
	 *    cornerLR_y:Number;
	 *  &#xA0;
	 *    cornerLL_x:Number;   // lower left corner point
	 *    cornerLL_y:Number;
	 *  </pre>
	 *  This structure is repeated in the <code>ByteArray</code> for every target found.
	 *
	 */
	public function getTrackerResults2D():ByteArray
	{
		if (! m_alcMemory) return null;

		m_alcMemory.position = m_alcTrackerResult2DPointer;
		return m_alcMemory;
	}

	// ------------------------------------------------------------------------

	/**
	 *  Returns the message encoded in a data matrix marker.
	 *  Call this method after <code>update()</code> found one or more targets.
	 *
	 *  @param index Retrieves the message for the data matrix marker at position <code>index</code>.
	 *  Where <code>index</code> is smaller than the number of targets returned by
	 *  <code>update()</code>.
	 *
	 *  @return Message encoded in data matrix marker, or <code>null</code>
	 *  if no message is found. <code>null</code> is also returned if
	 *  <code>index</code> doesn't point to a marker of type data matrix.
	 */
	public function getDataMatrixMessage(index:uint):String
	{
		return (m_trackerLib.getDataMatrixMessage(index));
	}

	// ------------------------------------------------------------------------

	private function fileLoadedCB(url:String, data:ByteArray, errMsg:String=null):void
	{
		try
		{
			if (errMsg) throw "ERROR: File \"" + url + "\" load failed: " + errMsg;

			m_CLib.supplyFile(url, data);

			// load targets, after all ini-files have been loaded
			if (m_fileLoader.allFilesLoaded())
			{
				var isOk:Boolean = m_trackerLib.initTracker(m_stage, m_camWidth, m_camHeight, m_camFile);
				if (!isOk) throw "ERROR: initTracker() failed.";

				// retrieve the "alchemy memory"
				var ns : Namespace = new Namespace("cmodule.libFlareTracker");
				m_alcMemory   = (ns::gstate).ds;

				// get offsets to image buffer and tracker-result buffer
				m_alcImagePointer           = m_trackerLib.getImageBufferPtr();		
				m_alcTrackerResultPointer   = m_trackerLib.getTrackerResultPtr();
				m_alcTrackerResult2DPointer = m_trackerLib.getTrackerResult2DPtr();

				m_initDoneCB();		// callback function to indicate that init() is finished
			}
		}
		catch (errStr:*)
		{
			if (m_logFunc != null) m_logFunc(0, String(errStr));
		}
	}

	// ------------------------------------------------------------------------

}

// ----------------------------------------------------------------------------

}

import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.utils.ByteArray;

// ----------------------------------------------------------------------------

// helper class to load files into memory

class FilePreloader
{
	private var m_loadCB:Function;
	private var m_ldrArray:Array;
	private var m_filesToLoad:uint;
	private var m_loadEnd:Boolean;
	
	// ------------------------------------------------------------------------
	
	public function FilePreloader(loadCB:Function)
	{
		m_loadCB = loadCB;
		m_ldrArray = new Array();
		m_filesToLoad = 0;
		m_loadEnd = false;
	}

	// ------------------------------------------------------------------------

	public function load(filename:String, path:String):void
	{
		var url:String = path + "/" + filename;
		try {
			var loader:URLLoader = new URLLoader();
			m_ldrArray.push([loader, filename]);
	
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorCB);
			loader.addEventListener(IOErrorEvent.IO_ERROR, errorCB);
			loader.addEventListener(Event.COMPLETE, dataCB);
			loader.load(new URLRequest(url));
			m_filesToLoad++;
		}
		catch (err:Error) { onError(filename, err.message); }
	}

	// ------------------------------------------------------------------------

	public function loadStart():void	{ m_loadEnd = false; m_filesToLoad = 0; }
	public function loadEnd():void		{ m_loadEnd = true;	}

	public function allFilesLoaded():Boolean
	{
		return (m_loadEnd && (m_filesToLoad == 0));
	}

	// ------------------------------------------------------------------------
	
	private function onLoad(url:String, data:ByteArray):void
	{
		m_filesToLoad--;
		if (m_loadCB != null) m_loadCB(url, data);
	}

	// ------------------------------------------------------------------------

	private function onError(url:String, errMsg:String):void
	{
		if (m_loadCB != null) m_loadCB(url, null, errMsg);
	}

	// ------------------------------------------------------------------------
	
	private function errorCB(event:Event):void
	{
		loadHandler(URLLoader(event.target), event.type);
	}
	
	// ------------------------------------------------------------------------
	
	private function dataCB(event:Event):void
	{
		loadHandler(URLLoader(event.target));
	}
	
	// ------------------------------------------------------------------------
	
	private function loadHandler(loader:URLLoader, errMsg:String = null):void
	{
		for (var i:uint = 0; i < m_ldrArray.length; i++)
		{
			if (m_ldrArray[i][0] == loader)
			{
				var url:String = m_ldrArray[i][1];
				if (errMsg == null)	onLoad (url, loader.data);
				else                onError(url, errMsg);

				m_ldrArray.splice(i, 1);		// removes element at index i
				return;
			}
		}
		// should never get here
		onError("", "FilePreloader: load error!");
	}

	// ------------------------------------------------------------------------
	
}
