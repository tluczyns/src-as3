package base.tf {
	import base.types.Singleton;
	import base.types.ArrayExt;

	public class HtmlTextUtils extends Singleton {
		
		static public function setTextWontFlowImage(strHtml: String, fontSize:uint = 10): String {
			strHtml = strHtml.replace(/<br>[\t ]*((<\/[^>]*>)*<img)/gsi, '$1');
			strHtml = strHtml.replace(/(<img[^>]+>(<\/[^>]*>)*)[\t ]*<br>/gsi, '$1');
			
			var currImgHeight:Number;
			while (strHtml.match(/<img[^>]*height=.[0-9]+.[^>]*>/si)) {
				// get the height from the current image
				currImgHeight = parseInt(strHtml.replace(/^.*?<img[^>]*height=.([0-9]+).[^>]*>.*$/si, "$1"));
				strHtml = strHtml.replace(/<(img[^>]*height=.[0-9]+.[^>]*>)/si, '<br><textformat leading="'+Math.ceil(currImgHeight-fontSize)+'"><xXxX$1<br></textformat>');
			}
			// now un-rename the <xXxXimg tags
			strHtml = strHtml.replace(/<xXxXimg/gi, "<img");
			if (strHtml.match(/<br><\/textformat>(<[^>]+>)*$/)) strHtml += ' ';
			return strHtml;
		}
		
		static public function setVHSpaceForImgTags(strHtml: String, spaceVH: uint = 2): String {
			strHtml = strHtml.replace(new RegExp("(<img[^>]*)hspace=.[0-9]+.", "gsi"), '$1');
			strHtml = strHtml.replace(new RegExp("(<img[^>]*)vspace=.[0-9]+.", "gsi"), '$1');
			strHtml = strHtml.replace(new RegExp("<img", "gi"), '<img vspace="' + String(spaceVH) + '" hspace="' + String(spaceVH) + '"');	
			return strHtml;
		}
		
	}

}