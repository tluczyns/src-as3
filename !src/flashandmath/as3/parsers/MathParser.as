/* ***********************************************************************
   The classes in the package
   flashandmath.as3.* were created by

   Barbara Kaskosz of the University of Rhode Island
   (bkaskosz@math.uri.edu) and
   Douglas E. Ensley of Shippensburg University
   (DEEnsley@ship.edu).

   Feel free to use and modify the classes in the package
   flashandmath.as3.* to create
   your own Flash applications for educational purposes under the
   following two conditions:

   1) Please include a line acknowledging this work and the authors
   with your application in a way that is visible in your compiled file
   or on your html page.

   2) If you choose to modify the classes in the package
   flashandmath.as3.*, put them into a package different from
   the original. In this case too, please acknowledge this work
   in a way visible to the user.

   If you wish to use the materials for commercial purposes, you need our
   permission.

   This work is supported in part by the National Science Foundation
   under the grant DUE-0535327.

   Preliminary version.(The class works but it needs to be polished to comply
   with best programming practices in ActionScript 3.0)

   Last modified: June 30, 2007
 ************************************************************************ */

package flashandmath.as3.parsers {
	
	import flashandmath.as3.parsers.CompiledObject;
	
	public class MathParser {
		
		protected var f1Array:Array = ["sin", "cos", "tan", "ln", "log", "sqrt", "abs", "acos", "asin", "atan", "ceil", "floor", "round"];
		protected var f2Array:Array = ["max", "min", "plus", "minus", "mul", "div", "pow"];
		
		protected var iserror:Number;
		protected var errorMes:String;
		
		protected var tokenvalue:String;
		protected var tokentype:String;
		protected var tokenlength:Number;
		
		protected var nums:String = "0123456789.";
		protected var lets:String = "abcdefghijklmnopqrstuwvxzy";
		protected var opers:String = "^*+-/(),";
		
		protected var aVarNames:Array;
		
		public function MathParser(varArray:Array){
			if (varArray.length == 0){
				this.aVarNames = [];
			} else {
				this.aVarNames = setVars(varArray);
			}
			this.iserror = 0;
			this.errorMes = "";
		}
		
		protected function setVars(v:Array):Array {
			var tranNames:Array = [];
			var i:Number;
			for (i = 0; i < v.length; i++){
				if ((typeof v[i]) != "string"){
					trace("All variables must be entered as strings into MathParser constructor. Don't forget quotation marks.");
				}
				tranNames[i] = v[i].toLowerCase();
			}
			return tranNames;
		}
		
		public function doCompile(inputstring:String):CompiledObject {
			var coCompObj:CompiledObject = new CompiledObject();
			var stepString:String;
			var conString:String;
			var fstack:Array = [];
			iserror = 0;
			errorMes = "";
			stepString = whiteSpaces(inputstring);
			if (stepString == ""){
				coCompObj.PolishArray = [];
				coCompObj.errorMes = "";
				coCompObj.errorStatus = 0;
				return coCompObj;
			}
			checkLegal(stepString);
			if (iserror == 1){
				coCompObj.PolishArray = [];
				coCompObj.errorMes = errorMes;
				coCompObj.errorStatus = 1;
				return coCompObj;
			}
			checkPars(stepString);
			if (iserror == 1){
				coCompObj.PolishArray = [];
				coCompObj.errorMes = errorMes;
				coCompObj.errorStatus = 1;
				return coCompObj;
			}
			checkToks(stepString);
			if (iserror == 1){
				coCompObj.PolishArray = [];
				coCompObj.errorMes = errorMes;
				coCompObj.errorStatus = 1;
				return coCompObj;
			}
			conString = conOper(conOper(conOper(conOper(conUnary(conCaret(stepString)), "/"), "*"), "-"), "+");
			//trace("conString:", conString)
			if (iserror == 1){
				coCompObj.PolishArray = [];
				coCompObj.errorMes = errorMes;
				coCompObj.errorStatus = 1;
				return coCompObj;
			}
			fstack = makeStack(conString);
			if (iserror == 1){
				coCompObj.PolishArray = [];
				coCompObj.errorMes = errorMes;
				coCompObj.errorStatus = 1;
				return coCompObj;
			} else {
				coCompObj.PolishArray = fstack;
				coCompObj.errorMes = "";
				coCompObj.errorStatus = 0;
				return coCompObj;
			}
		}
		
		protected function istokf1(chars:String):Boolean {
			var i:Number;
			for (i = 0; i < f1Array.length; i++){
				if (chars == f1Array[i]){
					return true;
				}
			}
			return false;
		}
		
		protected function isVar(chars:String):Boolean {
			var i:Number;
			for (i = 0; i < aVarNames.length; i++){
				if (chars == aVarNames[i]){
					return true;
				}
			}
			return false;
		}
		
		protected function istokf2(chars:String):Boolean {
			var i:Number;
			for (i = 0; i < f2Array.length; i++){
				if (chars == f2Array[i]){
					return true;
				}
			}
			return false;
		}
		
		protected function isLet(char:String):Boolean {
			return lets.indexOf(char) >= 0;
		}
		
		protected function isOper(char:String):Boolean {
			return opers.indexOf(char) >= 0;
		}
		
		protected function isNum(char:String):Boolean {
			return nums.indexOf(char) >= 0;
		}
		
		protected function setToken(curtype:String, curvalue:String, curlength:Number):void {
			tokentype = curtype;
			tokenvalue = curvalue;
			tokenlength = curlength;
		}
		
		protected function nextToken(inputstring:String, pos:Number):Boolean {
			var char:String, t:String, inilen:Number, cpos:Number;
			var cstring:String;
			cstring = inputstring;
			cpos = pos;
			inilen = inputstring.length;
			if (cpos >= inilen || cpos < 0){
				return false;
			} else {
				char = cstring.charAt(cpos);
				if (isLet(char)){
					t = char;
					do {
						cpos += 1;
						if (cpos >= inilen)
							break;
						char = cstring.charAt(cpos);
						if (!isLet(char))
							break;
						t += char;
					} while (1);
					if (istokf1(t)){
						setToken("f1", t, t.length);
						return true;
					} else if (istokf2(t)){
						setToken("f2", t, t.length);
						return true;
					} else {
						setToken("v", t, t.length);
						return true;
					}
				}
				if (isNum(char)){
					t = char;
					do {
						cpos += 1;
						if (cpos >= inilen)
							break;
						char = cstring.charAt(cpos);
						if (!isNum(char))
							break;
						t += char;
					} while (1);
					setToken("n", t, t.length);
					return true;
				}
				if (isOper(char)){
					setToken("oper", char, 1);
					return true;
				}
				return false;
			}
		
		}
		
		function checkToks(inputstring:String):void {
			var pstring, pinilen, ppos, fpos, bpos, fchar, bchar, counter, matchpar, iscomma, comcounter;
			pstring = inputstring;
			ppos = 0;
			counter = 0;
			comcounter = 0;
			pinilen = pstring.length;
			if (pstring.indexOf("---") >= 0){
				callError("No need for so many minuses.");
				return;
			}
			while (ppos < pinilen && counter < pinilen * 2){
				if (nextToken(pstring, ppos)){
					fpos = ppos + tokenlength;
					fchar = pstring.charAt(fpos);
					bpos = (ppos - 1);
					bchar = pstring.charAt(bpos);
					if (tokentype == "f1"){
						if (!(fchar == "(")){
							callError("'(' expected at position " + fpos + ".");
							return;
						}
						if (ppos > 0 && !(isOper(bchar))){
							callError("Operator expected at position " + bpos + ".");
							return;
						}
						if (ppos > 0 && bchar == ")"){
							callError("Operator expected at position " + bpos + ".");
							return;
						}
					}
					if (tokentype == "f2"){
						if (!(tokenvalue == "max") && !(tokenvalue == "min")){
							callError("Unknown functions at position " + fpos + ".");
							return;
						}
						if (!(fchar == "(")){
							callError("'(' expected at position " + fpos + ".");
							return;
						} else {
							matchpar = 1;
							iscomma = 0;
							comcounter = 0;
							while (matchpar > 0 && comcounter < pinilen){
								comcounter += 1;
								if (pstring.charAt(fpos + comcounter) == "("){
									matchpar += 1;
								}
								if (pstring.charAt(fpos + comcounter) == ")"){
									matchpar += -1;
								}
								if (pstring.charAt(fpos + comcounter) == ","){
									iscomma += 1;
								}
							}
							if (iscomma == 0){
								callError("Two arguments expected for function at position " + ppos + ".");
								return;
							}
						}
						if (ppos > 0 && !(isOper(bchar))){
							callError("Operator expected at position " + bpos + ".");
							return;
						}
						if (ppos > 0 && bchar == ")"){
							callError("Operator expected at position " + bpos + ".");
							return;
						}
					}
					if (tokentype == "v"){
						if (!(isVar(tokenvalue) || tokenvalue == "pi" || tokenvalue == "e")){
							callError("Unknown entries at position " + ppos + ".");
							return;
						}
						if (ppos > 0 && !(isOper(bchar))){
							callError("Operator expected at position " + bpos + ".");
							return;
						}
						if (ppos > 0 && bchar == ")"){
							callError("Operator expected at position " + bpos + ".");
							return;
						}
						if (fpos < pinilen && !(isOper(fchar))){
							callError("Operator expected at position " + fpos + ".");
							return;
						}
						if (fpos < pinilen && fchar == "("){
							callError("Operator expected at position " + fpos + ".");
							return;
						}
					}
					if (tokentype == "n"){
						if (ppos > 0 && !(isOper(bchar))){
							callError("Operator expected at position " + bpos + ".");
							return;
						}
						if (ppos > 0 && bchar == ")"){
							callError("Operator expected at position " + bpos + ".");
							return;
						}
						if (fpos < pinilen && !(isOper(fchar))){
							callError("Operator expected at position " + fpos + ".");
							return;
						}
						if (fpos < pinilen && fchar == "("){
							callError("Operator expected at position " + fpos + ".");
							return;
						}
					}
					if (tokenvalue == "("){
						if (fpos < pinilen && ("^*,)+/").indexOf(fchar) >= 0){
							callError("Entries expected at position " + fpos + ".");
							return;
						}
					}
					if (tokenvalue == ")"){
						if (fpos < pinilen && ("^*+-,/)").indexOf(fchar) == -1){
							callError("Entries expected at position " + fpos + ".");
							return;
						}
						if (bpos >= 0 && ("^*+-,/(").indexOf(bchar) >= 0){
							callError("Entries expected at position" + fpos + ".");
							return;
						}
					}
					if (tokenvalue == ","){
						if (ppos == 0 || ppos == pinilen - 1){
							callError("Stray comma at position " + ppos + ".");
							return;
						}
						if (fpos < pinilen && ("^*+,/)").indexOf(fchar) >= 0){
							callError("Entries expected at position " + fpos + ".");
							return;
						}
						if (bpos >= 0 && ("^*+-,/(").indexOf(bchar) >= 0){
							callError("Entries expected at position " + fpos + ".");
							return;
						}
					}
					if (("^/*-+").indexOf(tokenvalue) >= 0){
						if (("+*^/),").indexOf(fchar) >= 0){
							callError("Entries expected at position " + fpos + ".");
							return;
						}
						if (("+*^/(,").indexOf(bchar) >= 0 && !(tokenvalue == "-")){
							callError("Entries expected at position " + fpos + ".");
							return;
						}
					}
				} else {
					callError("Unknown characters at position ." + ppos);
				}
				ppos += tokenlength;
				counter += 1;
			}
		}
		
		protected function conOper(inputstring:String, char:String):String {
			var transtring: String, inilen: int, mco: int, curpos: int, leftoper, rightoper, leftmove, rightmove;
			inilen = inputstring.length;
			transtring = inputstring;
			if (transtring.indexOf(char) == -1) return transtring;
			else if (transtring.indexOf(char) == 0 && !(char == "-")){
				callError("Error at the first " + char);
				return "";
			}
			else if (transtring.charAt(transtring.length - 1) == char){
				callError("Error at the last " + char + ".");
				return "";
			} else {
				mco = 0;
				while (transtring.indexOf(char) > 0 && mco < inilen * 6){
					mco += 1;
					curpos = transtring.indexOf(char);
					leftmove = goLeft(transtring, curpos);
					if (iserror == 1){
						callError("Error at  " + char + "  number " + mco + ".");
						return "";
					}
					else leftoper = transtring.substring(leftmove + 1, curpos);
					rightmove = goRight(transtring, curpos);
					if (iserror == 1){
						callError("Error at  " + char + "  number " + mco + ".");
						return "";
					} else rightoper = transtring.substring(curpos + 1, rightmove);
					if (char == "*") transtring = transtring.substring(0, leftmove + 1) + "mul(" + leftoper + "," + rightoper + ")" + transtring.substring(rightmove, transtring.length + 1);
					if (char == "/") transtring = transtring.substring(0, leftmove + 1) + "div(" + leftoper + "," + rightoper + ")" + transtring.substring(rightmove, transtring.length + 1);
					if (char == "-") transtring = transtring.substring(0, leftmove + 1) + "minus(" + leftoper + "," + rightoper + ")" + transtring.substring(rightmove, transtring.length + 1);
					if (char == "+") transtring = transtring.substring(0, leftmove + 1) + "plus(" + leftoper + "," + rightoper + ")" + transtring.substring(rightmove, transtring.length + 1);
					if (transtring.length > inilen * 7){
						callError("Oooops!");
						return "";
					}
				}
				return transtring;
			}
		}
		
		protected function conUnary(inputstring:String):String {
			var transtring, inilen, mco, curpos, i, j;
			inilen = inputstring.length;
			transtring = inputstring;
			if (transtring.indexOf("-") == -1) return transtring;
			if (transtring.charAt(transtring.length - 1) == "-"){
				callError("Error at the last minus.");
				return "";
			}
			for (i = 0; i < transtring.length; i++){
				if (transtring.charAt(i) == "-" && unaryId(transtring.charAt(i - 1))){
					j = goRight(transtring, i);
					if (iserror == 1){
						callError("Error at position " + i);
						return "";
					}
					transtring = transtring.substring(0, i) + "minus(0," + transtring.substring(i + 1, j) + ")" + transtring.substring(j, transtring.length);
				}
				if (transtring.length > 9 * inilen){
					callError("Ooops!");
					return "";
				}
			}
			return transtring;
		}
		
		protected function unaryId(char:String):Boolean {
			return ("+-,(/*^".indexOf(char) > -1);
		}
		
		protected function goRight(inputstring:String, pos:Number):Number {
			var rightchar, rightcounter, matchpar;
			rightchar = inputstring.charAt(pos + 1);
			rightcounter = pos + 1;
			if (rightchar == "-"){
				rightcounter += 1;
				if (rightcounter >= inputstring.length){
					iserror = 1;
					return rightcounter;
				} else rightchar = inputstring.charAt(rightcounter);
			}
			if (nums.indexOf(rightchar) > -1){
				while (nums.indexOf(inputstring.charAt(rightcounter)) > -1 && rightcounter < inputstring.length) rightcounter += 1;
			} else if (lets.indexOf(rightchar) > -1){
				while (lets.indexOf(inputstring.charAt(rightcounter)) > -1 && rightcounter < inputstring.length) rightcounter += 1;
				if (inputstring.charAt(rightcounter) == "("){
					matchpar = 1;
					while (matchpar > 0 && rightcounter < inputstring.length){
						rightcounter += 1;
						if (inputstring.charAt(rightcounter) == "(") matchpar += 1;
						if (inputstring.charAt(rightcounter) == ")") matchpar += -1;
					}
				}
				if (matchpar > 0) {
					iserror = 1;
					return rightcounter;
				}
			} else if (rightchar == "("){
				matchpar = 1;
				while (matchpar > 0 && rightcounter < inputstring.length){
					rightcounter += 1;
					if (inputstring.charAt(rightcounter) == "(") matchpar += 1;
					if (inputstring.charAt(rightcounter) == ")") matchpar += -1;
				}
				rightcounter += 1;
				if (matchpar > 0){
					iserror = 1;
					return rightcounter;
				}
			} else {
				iserror = 1;
				return rightcounter;
			}
			return rightcounter;
		}
		
		protected function goLeft(inputstring:String, pos:Number):Number {
			var leftchar, leftcounter, matchpar;
			leftchar = inputstring.charAt(pos - 1);
			leftcounter = pos - 1;
			if (nums.indexOf(leftchar) > -1){
				while (nums.indexOf(inputstring.charAt(leftcounter)) > -1 && leftcounter >= 0) leftcounter += -1;
			} else if (lets.indexOf(leftchar) > -1){
				while (lets.indexOf(inputstring.charAt(leftcounter)) > -1 && leftcounter >= 0) leftcounter += -1;
			} else if (leftchar == ")"){
				matchpar = 1;
				if (leftcounter == 0){
					iserror = 1;
					return leftcounter;
				}
				while (matchpar > 0 && leftcounter > 0){
					leftcounter += -1;
					if (inputstring.charAt(leftcounter) == ")") matchpar += 1;
					if (inputstring.charAt(leftcounter) == "(") matchpar += -1;
				}
				leftcounter += -1;
				if (matchpar > 0){
					iserror = 1;
					return leftcounter;
				}
				if (leftcounter >= 0 && nums.indexOf(inputstring.charAt(leftcounter)) > -1){
					iserror = 1;
					return leftcounter;
				}
				if (leftcounter == 0 && !(inputstring.charAt(leftcounter) == "-") && !(inputstring.charAt(leftcounter) == "(")){
					iserror = 1;
					return leftcounter;
				}
				if (leftcounter > 0 && lets.indexOf(inputstring.charAt(leftcounter)) > -1){
					while (lets.indexOf(inputstring.charAt(leftcounter)) > -1 && leftcounter >= 0) leftcounter += -1;
				}
			} else {
				iserror = 1;
				return leftcounter;
			}
			return leftcounter;
		}
		
		protected function conCaret(inputstring:String):String {
			var transtring, inilen, mco, curpos, leftmove, rightmove, base, expon;
			inilen = inputstring.length;
			transtring = inputstring;
			if (transtring.indexOf("^") == -1) return transtring;
			else if (transtring.indexOf("^") == 0){
				callError("Error at the first ^.");
				return "";
			} else if (transtring.charAt(transtring.length - 1) == "^"){
				callError("Error at the last ^.");
				return "";
			} else {
				mco = 0;
				while (transtring.indexOf("^") > 0 && mco < inilen * 6){
					mco += 1;
					curpos = transtring.lastIndexOf("^");
					leftmove = goLeft(transtring, curpos);
					if (iserror == 1){
						callError("Error at ^ number " + mco + " from the end.");
						return "";
					} else base = transtring.substring(leftmove + 1, curpos);
					rightmove = goRight(transtring, curpos);
					if (iserror == 1){
						callError("Error at ^ number " + mco + " from the end.");
						return "";
					} else expon = transtring.substring(curpos + 1, rightmove);
					transtring = transtring.substring(0, leftmove + 1) + "pow(" + base + "," + expon + ")" + transtring.substring(rightmove, transtring.length + 1);
					if (transtring.length > inilen * 7){
						callError("Oooops!");
						return "";
					}
				}
				return transtring;
			}
		}
		
		protected function whiteSpaces(inputstring:String):String {
			var curpos, transtring, inilen, counter = 0;
			inilen = inputstring.length;
			transtring = inputstring.toLowerCase();
			while (transtring.indexOf(" ") > -1 && counter < inilen + 1){
				curpos = transtring.indexOf(" ");
				transtring = transtring.substring(0, curpos) + transtring.substring(curpos + 1, transtring.length);
				counter += 1;
			}
			return transtring;
		}
		
		protected function checkLegal(inputstring:String):Boolean {
			var i, legal, curchar;
			if (inputstring == ""){
				callError("Empty input.");
				return false;
			}
			for (i = 0; i < inputstring.length; i++){
				curchar = inputstring.charAt(i);
				legal = nums.indexOf(curchar) + lets.indexOf(curchar) + opers.indexOf(curchar);
				if (legal == -3){
					callError("Unknown characters.");
					return false;
				}
			}
			return true;
		}
		
		protected function checkPars(inputstring:String):Boolean {
			var i, j, matchpar, left = 0, right = 0, counter = 0;
			for (i = 0; i < inputstring.length; i++){
				if (inputstring.charAt(i) == "(") left += 1;
				if (inputstring.charAt(i) == ")") right += 1;
			}
			if (!(left == right)){
				callError("Mismatched parenthesis.");
				return false;
			}
			for (j = 0; j < inputstring.length; j++){
				if (inputstring.charAt(j) == "("){
					matchpar = 1;
					counter = 0;
					while (matchpar > 0 && counter < inputstring.length){
						counter += 1;
						if (inputstring.charAt(j + counter) == "(") matchpar += 1;
						if (inputstring.charAt(j + counter) == ")") matchpar += -1;
					}
					if (matchpar > 0){
						j += 1;
						callError("Mismatched parenthesis at position number " + j);
						return false;
					}
				}
			}
			for (j = 0; j < inputstring.length; j++){
				if (inputstring.charAt(j) == ")"){
					matchpar = 1;
					counter = 0;
					while (matchpar > 0 && counter < inputstring.length){
						counter += 1;
						if (inputstring.charAt(j - counter) == ")") matchpar += 1;
						if (inputstring.charAt(j - counter) == "(") matchpar += -1;
					}
					if (matchpar > 0){
						j += 1;
						callError("Mismatched parenthesis at position number " + j);
						return false;
					}
				}
			}
			return true;
		}
		
		protected function makeStack(inputstring:String):Array {
			var mstring: String, minilen: int, mpos: int, mstack: Array, checkStack: Array, checkExpr: Array, counter: int, checkResult: Array;
			mstring = inputstring;
			mpos = 0;
			mstack = [];
			checkStack = [];
			minilen = mstring.length;
			checkExpr = [];
			checkResult = [];
			counter = 0;
			while (mpos < minilen && counter < minilen * 2){
				if (nextToken(mstring, mpos)) {
					if (tokentype == "f1") {
						mstack.push(tokenvalue);
						mstack.push("f1");
						checkStack.push("sin");
						checkStack.push("f1");
					}
					if (tokentype == "f2"){
						mstack.push(tokenvalue);
						mstack.push("f2");
						checkStack.push("plus");
						checkStack.push("f2");
					}
					if (tokentype == "v"){
						mstack.push(tokenvalue);
						mstack.push("v");
						checkStack.push("x");
						checkStack.push("v");
					}
					if (tokentype == "n"){
						mstack.push(Number(tokenvalue));
						mstack.push("n");
						checkStack.push(Number(tokenvalue));
						checkStack.push("n");
					}
				} else {
					callError("Unknown characters.");
					return [];
				}
				mpos += tokenlength;
				counter += 1;
			}
			mstack.reverse();
			checkExpr = checkStack.reverse();
			checkEval(checkExpr);
			if (iserror == 1) return [];
			return (mstack);
		}
		
		protected function makeString(fstack: Array): String {
			return "";
		}
		
		protected function callError(mess:String):void {
			errorMes = "Syntax error. " + mess;
			iserror = 1;
		}
		
		protected function checkEval(compiledExpression:Array):void {
			var entrytype = "";
			var operands = [];
			var arg1, arg2;
			for (var i = 0; i < compiledExpression.length; i++){
				entrytype = compiledExpression[i++];
				if (entrytype == "n") operands.push(compiledExpression[i]);
				else if (entrytype == "v") operands.push(1);
				else if (entrytype == "f1"){
					if (operands.length < 1){
						callError("Check number of arguments in your functions.");
						return;
					}
					operands.push(this[compiledExpression[i]](operands.pop()))
				} else if (entrytype == "f2"){
					if (operands.length < 2){
						callError("Check number of arguments in your functions.");
						return;
					}
					arg1 = operands.pop();
					arg2 = operands.pop();
					operands.push(this[compiledExpression[i]](arg1, arg2));
				} else {
					callError("Can't evaluate.");
					return;
				}
			}
			if (!(operands.length == 1)){
				callError("");
				return;
			}
			if (isNaN(operands[0])){
				callError("");
				return;
			}
		}
		
		protected function sin(a: Number): Number {
			return Math.sin(a);
		}
		
		protected function cos(a: Number): Number {
			return Math.cos(a);
		}
		
		protected function tan(a: Number): Number {
			return Math.tan(a);
		}
		
		protected function ln(a: Number): Number {
			return Math.log(a);
		}
		
		protected function log(a: Number): Number {
			return Math.log(a) * Math.LOG10E;
		}
		
		protected function sqrt(a: Number): Number { 
			return Math.sqrt(a);
		}
		
		protected function abs(a: Number): Number {
			return Math.abs(a);
		}
		
		protected function asin(a: Number): Number {
			return Math.asin(a);
		}
		
		protected function acos(a: Number): Number {
			return Math.acos(a);
		}
		
		protected function atan(a: Number): Number {
			return Math.atan(a);
		}
		
		protected function floor(a: Number): Number {
			return Math.floor(a);
		}
		
		protected function ceil(a: Number): Number {
			return Math.ceil(a);
		}
		
		protected function round(a: Number): Number {
			return Math.round(a);
		}
		
		protected function max(a: Number, b: Number): Number {
			return Math.max(a, b);
		}
		
		protected function min(a: Number, b: Number): Number {
			return Math.min(a, b);
		}
		
		protected function plus(a: Number, b: Number): Number {
			return a + b;
		}
		
		protected function minus(a: Number, b: Number): Number {
			return a - b;
		}
		
		protected function mul(a: Number, b: Number): Number {
			return a * b;
		}
		
		protected function div(a: Number, b: Number): Number {
			return a / b;
		}
		
		protected function pow(a: Number, b: Number): Number {
			if (a < 0 && b == Math.floor(b)){
				if ((b % 2) == 0) return Math.pow(-a, b);
				else return -Math.pow(-a, b);
			}
			if (a == 0 && b > 0) return 0;
			if (isNaN(a) && b == 0) return NaN;
			return Math.pow(a, b);
		}
		
		public function doEval(compiledExpression:Array, aVarVals:Array):Number {
			var entrytype:String = "";
			var operands:Array = [];
			var i:Number;
			var j:Number;
			var arg0: Number;
			var arg1: Number;
			var arg2: Number;
			if (aVarVals.length != aVarNames.length) return NaN;
			for (j = 0; j < aVarVals.length; j++) {
				if ((typeof aVarVals[j]) != "number") return NaN;
			}
			for (i = 0; i < compiledExpression.length; i++){
				entrytype = compiledExpression[i++];
				if (entrytype == "n") operands.push(compiledExpression[i]);
				else if (entrytype == "v") {
					if (compiledExpression[i] == "e") operands.push(Math.E);
					else if (compiledExpression[i] == "pi") operands.push(Math.PI);
					else {
						for (j = 0; j < aVarNames.length; j++){
							if (compiledExpression[i] == aVarNames[j]){
								operands.push(aVarVals[j]);
							}
						}
					}
				} else if (entrytype == "f1"){
					arg0 = operands.pop();
					var val: Number = this[compiledExpression[i]](arg0);
					if (isNaN(val)) val = 0;
					operands.push(val);
				} else if (entrytype == "f2"){
					arg1 = operands.pop();
					arg2 = operands.pop();
					var val: Number = this[compiledExpression[i]](arg1, arg2);
					if (isNaN(val)) val = 0;
					operands.push(val);
				} else return NaN;
			}
			return operands[0]
		}
		
		public function doDeriv(compiledExpression:Array, aVarVals:Array):Number {
			// Method only works for single-variable expressions 
			if (aVarVals.length > 1) return (NaN);
			var entrytype:String = "";
			var operands:Array = [];
			var i:Number;
			var j:Number;
			var arg0:Array;
			var arg1:Array;
			var arg2:Array;
			if (aVarVals.length != aVarNames.length) return NaN;
			for (j = 0; j < aVarVals.length; j++){
				if ((typeof aVarVals[j]) != "number") return NaN;
			}
			for (i = 0; i < compiledExpression.length; i++){
				entrytype = compiledExpression[i++];
				if (entrytype == "n") operands.push([compiledExpression[i], 0]);
				else if (entrytype == "v") {
					if (compiledExpression[i] == "e") operands.push([Math.E, 0]);
					else if (compiledExpression[i] == "pi") operands.push([Math.PI, 0]);
					else {
						for (j = 0; j < aVarNames.length; j++){
							if (compiledExpression[i] == aVarNames[j]) operands.push([aVarVals[j], 1]);
						}
					}
				} else if (entrytype == "f1"){
					arg0 = operands.pop();
					if (compiledExpression[i] == "sin") operands.push([Math.sin(arg0[0]), Math.cos(arg0[0]) * arg0[1]]);
					else if (compiledExpression[i] == "cos") operands.push([Math.cos(arg0[0]), -Math.sin(arg0[0]) * arg0[1]]);
					else if (compiledExpression[i] == "tan") operands.push([Math.tan(arg0[0]), arg0[1] / (Math.cos(arg0[0]) * Math.cos(arg0[0]))]);
					else if (compiledExpression[i] == "asin") operands.push([Math.asin(arg0[0]), arg0[1] / Math.cos(Math.asin(arg0[0]))]);
					else if (compiledExpression[i] == "acos") operands.push([Math.acos(arg0[0]), -arg0[1] / Math.sin(Math.acos(arg0[0]))]);
					else if (compiledExpression[i] == "atan") operands.push([Math.atan(arg0[0]), arg0[1] * Math.cos(Math.atan(arg0[0])) * Math.cos(Math.atan(arg0[0]))]);
					else if (compiledExpression[i] == "ln") operands.push([Math.log(arg0[0]), arg0[1] / arg0[0]]);
					else if (compiledExpression[i] == "log") operands.push([Math.log(arg0[0]), arg0[1] / (arg0[0] * Math.log(10))]);
					else if (compiledExpression[i] == "sqrt") operands.push([Math.sqrt(arg0[0]), arg0[1] / (2 * Math.sqrt(arg0[0]))]);
					else if (compiledExpression[i] == "abs") operands.push([Math.abs(arg0[0]), NaN]);
					else if (compiledExpression[i] == "ceil") operands.push([Math.ceil(arg0[0]), NaN]);
					else if (compiledExpression[i] == "floor") operands.push([Math.floor(arg0[0]), NaN]);
					else if (compiledExpression[i] == "round") operands.push([Math.round(arg0[0]), NaN]);
					else operands.push(this[compiledExpression[i]](arg0));
				} else if (entrytype == "f2"){
					arg1 = operands.pop();
					arg2 = operands.pop();
					if (compiledExpression[i] == "mul") operands.push([arg1[0] * arg2[0], arg1[1] * arg2[0] + arg1[0] * arg2[1]]);
					else if (compiledExpression[i] == "plus") operands.push([arg1[0] + arg2[0], arg1[1] + arg2[1]]);
					else if (compiledExpression[i] == "minus") operands.push([arg1[0] - arg2[0], arg1[1] - arg2[1]]);
					else if (compiledExpression[i] == "div") operands.push([arg1[0] / arg2[0], (arg2[0] * arg1[1] - arg2[1] * arg1[0]) / (arg2[0] * arg2[0])]);
					else if (compiledExpression[i] == "pow"){
						if (arg2[1] == 0) operands.push([Math.pow(arg1[0], arg2[0]), Math.pow(arg1[0], arg2[0] - 1) * arg2[0] * arg1[1]]);
						else operands.push([Math.pow(arg1[0], arg2[0]), Math.pow(arg1[0], arg2[0] - 1) * (arg2[0] * arg1[1] + arg1[0] * arg2[1] * Math.log(arg1[0]))]);
					} else if (compiledExpression[i] == "min") operands.push([Math.min(arg1[0], arg2[0]), NaN]);
					else if (compiledExpression[i] == "max") operands.push([Math.max(arg1[0], arg2[0]), NaN]);
					else operands.push(this[compiledExpression[i]](arg1, arg2));
				} else {
					return NaN;
				}
			}
			return operands[0][1];
		}
	
		public function doDerivFormula(compiledExpression:Array): Array {
			//Method only works for single-variable expressions
			var entrytype:String = "";
			var operands:Array = [];
			var arg0:Array;
			var arg1:Array;
			var arg2:Array;
			//trace("compiledExpression:", compiledExpression)
			for (var i: uint = 0; i < compiledExpression.length; i++){
				entrytype = compiledExpression[i++];
				if (entrytype == "n") operands.push([["n", compiledExpression[i]], ["n", 0]]);
				else if (entrytype == "v") {
					if (compiledExpression[i] == "e") operands.push([["n", Math.E], ["n", 0]]);
					else if (compiledExpression[i] == "pi") operands.push([["n", Math.PI], ["n", 0]]);
					else operands.push([["v", compiledExpression[i]], ["n", 1]]);
				} else if (entrytype == "f1"){
					arg0 = operands.pop();
					if (compiledExpression[i] == "sin") operands.push([arg0[0].concat("f1", "sin"), arg0[0].concat("f1", "cos").concat(arg0[1]).concat("f2", "mul")]);
					else if (compiledExpression[i] == "cos") operands.push([arg0[0].concat("f1", "cos"), arg0[0].concat("f1", "sin").concat("n", -1).concat("f2", "mul").concat(arg0[1]).concat("f2", "mul")]);
					else if (compiledExpression[i] == "tan") operands.push([arg0[0].concat("f1", "tan"), ["n", 2].concat(arg0[0]).concat("f1", "cos").concat("f2", "pow").concat(arg0[1]).concat("f2", "div")]);
					else if (compiledExpression[i] == "asin") operands.push([arg0[0].concat("f1", "asin"), arg0[0].concat("f1", "asin").concat("f1", "cos").concat(arg0[1]).concat("f2", "div")]);
					else if (compiledExpression[i] == "acos") operands.push([arg0[0].concat("f1", "acos"), arg0[0].concat("f1", "acos").concat("f1", "sin").concat(arg0[1]).concat("n", -1).concat("f2", "mul").concat("f2", "div")]);
					else if (compiledExpression[i] == "atan") operands.push([arg0[0].concat("f1", "atan"), arg0[1].concat("n", 2).concat(arg0[0]).concat("f1", "atan").concat("f1", "cos").concat("f2", "pow").concat("f2", "mul")]);
					else if (compiledExpression[i] == "ln") operands.push([arg0[0].concat("f1", "ln"), arg0[0].concat(arg0[1]).concat("f2", "div")]);
					else if (compiledExpression[i] == "log") operands.push([arg0[0].concat("f1", "ln"), arg0[0].concat("n", Math.log(10)).concat("f2", "mul").concat(arg0[1]).concat("f2", "div")]);
					else if (compiledExpression[i] == "sqrt") operands.push([arg0[0].concat("f1", "sqrt"), arg0[0].concat("f1", "sqrt").concat("n", 2).concat("f2", "mul").concat(arg0[1]).concat("f2", "div")]);
					else if (compiledExpression[i] == "abs") operands.push([arg0[0].concat("f1", "abs"), [NaN]]);
					else if (compiledExpression[i] == "ceil") operands.push([arg0[0].concat("f1", "ceil"), [NaN]]);
					else if (compiledExpression[i] == "floor") operands.push([arg0[0].concat("f1", "floor"), [NaN]]);
					else if (compiledExpression[i] == "round") operands.push([arg0[0].concat("f1", "round"), [NaN]]);
					else operands.push(arg0[0].concat("f1", compiledExpression[i]));
				} else if (entrytype == "f2") {
					arg1 = operands.pop();
					arg2 = operands.pop();
					if (compiledExpression[i] == "mul") operands.push([arg1[0].concat(arg2[0]).concat("f2", "mul"), arg1[1].concat(arg2[0]).concat("f2", "mul").concat(arg1[0]).concat(arg2[1]).concat("f2", "mul").concat("f2", "plus")]);
					else if (compiledExpression[i] == "plus") operands.push([arg1[0].concat(arg2[0]).concat("f2", "plus"), arg1[1].concat(arg2[1]).concat("f2", "plus")]);
					else if (compiledExpression[i] == "minus") operands.push([arg2[0].concat(arg1[0]).concat("f2", "minus"), arg2[1].concat(arg1[1]).concat("f2", "minus")]);
					else if (compiledExpression[i] == "div") operands.push([arg2[0].concat(arg1[0]).concat("f2", "div"), arg2[0].concat(arg2[0]).concat("f2", "mul").concat(arg2[1]).concat(arg1[0]).concat("f2", "mul").concat(arg2[0]).concat(arg1[1]).concat("f2", "mul").concat("f2", "minus").concat("f2", "div")]);
					else if (compiledExpression[i] == "pow"){
						if (arg2[1] == 0) operands.push([arg2[0].concat(arg1[0]).concat("f2", "pow"), ["n", 1].concat(arg2[0]).concat("f2", "minus").concat(arg1[0]).concat("f2", "pow").concat(arg2[0]).concat("f2", "mul").concat(arg1[1]).concat("f2", "mul")]);
						else operands.push([arg2[0].concat(arg1[0]).concat("f2", "pow"), ["n", 1].concat(arg2[0]).concat("f2", "minus").concat(arg1[0]).concat("f2", "pow").concat(arg2[0]).concat(arg1[1]).concat("f2", "mul").concat(arg1[0]).concat(arg2[1]).concat("f2", "mul").concat(arg1[0]).concat("f1", "ln").concat("f2", "mul").concat("f2", "plus").concat("f2", "mul")]);
					} else if (compiledExpression[i] == "min") operands.push([arg1[0].concat(arg2[0]).concat("f2", "min"), [NaN]]);
					else if (compiledExpression[i] == "max") operands.push([arg1[0].concat(arg2[0]).concat("f2", "max"), [NaN]]);
					else operands.push([arg1[0].concat(arg1[1]).concat("f2", compiledExpression[i]), arg2[0].concat(arg2[1]).concat("f2", compiledExpression[i])]);
				} else {
					return [];
				}
				//trace("operands:", operands[0])
			}
			return operands[0][1];
		}		
	}

}
