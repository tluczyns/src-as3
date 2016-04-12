package nape.geom {
	import nape.phys.BodyType;
	import nape.phys.Body;
	import nape.shape.Polygon;
	import flash.display.DisplayObjectContainer;
	
	public class IsoBody {

		public static function run(iso:IsoFunction, bodyType: BodyType, bounds:AABB, parent: DisplayObjectContainer = null, granularity:Vec2 = null, quality:int = 2, simplification:Number = 1.5): Body {
			// Flash requires an object to be on stage for hitTestPoint used
            // by the iso-function to work correctly. SIGH.
			var wasAddedToParent: Boolean = false;
			if ((iso is DisplayObjectIso) && (parent) && (!parent.contains(DisplayObjectIso(iso).displayObject))) {
				wasAddedToParent = true;
				parent.addChild(DisplayObjectIso(iso).displayObject);
			}
			var body:Body = new Body(bodyType);
			if (granularity==null) granularity = Vec2.weak(8, 8);
			var polys:GeomPolyList = MarchingSquares.run(iso, bounds, granularity, quality);
			for (var i:int = 0; i < polys.length; i++) {
				var p:GeomPoly = polys.at(i);
				var qolys:GeomPolyList = p.simplify(simplification).convexDecomposition(true);
				for (var j:int = 0; j < qolys.length; j++) {
					var q: GeomPoly = qolys.at(j);
					body.shapes.add(new Polygon(q));
					// Recycle GeomPoly and its vertices
					q.dispose();
				}
				// Recycle list nodes
				qolys.clear();
				// Recycle GeomPoly and its vertices
				p.dispose();
			}
			// Recycle list nodes
			polys.clear();
			
			if (wasAddedToParent) parent.removeChild(DisplayObjectIso(iso).displayObject);
			return body;
		}
		
	}
	
}