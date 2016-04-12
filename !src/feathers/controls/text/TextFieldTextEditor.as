/*
Feathers
Copyright 2012-2014 Joshua Tynjala. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.controls.text
{
	import feathers.core.FeathersControl;
	import feathers.core.ITextEditor;
	import feathers.events.FeathersEventType;
	import feathers.utils.geom.matrixToRotation;
	import feathers.utils.geom.matrixToScaleX;
	import feathers.utils.geom.matrixToScaleY;

	import flash.display.BitmapData;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.SoftKeyboardEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;

	import starling.core.RenderSupport;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.events.Event;
	import starling.textures.ConcreteTexture;
	import starling.textures.Texture;
	import starling.utils.MatrixUtil;
	import starling.utils.getNextPowerOfTwo;

	/**
	 * Dispatched when the text property changes.
	 */
	[Event(name="change",type="starling.events.Event")]

	/**
	 * Dispatched when the user presses the Enter key while the editor has focus.
	 *
	 * @eventType feathers.events.FeathersEventType.ENTER
	 */
	[Event(name="enter",type="starling.events.Event")]

	/**
	 * Dispatched when the text editor receives focus.
	 *
	 * @eventType feathers.events.FeathersEventType.FOCUS_IN
	 */
	[Event(name="focusIn",type="starling.events.Event")]

	/**
	 * Dispatched when the text editor loses focus.
	 *
	 * @eventType feathers.events.FeathersEventType.FOCUS_OUT
	 */
	[Event(name="focusOut",type="starling.events.Event")]

	/**
	 * Dispatched when the soft keyboard is activated. Not all text editors will
	 * activate a soft keyboard.
	 *
	 * @eventType feathers.events.FeathersEventType.SOFT_KEYBOARD_ACTIVATE
	 */
	[Event(name="softKeyboardActivate",type="starling.events.Event")]

	/**
	 * Dispatched when the soft keyboard is deactivated. Not all text editors
	 * will activate a soft keyboard.
	 *
	 * @eventType feathers.events.FeathersEventType.SOFT_KEYBOARD_DEACTIVATE
	 */
	[Event(name="softKeyboardDeactivate",type="starling.events.Event")]

	/**
	 * A Feathers text editor that uses the native <code>TextField</code> class
	 * set to <code>TextInputType.INPUT</code>.
	 *
	 * @see http://wiki.starling-framework.org/feathers/text-editors
	 * @see flash.text.TextField
	 */
	public class TextFieldTextEditor extends FeathersControl implements ITextEditor
	{
		/**
		 * @private
		 */
		private static const HELPER_MATRIX:Matrix = new Matrix();

		/**
		 * @private
		 */
		private static const HELPER_POINT:Point = new Point();

		/**
		 * Constructor.
		 */
		public function TextFieldTextEditor()
		{
			this.isQuickHitAreaEnabled = true;
			this.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			this.addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
		}

		/**
		 * The text field sub-component.
		 */
		protected var textField:TextField;

		/**
		 * An image that displays a snapshot of the native <code>TextField</code>
		 * in the Starling display list when the editor doesn't have focus.
		 */
		protected var textSnapshot:Image;

		/**
		 * The separate text field sub-component used for measurement.
		 * Typically, the main text field often doesn't report correct values
		 * for a full frame if its dimensions are changed too often.
		 */
		protected var measureTextField:TextField;

		/**
		 * @private
		 */
		protected var _snapshotWidth:int = 0;

		/**
		 * @private
		 */
		protected var _snapshotHeight:int = 0;

		/**
		 * @private
		 */
		protected var _textFieldClipRect:Rectangle = new Rectangle();

		/**
		 * @private
		 */
		protected var _textFieldOffsetX:Number = 0;

		/**
		 * @private
		 */
		protected var _textFieldOffsetY:Number = 0;

		/**
		 * @private
		 */
		protected var _needsNewTexture:Boolean = false;

		/**
		 * @private
		 */
		protected var _text:String = "";

		/**
		 * @inheritDoc
		 *
		 * <p>In the following example, the text is changed:</p>
		 *
		 * <listing version="3.0">
		 * textEditor.text = "Lorem ipsum";</listing>
		 *
		 * @default ""
		 */
		public function get text():String
		{
			return this._text;
		}

		/**
		 * @private
		 */
		public function set text(value:String):void
		{
			if(!value)
			{
				//don't allow null or undefined
				value = "";
			}
			if(this._text == value)
			{
				return;
			}
			this._text = value;
			this.invalidate(INVALIDATION_FLAG_DATA);
			this.dispatchEventWith(Event.CHANGE);
		}

		/**
		 * @private
		 */
		protected var _textFormat:TextFormat;

		/**
		 * The format of the text, such as font and styles.
		 *
		 * <p>In the following example, the text format is changed:</p>
		 *
		 * <listing version="3.0">
		 * textEditor.textFormat = new TextFormat( "Source Sans Pro" );;</listing>
		 *
		 * @default null
		 */
		public function get textFormat():TextFormat
		{
			return this._textFormat;
		}

		/**
		 * @private
		 */
		public function set textFormat(value:TextFormat):void
		{
			if(this._textFormat == value)
			{
				return;
			}
			this._textFormat = value;
			this.invalidate(INVALIDATION_FLAG_STYLES);
		}

		/**
		 * @private
		 */
		protected var _embedFonts:Boolean = false;

		/**
		 * Determines if the TextField should use an embedded font or not.
		 *
		 * <p>In the following example, the font is embedded:</p>
		 *
		 * <listing version="3.0">
		 * textEditor.embedFonts = true;</listing>
		 *
		 * @default false
		 */
		public function get embedFonts():Boolean
		{
			return this._embedFonts;
		}

		/**
		 * @private
		 */
		public function set embedFonts(value:Boolean):void
		{
			if(this._embedFonts == value)
			{
				return;
			}
			this._embedFonts = value;
			this.invalidate(INVALIDATION_FLAG_STYLES);
		}

		/**
		 * @private
		 */
		protected var _wordWrap:Boolean = false;

		/**
		 * Determines if the TextField wraps text to the next line.
		 *
		 * <p>In the following example, word wrap is enabled:</p>
		 *
		 * <listing version="3.0">
		 * textEditor.wordWrap = true;</listing>
		 *
		 * @default false
		 */
		public function get wordWrap():Boolean
		{
			return this._wordWrap;
		}

		/**
		 * @private
		 */
		public function set wordWrap(value:Boolean):void
		{
			if(this._wordWrap == value)
			{
				return;
			}
			this._wordWrap = value;
			this.invalidate(INVALIDATION_FLAG_STYLES);
		}

		/**
		 * @private
		 */
		protected var _multiline:Boolean = false;

		/**
		 * Same as the <code>TextField</code> property with the same name.
		 *
		 * <p>In the following example, multiline is enabled:</p>
		 *
		 * <listing version="3.0">
		 * textEditor.multiline = true;</listing>
		 *
		 * @default false
		 */
		public function get multiline():Boolean
		{
			return this._multiline;
		}

		/**
		 * @private
		 */
		public function set multiline(value:Boolean):void
		{
			if(this._multiline == value)
			{
				return;
			}
			this._multiline = value;
			this.invalidate(INVALIDATION_FLAG_STYLES);
		}

		/**
		 * @private
		 */
		protected var _isHTML:Boolean = false;

		/**
		 * Determines if the TextField should display the text as HTML or not.
		 *
		 * <p>In the following example, the text is displayed as HTML:</p>
		 *
		 * <listing version="3.0">
		 * textEditor.isHTML = true;</listing>
		 *
		 * @default false
		 */
		public function get isHTML():Boolean
		{
			return this._isHTML;
		}

		/**
		 * @private
		 */
		public function set isHTML(value:Boolean):void
		{
			if(this._isHTML == value)
			{
				return;
			}
			this._isHTML = value;
			this.invalidate(INVALIDATION_FLAG_DATA);
		}

		/**
		 * @private
		 */
		protected var _alwaysShowSelection:Boolean = false;

		/**
		 * Same as the <code>flash.text.TextField</code> property with the same name.
		 *
		 * <p>In the following example, the selection is always shown:</p>
		 *
		 * <listing version="3.0">
		 * textEditor.alwaysShowSelection = true;</listing>
		 *
		 * @default false
		 */
		public function get alwaysShowSelection():Boolean
		{
			return this._alwaysShowSelection;
		}

		/**
		 * @private
		 */
		public function set alwaysShowSelection(value:Boolean):void
		{
			if(this._alwaysShowSelection == value)
			{
				return;
			}
			this._alwaysShowSelection = value;
			this.invalidate(INVALIDATION_FLAG_STYLES);
		}

		/**
		 * @private
		 */
		protected var _displayAsPassword:Boolean = false;

		/**
		 * Same as the <code>flash.text.TextField</code> property with the same name.
		 *
		 * <p>In the following example, the text is displayed as as password:</p>
		 *
		 * <listing version="3.0">
		 * textEditor.fontWeight = FontWeight.BOLD;</listing>
		 *
		 * @default false
		 */
		public function get displayAsPassword():Boolean
		{
			return this._displayAsPassword;
		}

		/**
		 * @private
		 */
		public function set displayAsPassword(value:Boolean):void
		{
			if(this._displayAsPassword == value)
			{
				return;
			}
			this._displayAsPassword = value;
			this.invalidate(INVALIDATION_FLAG_STYLES);
		}

		/**
		 * @private
		 */
		protected var _maxChars:int = 0;

		/**
		 * Same as the <code>flash.text.TextField</code> property with the same name.
		 *
		 * <p>In the following example, the maximum character count is changed:</p>
		 *
		 * <listing version="3.0">
		 * textEditor.maxChars = 10;</listing>
		 *
		 * @default 0
		 */
		public function get maxChars():int
		{
			return this._maxChars;
		}

		/**
		 * @private
		 */
		public function set maxChars(value:int):void
		{
			if(this._maxChars == value)
			{
				return;
			}
			this._maxChars = value;
			this.invalidate(INVALIDATION_FLAG_STYLES);
		}

		/**
		 * @private
		 */
		protected var _restrict:String;

		/**
		 * Same as the <code>flash.text.TextField</code> property with the same name.
		 *
		 * <p>In the following example, the text is restricted to numbers:</p>
		 *
		 * <listing version="3.0">
		 * textEditor.restrict = "0-9";</listing>
		 *
		 * @default null
		 */
		public function get restrict():String
		{
			return this._restrict;
		}

		/**
		 * @private
		 */
		public function set restrict(value:String):void
		{
			if(this._restrict == value)
			{
				return;
			}
			this._restrict = value;
			this.invalidate(INVALIDATION_FLAG_STYLES);
		}

		/**
		 * @private
		 */
		protected var _isEditable:Boolean = true;

		/**
		 * Determines if the text input is editable. If the text input is not
		 * editable, it will still appear enabled.
		 *
		 * <p>In the following example, the text is not editable:</p>
		 *
		 * <listing version="3.0">
		 * textEditor.isEditable = false;</listing>
		 *
		 * @default true
		 */
		public function get isEditable():Boolean
		{
			return this._isEditable;
		}

		/**
		 * @private
		 */
		public function set isEditable(value:Boolean):void
		{
			if(this._isEditable == value)
			{
				return;
			}
			this._isEditable = value;
			this.invalidate(INVALIDATION_FLAG_STYLES);
		}

		/**
		 * @inheritDoc
		 */
		public function get setTouchFocusOnEndedPhase():Boolean
		{
			return false;
		}

		/**
		 * @private
		 */
		protected var _textFieldHasFocus:Boolean = false;

		/**
		 * @private
		 */
		protected var _isWaitingToSetFocus:Boolean = false;

		/**
		 * @private
		 */
		protected var _pendingSelectionStartIndex:int = -1;

		/**
		 * @private
		 */
		protected var _pendingSelectionEndIndex:int = -1;

		/**
		 * @private
		 */
		protected var resetScrollOnFocusOut:Boolean = true;

		/**
		 * @private
		 */
		override public function dispose():void
		{
			this.disposeContent();
			super.dispose();
		}

		/**
		 * @private
		 */
		override public function render(support:RenderSupport, parentAlpha:Number):void
		{
			//theoretically, this will ensure that the TextField is set visible
			//or invisible immediately after the snapshot changes visibility in
			//the rendered graphics. the OS might take longer to do the change,
			//though.
			var isTextFieldVisible:Boolean = this.textSnapshot ? !this.textSnapshot.visible : this._textFieldHasFocus;
			this.textField.visible = isTextFieldVisible;

			this.transformTextField();
			this.positionSnapshot();

			super.render(support, parentAlpha);
		}

		/**
		 * @inheritDoc
		 */
		public function setFocus(position:Point = null):void
		{
			if(this.textField)
			{
				if(!this.textField.parent)
				{
					Starling.current.nativeStage.addChild(this.textField);
				}
				if(position)
				{
					const positionX:Number = position.x;
					const positionY:Number = position.y;
					if(positionX < 0)
					{
						this._pendingSelectionStartIndex = this._pendingSelectionEndIndex = 0;
					}
					else
					{
						this._pendingSelectionStartIndex = this.textField.getCharIndexAtPoint(positionX, positionY);
						if(this._pendingSelectionStartIndex < 0)
						{
							if(this._multiline)
							{
								const lineIndex:int = int(positionY / this.textField.getLineMetrics(0).height) + (this.textField.scrollV - 1);
								try
								{
									this._pendingSelectionStartIndex = this.textField.getLineOffset(lineIndex) + this.textField.getLineLength(lineIndex);
									if(this._pendingSelectionStartIndex != this._text.length)
									{
										this._pendingSelectionStartIndex--;
									}
								}
								catch(error:Error)
								{
									//we may be checking for a line beyond the
									//end that doesn't exist
									this._pendingSelectionStartIndex = this._text.length;
								}
							}
							else
							{
								this._pendingSelectionStartIndex = this._text.length;
							}
						}
						else
						{
							var bounds:Rectangle = this.textField.getCharBoundaries(this._pendingSelectionStartIndex);
							//bounds should never be null because the character
							//index passed to getCharBoundaries() comes from a
							//call to getCharIndexAtPoint(). however, a user
							//reported that a null reference error happened
							//here! I couldn't reproduce, but I might as well
							//assume that the runtime has a bug. won't hurt.
							if(bounds)
							{
								var boundsX:Number = bounds.x;
								if(bounds && (boundsX + bounds.width - positionX) < (positionX - boundsX))
								{
									this._pendingSelectionStartIndex++;
								}
							}
						}
						this._pendingSelectionEndIndex = this._pendingSelectionStartIndex;
					}
				}
				else
				{
					this._pendingSelectionStartIndex = this._pendingSelectionEndIndex = -1;
				}
				if(!this._focusManager)
				{
					Starling.current.nativeStage.focus = this.textField;
				}
				this.textField.requestSoftKeyboard();
			}
			else
			{
				this._isWaitingToSetFocus = true;
			}
		}

		/**
		 * @inheritDoc
		 */
		public function clearFocus():void
		{
			if(!this._textFieldHasFocus || this._focusManager)
			{
				return;
			}
			Starling.current.nativeStage.focus = Starling.current.nativeStage;
			this.dispatchEventWith(FeathersEventType.FOCUS_OUT);
		}

		/**
		 * @inheritDoc
		 */
		public function selectRange(startIndex:int, endIndex:int):void
		{
			if(this.textField)
			{
				this.validate();
				this.textField.setSelection(startIndex, endIndex);
			}
			else
			{
				this._pendingSelectionStartIndex = startIndex;
				this._pendingSelectionEndIndex = endIndex;
			}
		}

		/**
		 * @inheritDoc
		 */
		public function measureText(result:Point = null):Point
		{
			if(!result)
			{
				result = new Point();
			}

			if(!this.textField)
			{
				result.x = result.y = 0;
				return result;
			}

			const needsWidth:Boolean = isNaN(this.explicitWidth);
			const needsHeight:Boolean = isNaN(this.explicitHeight);
			if(!needsWidth && !needsHeight)
			{
				result.x = this.explicitWidth;
				result.y = this.explicitHeight;
				return result;
			}

			this.commit();

			result = this.measure(result);

			return result;
		}

		/**
		 * @private
		 */
		override protected function initialize():void
		{
			this.textField = new TextField();
			this.textField.needsSoftKeyboard = true;
			this.textField.addEventListener(flash.events.Event.CHANGE, textField_changeHandler);
			this.textField.addEventListener(FocusEvent.FOCUS_IN, textField_focusInHandler);
			this.textField.addEventListener(FocusEvent.FOCUS_OUT, textField_focusOutHandler);
			this.textField.addEventListener(KeyboardEvent.KEY_DOWN, textField_keyDownHandler);
			this.textField.addEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATE, textField_softKeyboardActivateHandler);
			this.textField.addEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_DEACTIVATE, textField_softKeyboardDeactivateHandler);

			this.measureTextField = new TextField();
			this.measureTextField.autoSize = TextFieldAutoSize.LEFT;
			this.measureTextField.selectable = false;
			this.measureTextField.mouseWheelEnabled = false;
			this.measureTextField.mouseEnabled = false;
		}

		/**
		 * @private
		 */
		override protected function draw():void
		{
			var sizeInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_SIZE);

			this.commit();

			sizeInvalid = this.autoSizeIfNeeded() || sizeInvalid;

			this.layout(sizeInvalid);
		}

		/**
		 * @private
		 */
		protected function commit():void
		{
			const stylesInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_STYLES);
			const dataInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_DATA);
			const stateInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_STATE);

			if(dataInvalid || stylesInvalid || stateInvalid)
			{
				this.commitStylesAndData(this.textField);
			}
		}

		/**
		 * If the component's dimensions have not been set explicitly, it will
		 * measure its content and determine an ideal size for itself. If the
		 * <code>explicitWidth</code> or <code>explicitHeight</code> member
		 * variables are set, those value will be used without additional
		 * measurement. If one is set, but not the other, the dimension with the
		 * explicit value will not be measured, but the other non-explicit
		 * dimension will still need measurement.
		 *
		 * <p>Calls <code>setSizeInternal()</code> to set up the
		 * <code>actualWidth</code> and <code>actualHeight</code> member
		 * variables used for layout.</p>
		 *
		 * <p>Meant for internal use, and subclasses may override this function
		 * with a custom implementation.</p>
		 */
		protected function autoSizeIfNeeded():Boolean
		{
			const needsWidth:Boolean = isNaN(this.explicitWidth);
			const needsHeight:Boolean = isNaN(this.explicitHeight);
			if(!needsWidth && !needsHeight)
			{
				return false;
			}

			this.measure(HELPER_POINT);
			return this.setSizeInternal(HELPER_POINT.x, HELPER_POINT.y, false);
		}

		/**
		 * @private
		 */
		protected function measure(result:Point = null):Point
		{
			if(!result)
			{
				result = new Point();
			}

			const needsWidth:Boolean = isNaN(this.explicitWidth);
			const needsHeight:Boolean = isNaN(this.explicitHeight);

			if(!needsWidth && !needsHeight)
			{
				result.x = this.explicitWidth;
				result.y = this.explicitHeight;
				return result;
			}

			this.commitStylesAndData(this.measureTextField);
			var newWidth:Number = this.explicitWidth;
			if(needsWidth)
			{
				this.measureTextField.width = newWidth;
				newWidth = Math.max(this._minWidth, Math.min(this._maxWidth, this.measureTextField.textWidth + 4));
			}

			var newHeight:Number = this.explicitHeight;
			if(needsHeight)
			{
				this.measureTextField.width = newWidth;
				newHeight = Math.max(this._minHeight, Math.min(this._maxHeight, this.textField.textHeight + 4));
			}

			result.x = newWidth;
			result.y = newHeight;

			return result;
		}

		/**
		 * @private
		 */
		protected function commitStylesAndData(textField:TextField):void
		{
			textField.maxChars = this._maxChars;
			textField.restrict = this._restrict;
			textField.alwaysShowSelection = this._alwaysShowSelection;
			textField.displayAsPassword = this._displayAsPassword;
			textField.wordWrap = this._wordWrap;
			textField.multiline = this._multiline;
			textField.embedFonts = this._embedFonts;
			textField.type = this._isEditable ? TextFieldType.INPUT : TextFieldType.DYNAMIC;
			textField.selectable = this._isEnabled;
			if(this._textFormat)
			{
				textField.defaultTextFormat = this._textFormat;
			}
			if(this._isHTML)
			{
				if(textField.htmlText != this._text)
				{
					if(textField == this.textField && this._pendingSelectionStartIndex < 0)
					{
						this._pendingSelectionStartIndex = this.textField.selectionBeginIndex;
						this._pendingSelectionEndIndex = this.textField.selectionEndIndex;
					}
					textField.htmlText = this._text;
				}
			}
			else
			{
				if(textField.text != this._text)
				{
					if(textField == this.textField && this._pendingSelectionStartIndex < 0)
					{
						this._pendingSelectionStartIndex = this.textField.selectionBeginIndex;
						this._pendingSelectionEndIndex = this.textField.selectionEndIndex;
					}
					textField.text = this._text;
				}
			}
		}

		/**
		 * @private
		 */
		protected function layout(sizeInvalid:Boolean):void
		{
			const stylesInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_STYLES);
			const dataInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_DATA);

			if(sizeInvalid)
			{
				this.refreshSnapshotParameters();
				this.refreshTextFieldSize();
				this.transformTextField();
				this.positionSnapshot();
			}

			this.checkIfNewSnapshotIsNeeded();

			if(!this._textFieldHasFocus && (stylesInvalid || dataInvalid || this._needsNewTexture))
			{
				//we need to wait a frame for the flash.text.TextField to render
				//properly. sometimes two, and this is a known issue.
				this.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			}
			this.doPendingActions();
		}

		/**
		 * @private
		 */
		protected function refreshTextFieldSize():void
		{
			this.textField.width = this.actualWidth;
			this.textField.height = this.actualHeight;
		}

		/**
		 * @private
		 */
		protected function refreshSnapshotParameters():void
		{
			this._textFieldOffsetX = 0;
			this._textFieldOffsetY = 0;
			this._textFieldClipRect.x = 0;
			this._textFieldClipRect.y = 0;

			this.getTransformationMatrix(this.stage, HELPER_MATRIX);
			this._textFieldClipRect.width = this.actualWidth * Starling.contentScaleFactor * matrixToScaleX(HELPER_MATRIX);
			this._textFieldClipRect.height = this.actualHeight * Starling.contentScaleFactor * matrixToScaleY(HELPER_MATRIX);
		}

		/**
		 * @private
		 */
		protected function transformTextField():void
		{
			if(!this.textField.visible)
			{
				return;
			}
			HELPER_POINT.x = HELPER_POINT.y = 0;
			this.getTransformationMatrix(this.stage, HELPER_MATRIX);
			MatrixUtil.transformCoords(HELPER_MATRIX, 0, 0, HELPER_POINT);
			var starlingViewPort:Rectangle = Starling.current.viewPort;
			var nativeScaleFactor:Number = 1;
			if(Starling.current.supportHighResolutions)
			{
				nativeScaleFactor = Starling.current.nativeStage.contentsScaleFactor;
			}
			var scaleFactor:Number = Starling.contentScaleFactor / nativeScaleFactor;
			this.textField.x = Math.round(starlingViewPort.x + (HELPER_POINT.x * scaleFactor));
			this.textField.y = Math.round(starlingViewPort.y + (HELPER_POINT.y * scaleFactor));
			this.textField.rotation = matrixToRotation(HELPER_MATRIX) * 180 / Math.PI;
			scaleFactor = Starling.contentScaleFactor;
			this.textField.scaleX = matrixToScaleX(HELPER_MATRIX) * scaleFactor;
			this.textField.scaleY = matrixToScaleY(HELPER_MATRIX) * scaleFactor;
		}

		/**
		 * @private
		 */
		protected function positionSnapshot():void
		{
			if(!this.textSnapshot)
			{
				return;
			}
			this.getTransformationMatrix(this.stage, HELPER_MATRIX);
			this.textSnapshot.x = Math.round(HELPER_MATRIX.tx) - HELPER_MATRIX.tx;
			this.textSnapshot.y = Math.round(HELPER_MATRIX.ty) - HELPER_MATRIX.ty;
		}

		/**
		 * @private
		 */
		protected function checkIfNewSnapshotIsNeeded():void
		{
			this._snapshotWidth = getNextPowerOfTwo(this._textFieldClipRect.width);
			this._snapshotHeight = getNextPowerOfTwo(this._textFieldClipRect.height);
			const textureRoot:ConcreteTexture = this.textSnapshot ? this.textSnapshot.texture.root : null;
			this._needsNewTexture = this._needsNewTexture || !this.textSnapshot || this._snapshotWidth != textureRoot.width || this._snapshotHeight != textureRoot.height;
		}

		/**
		 * @private
		 */
		protected function doPendingActions():void
		{
			if(this._isWaitingToSetFocus)
			{
				this._isWaitingToSetFocus = false;
				this.setFocus();
			}

			if(this._pendingSelectionStartIndex >= 0)
			{
				var startIndex:int = this._pendingSelectionStartIndex;
				var endIndex:int = this._pendingSelectionEndIndex;
				this._pendingSelectionStartIndex = -1;
				this._pendingSelectionEndIndex = -1;
				this.selectRange(startIndex, endIndex);
			}
		}

		/**
		 * @private
		 */
		protected function texture_onRestore():void
		{
			this.refreshSnapshot();
		}

		/**
		 * @private
		 */
		protected function refreshSnapshot():void
		{
			if(this.textField.width == 0 || this.textField.height == 0)
			{
				return;
			}
			this.getTransformationMatrix(this.stage, HELPER_MATRIX);
			var globalScaleX:Number = matrixToScaleX(HELPER_MATRIX);
			var globalScaleY:Number = matrixToScaleY(HELPER_MATRIX);
			var scaleFactor:Number = Starling.contentScaleFactor;
			HELPER_MATRIX.identity();
			HELPER_MATRIX.translate(this._textFieldOffsetX, this._textFieldOffsetY);
			HELPER_MATRIX.scale(scaleFactor * globalScaleX, scaleFactor * globalScaleY);
			var bitmapData:BitmapData = new BitmapData(this._snapshotWidth, this._snapshotHeight, true, 0x00ff00ff);
			bitmapData.draw(this.textField, HELPER_MATRIX, null, null, this._textFieldClipRect);
			var newTexture:Texture;
			if(!this.textSnapshot || this._needsNewTexture)
			{
				newTexture = Texture.fromBitmapData(bitmapData, false, false, Starling.contentScaleFactor);
				newTexture.root.onRestore = texture_onRestore;
			}
			if(!this.textSnapshot)
			{
				this.textSnapshot = new Image(newTexture);
				this.addChild(this.textSnapshot);
			}
			else
			{
				if(this._needsNewTexture)
				{
					this.textSnapshot.texture.dispose();
					this.textSnapshot.texture = newTexture;
					this.textSnapshot.readjustSize();
				}
				else
				{
					//this is faster, if we haven't resized the bitmapdata
					const existingTexture:Texture = this.textSnapshot.texture;
					existingTexture.root.uploadBitmapData(bitmapData);
				}
			}
			this.getTransformationMatrix(this.stage, HELPER_MATRIX);
			this.textSnapshot.scaleX = 1 / matrixToScaleX(HELPER_MATRIX);
			this.textSnapshot.scaleY = 1 / matrixToScaleY(HELPER_MATRIX);
			bitmapData.dispose();
			this._needsNewTexture = false;
		}

		/**
		 * @private
		 */
		protected function disposeContent():void
		{
			if(this.textSnapshot)
			{
				//avoid the need to call dispose(). we'll create a new snapshot
				//when the renderer is added to stage again.
				this.textSnapshot.texture.dispose();
				this.removeChild(this.textSnapshot, true);
				this.textSnapshot = null;
			}

			if(this.textField.parent)
			{
				Starling.current.nativeStage.removeChild(this.textField);
			}
		}

		/**
		 * @private
		 */
		protected function addedToStageHandler(event:Event):void
		{
			//we need to invalidate in order to get a fresh snapshot
			this.invalidate(INVALIDATION_FLAG_DATA);
		}

		/**
		 * @private
		 */
		protected function removedFromStageHandler(event:Event):void
		{
			this.disposeContent();
		}

		/**
		 * @private
		 */
		protected function enterFrameHandler(event:Event):void
		{
			this.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			this.refreshSnapshot();
			if(this.textSnapshot)
			{
				this.textSnapshot.visible = !this._textFieldHasFocus;
				this.textSnapshot.alpha = this._text.length > 0 ? 1 : 0;
			}
		}

		/**
		 * @private
		 */
		protected function textField_changeHandler(event:flash.events.Event):void
		{
			this.text = this.textField.text;
		}

		/**
		 * @private
		 */
		protected function textField_focusInHandler(event:FocusEvent):void
		{
			this._textFieldHasFocus = true;
			if(this.textSnapshot)
			{
				this.textSnapshot.visible = false;
			}
			this.invalidate(INVALIDATION_FLAG_SKIN);
			this.dispatchEventWith(FeathersEventType.FOCUS_IN);
		}

		/**
		 * @private
		 */
		protected function textField_focusOutHandler(event:FocusEvent):void
		{
			this._textFieldHasFocus = false;

			if(this.resetScrollOnFocusOut)
			{
				this.textField.scrollH = this.textField.scrollV = 0;
			}

			this.invalidate(INVALIDATION_FLAG_DATA);
			this.invalidate(INVALIDATION_FLAG_SKIN);
			this.dispatchEventWith(FeathersEventType.FOCUS_OUT);
		}

		/**
		 * @private
		 */
		protected function textField_keyDownHandler(event:KeyboardEvent):void
		{
			if(event.keyCode == Keyboard.ENTER)
			{
				this.dispatchEventWith(FeathersEventType.ENTER);
			}
		}

		/**
		 * @private
		 */
		protected function textField_softKeyboardActivateHandler(event:SoftKeyboardEvent):void
		{
			this.dispatchEventWith(FeathersEventType.SOFT_KEYBOARD_ACTIVATE, true);
		}

		/**
		 * @private
		 */
		protected function textField_softKeyboardDeactivateHandler(event:SoftKeyboardEvent):void
		{
			this.dispatchEventWith(FeathersEventType.SOFT_KEYBOARD_DEACTIVATE, true);
		}
	}
}
