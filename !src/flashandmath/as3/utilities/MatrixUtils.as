/* ***********************************************************************
The classes in the package
bkde.as3.* were created by

Barbara Kaskosz of the University of Rhode Island
(bkaskosz@math.uri.edu) and
Douglas E. Ensley of Shippensburg University
(DEEnsley@ship.edu).

Feel free to use and modify the classes in the package 
bkde.as3.* to create
your own Flash applications for educational purposes under the
following two conditions:

1) Please include a line acknowledging this work and the authors
with your application in a way that is visible in your compiled file
or on your html page. 

2) If you choose to modify the classes in the package 
bkde.as3.*, put them into a package different from
the original. In this case too, please acknowledge this work
in a way visible to the user.

If you wish to use the materials for commercial purposes, you need our
permission.

This work is supported in part by the National Science Foundation
under the grant DUE-0535327.

Last modified: July 9, 2007
Renamed from bkde to flashandmath on October 31, 2008
************************************************************************ */

package flashandmath.as3.utilities {
	

public class MatrixUtils {
	
	
  public static function MatrixByVector(A:Array, B:Array):Array {
	  
	var C:Array = [];
	
	C[0] = A[0][0]*B[0]+A[0][1]*B[1]+A[0][2]*B[2];
	C[1] = A[1][0]*B[0]+A[1][1]*B[1]+A[1][2]*B[2];
	C[2] = A[2][0]*B[0]+A[2][1]*B[1]+A[2][2]*B[2]; 
	
	return C;
}
	
	
  public static function MatrixByMatrix(A:Array, B:Array):Array {
	
	var C:Array=[];
	
	var i:Number;
	
	for(i=0;i<3;i++){
		
		C[i]=[];
		
	}
	
	C[0][0] = A[0][0]*B[0][0]+A[0][1]*B[1][0]+A[0][2]*B[2][0];
	C[0][1] = A[0][0]*B[0][1]+A[0][1]*B[1][1]+A[0][2]*B[2][1];
	C[0][2] = A[0][0]*B[0][2]+A[0][1]*B[1][2]+A[0][2]*B[2][2];
	C[1][0] = A[1][0]*B[0][0]+A[1][1]*B[1][0]+A[1][2]*B[2][0];
	C[1][1] = A[1][0]*B[0][1]+A[1][1]*B[1][1]+A[1][2]*B[2][1];
	C[1][2] = A[1][0]*B[0][2]+A[1][1]*B[1][2]+A[1][2]*B[2][2];
	C[2][0] = A[2][0]*B[0][0]+A[2][1]*B[1][0]+A[2][2]*B[2][0];
	C[2][1] = A[2][0]*B[0][1]+A[2][1]*B[1][1]+A[2][2]*B[2][1];
	C[2][2] = A[2][0]*B[0][2]+A[2][1]*B[1][2]+A[2][2]*B[2][2];
	
	return C;
	
}


public static function projectPoint(point:Array,flen:Number):Array {
	
	var projection:Array=[];
	
	projection[0]=flen/(flen-point[2])*point[0];
	
	projection[1]=flen/(flen-point[2])*point[1];
	
	return projection;
	
}

public static function rotMatrix(x:Number, y:Number, z:Number, theta:Number):Array {
	
	var axLen:Number;
	
	var T:Array=[];
	
	var radtheta:Number;
	
	var i:Number;
	
	var cosT:Number;
	
	var sinT:Number;
	
	var diffT:Number;
	
	radtheta=Math.PI/180*theta;
	
	axLen = Math.sqrt(x*x+y*y+z*z);
	
	for(i=0;i<3;i++){
		
		T[i]=[];
		
	}
	
	T =[[1,0,0], [0,1,0], [0,0,1]];
	
	if (axLen>.0001) {
		
		x /= axLen;
		y /= axLen;
		z /= axLen;
		
		cosT = Math.cos(radtheta);
		sinT = Math.sin(radtheta);
		diffT = 1-cosT;
		T[0][0] = diffT*x*x+cosT;
		T[0][1] = diffT*x*y-sinT*z;
		T[0][2] = diffT*x*z+sinT*y;
		T[1][0] = diffT*x*y+sinT*z;
		T[1][1] = diffT*y*y+cosT;
		T[1][2] = diffT*y*z-sinT*x;
		T[2][0] = diffT*x*z-sinT*y;
		T[2][1] = diffT*y*z+sinT*x;
		T[2][2] = diffT*z*z+cosT;
			
		
	}
	
	  	return T;
}


		
}

}