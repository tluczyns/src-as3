package baseStarling.gallery {
	

	public class DescriptionRowMultiGallery extends Object {
		
		public var classRow: Class;
		
		public function DescriptionRowMultiGallery(classRow: Class): void {
			if (!(classRow is RowMultiGallery))
			this.classRow = classRow;
			
		}
		
	}

}