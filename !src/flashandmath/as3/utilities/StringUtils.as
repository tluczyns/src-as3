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

Last modified: July 28, 2007
Renamed from bkde to flashandmath on October 31, 2008
************************************************************************ */

package flashandmath.as3.utilities {
	

public class StringUtils {
	
	
	public static function isBlankText(s:String):Boolean {
		
		var k:int;
		
		for(k=0;k<s.length;k++){
			
			if(s.charAt(k)!=" "){
				
				return false;
				
			} 		
			
		}
		
		return true;
		
	}
	
	
	public static function removeSpaces(inputstring:String):String {

      var curpos:int;
	  
	  var transtring:String;
	  
	  var inilen:int;
	  
	  var counter:int=0;
   
      inilen=inputstring.length;
   
      transtring=inputstring.toLowerCase();
   
   while(transtring.indexOf(" ")>-1 && counter < inilen+1){
	   
	 curpos=transtring.indexOf(" ");
	 
	 transtring=transtring.substring(0,curpos) + 
	 transtring.substring(curpos+1,transtring.length);
	   
	 counter+=1;
	
   }

   return transtring;
		
}


}

}