package base.types {
    public dynamic class ArrayExt extends Array {

        public function ArrayExt(...args) {
	        var n:uint = args.length
	        if (n == 1 && (args[0] is Number))  {
	            var dlen:Number = args[0];
	            var ulen:uint = dlen
	            if (ulen != dlen)  {
	                throw new RangeError("Array index is not a 32-bit unsigned integer ("+dlen+")")
	            }
	            length = ulen;
	        } else {
	            for (var i:int=0; i < n; i++) {
	                // type check done in push() 
	                this.push(args[i])
	            }
	            length = this.length;
	        }
	    }
		
		public function isInArray(element: *): Boolean {
            var isInArray: Boolean = false;
    	    var i: uint = 0;
        	while ((i < this.length) && (!isInArray)) {
        		if (this[i] == element) {
        			isInArray = true;
        		}
        		i++;
        	}
        	return isInArray;
        }
    
        public function isPropertyValueInArray(propertyName: String, propertyValue: *): Boolean {
        	var isPropertyValueInArray: Boolean = false
        	var i: uint = 0;
        	while ((i < this.length) && (!isPropertyValueInArray)) {
        		if (this[i][propertyName] == propertyValue) {
        			isPropertyValueInArray = true;
        		}
        		i++;
        	}
        	return isPropertyValueInArray;
        }
    
        public function copyIn(sourceArray: Array): void {
            for (var i: uint = 0; i < sourceArray.length; i++) {
        		this.push(sourceArray[i]);
        	}  
        }
    
		public function remove(element: * ): Boolean {
			return ArrayExt.remove(this, element);
		}
		
        static public function remove(arr: Array, element: *): Boolean {
        	var isRemoved: Boolean = false;
        	var i: uint = 0;
        	while ((i < arr.length) && (!isRemoved)) {
        		if (arr[i] == element) {
        			arr.splice(i, 1);
        			isRemoved = true;
        		}
        		i++;
        	}
        	return isRemoved;
        }
		
		public function removeByProperty(propertyName: String, propertyValue: * ): Boolean {
			return ArrayExt.removeByProperty(this, propertyName, propertyValue);
		}
		
        static public function removeByProperty(arr: Array, propertyName: String, propertyValue: *): Boolean {
        	var isRemoved: Boolean = false;
        	var i: uint = 0;
        	while ((i < arr.length) && (!isRemoved)) {
        		if (arr[i][propertyName] == propertyValue) {
        			arr.splice(i, 1);
        			isRemoved = true;
        		}
        		i++;
        	}
        	return isRemoved;
        }
		
        public function getElementIndex(element: *): int {
        	var elementIndex: int = -1;
        	var i: uint = 0;
        	while ((i < this.length) && (elementIndex == -1)) {
        		if (this[i] == element) {
        			elementIndex = i;
        		}
        		i++;
        	}
        	return elementIndex;
        }
		
		public function getElementArrIndex(element: *): Array {
        	var elementArrIndex: Array = [];
        	var i: uint = 0;
        	while (i < this.length) {
        		if (this[i] == element) {
        			elementArrIndex.push(i);
        		}
        		i++;
        	}
        	return elementArrIndex;
        }
		
		static public function getElementIndexByProperty(arr: Array, propertyName: String, propertyValue: *): int {
        	var elementIndex: int = -1;
        	var i: uint = 0;
			var arrPropertyName: Array = [];
			if (propertyName.length) arrPropertyName = propertyName.split(".");
        	while ((i < arr.length) && (elementIndex == -1)) {
				var propertyValueInArr: * = arr[i];
				for (var j: uint = 0; j < arrPropertyName.length; j++) propertyValueInArr = propertyValueInArr[arrPropertyName[j]];
        		if (propertyValueInArr == propertyValue) elementIndex = i;
        		i++;
        	}
        	return elementIndex;
        }
		
		public function getElementIndexByProperty(propertyName: String, propertyValue: * ): int {
			return ArrayExt.getElementIndexByProperty(this, propertyName, propertyValue);
		}
		
		static public function getElementArrIndexByProperty(arr: Array, propertyName: String, propertyValue: *): Array {
        	var elementArrIndex: Array = [];
        	var i: uint = 0;
			var arrPropertyName: Array = [];
			if (propertyName.length) arrPropertyName = propertyName.split(".");
        	while (i < arr.length) {
				var propertyValueInArr: * = arr[i];
				for (var j: uint = 0; j < arrPropertyName.length; j++) propertyValueInArr = propertyValueInArr[arrPropertyName[j]];
        		if (propertyValueInArr == propertyValue) elementArrIndex.push(i);
        		i++;
        	}
        	return elementArrIndex;
        }
		
		public function getElementArrIndexByProperty(propertyName: String, propertyValue: * ): Array {
			return ArrayExt.getElementArrIndexByProperty(this, propertyName, propertyValue);
		}
		
		public function move(indexFrom: uint, indexTo: uint): void {
			var elementMoved: * = this.splice(indexFrom, 1);
			this.splice(indexTo, 0, elementMoved);
		}
		
		static public function generateRandomIndexArray(length: uint): ArrayExt {
			var arrRandomIndex: ArrayExt = new ArrayExt();
			for (var i: uint = 0; i < length; i++) {
				var index: uint;
				do {
					index = Math.floor(Math.random() * length);
				} while (arrRandomIndex.isInArray(index));
				arrRandomIndex.push(index);
			}
			return arrRandomIndex;
		}
		
		public function generateRandomIndexArray(): ArrayExt {
			return ArrayExt.generateRandomIndexArray(this.length);
		}
		
		static public function generateRandomMixedArray(arrToMix: Array): Array {
			var arrInd: ArrayExt = ArrayExt.generateRandomIndexArray(arrToMix.length);
			var arrMix: ArrayExt = new ArrayExt(arrToMix.length);
			for (var i: uint = 0; i < arrToMix.length; i++)
				arrMix[i] = arrToMix[arrInd[i]];
			return arrMix;
		}
		
		public function generateRandomMixedArray(): Array {
			return ArrayExt.generateRandomMixedArray(this);
		}
		
		public function concatUnique(arrToConcat: Array): Array {
			return ArrayExt.concatUnique(this, arrToConcat);
		}
		
		static public function concatUnique(arrToConcat1: Array, arrToConcat2: Array, isNewArray: Boolean = true): Array {
			if (isNewArray) arrToConcat1 = arrToConcat1.concat();
			for (var i: uint = 0; i < arrToConcat2.length; i++) if (arrToConcat1.indexOf(arrToConcat2[i]) == -1) arrToConcat1.push(arrToConcat2[i]);
			return arrToConcat1;
		}
		
		public function compareElements(arrToCompare: Array, isComparedMayBeLonger: Boolean = false): Boolean {
			if ((arrToCompare.length == this.length) || ((isComparedMayBeLonger) && (arrToCompare.length > this.length))) {
				var i: uint = 0;
				while ((i < this.length) && (this[i] == arrToCompare[i])) i++;
				return Boolean(i == this.length);
			} else return false
			
		}
		
    }
}