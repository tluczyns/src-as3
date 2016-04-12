/*
Feathers
Copyright 2012-2014 Joshua Tynjala. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.controls
{
	import feathers.controls.supportClasses.LayoutViewPort;
	import feathers.layout.ILayout;
	import feathers.layout.IVirtualLayout;

	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;

	/**
	 * Dispatched when the container is scrolled.
	 *
	 * @eventType starling.events.Event.SCROLL
	 */
	[Event(name="change",type="starling.events.Event")]

	[DefaultProperty("mxmlContent")]
	/**
	 * A generic container that supports layout, scrolling, and a background
	 * skin. For a lighter container, see <code>LayoutGroup</code>, which
	 * focuses specifically on layout without scrolling.
	 *
	 * <p>The following example creates a scroll container with a horizontal
	 * layout and adds two buttons to it:</p>
	 *
	 * <listing version="3.0">
	 * var container:ScrollContainer = new ScrollContainer();
	 * var layout:HorizontalLayout = new HorizontalLayout();
	 * layout.gap = 20;
	 * layout.padding = 20;
	 * container.layout = layout;
	 * this.addChild( container );
	 *
	 * var yesButton:Button = new Button();
	 * yesButton.label = "Yes";
	 * container.addChild( yesButton );
	 *
	 * var noButton:Button = new Button();
	 * noButton.label = "No";
	 * container.addChild( noButton );</listing>
	 *
	 * @see http://wiki.starling-framework.org/feathers/scroll-container
	 * @see feathers.controls.LayoutGroup
	 */
	public class ScrollContainer extends Scroller implements IScrollContainer
	{
		/**
		 * @private
		 */
		protected static const INVALIDATION_FLAG_MXML_CONTENT:String = "mxmlContent";

		/**
		 * An alternate name to use with <code>ScrollContainer</code> to allow a
		 * theme to give it a toolbar style. If a theme does not provide a skin
		 * for the toolbar style, the theme will automatically fall back to
		 * using the default scroll container skin.
		 *
		 * <p>An alternate name should always be added to a component's
		 * <code>nameList</code> before the component is added to the stage for
		 * the first time. If it is added later, it will be ignored.</p>
		 *
		 * <p>In the following example, the toolbar style is applied to a scroll
		 * container:</p>
		 *
		 * <listing version="3.0">
		 * var container:ScrollContainer = new ScrollContainer();
		 * container.nameList.add( ScrollContainer.ALTERNATE_NAME_TOOLBAR );
		 * this.addChild( container );</listing>
		 *
		 * @see feathers.core.IFeathersControl#nameList
		 */
		public static const ALTERNATE_NAME_TOOLBAR:String = "feathers-toolbar-scroll-container";

		/**
		 * @copy feathers.controls.Scroller#SCROLL_POLICY_AUTO
		 *
		 * @see feathers.controls.Scroller#horizontalScrollPolicy
		 * @see feathers.controls.Scroller#verticalScrollPolicy
		 */
		public static const SCROLL_POLICY_AUTO:String = "auto";

		/**
		 * @copy feathers.controls.Scroller#SCROLL_POLICY_ON
		 *
		 * @see feathers.controls.Scroller#horizontalScrollPolicy
		 * @see feathers.controls.Scroller#verticalScrollPolicy
		 */
		public static const SCROLL_POLICY_ON:String = "on";

		/**
		 * @copy feathers.controls.Scroller#SCROLL_POLICY_OFF
		 *
		 * @see feathers.controls.Scroller#horizontalScrollPolicy
		 * @see feathers.controls.Scroller#verticalScrollPolicy
		 */
		public static const SCROLL_POLICY_OFF:String = "off";

		/**
		 * @copy feathers.controls.Scroller#SCROLL_BAR_DISPLAY_MODE_FLOAT
		 *
		 * @see feathers.controls.Scroller#scrollBarDisplayMode
		 */
		public static const SCROLL_BAR_DISPLAY_MODE_FLOAT:String = "float";

		/**
		 * @copy feathers.controls.Scroller#SCROLL_BAR_DISPLAY_MODE_FIXED
		 *
		 * @see feathers.controls.Scroller#scrollBarDisplayMode
		 */
		public static const SCROLL_BAR_DISPLAY_MODE_FIXED:String = "fixed";

		/**
		 * @copy feathers.controls.Scroller#SCROLL_BAR_DISPLAY_MODE_NONE
		 *
		 * @see feathers.controls.Scroller#scrollBarDisplayMode
		 */
		public static const SCROLL_BAR_DISPLAY_MODE_NONE:String = "none";

		/**
		 * The vertical scroll bar will be positioned on the right.
		 *
		 * @see feathers.controls.Scroller#verticalScrollBarPosition
		 */
		public static const VERTICAL_SCROLL_BAR_POSITION_RIGHT:String = "right";

		/**
		 * The vertical scroll bar will be positioned on the left.
		 *
		 * @see feathers.controls.Scroller#verticalScrollBarPosition
		 */
		public static const VERTICAL_SCROLL_BAR_POSITION_LEFT:String = "left";

		/**
		 * @copy feathers.controls.Scroller#INTERACTION_MODE_TOUCH
		 *
		 * @see feathers.controls.Scroller#interactionMode
		 */
		public static const INTERACTION_MODE_TOUCH:String = "touch";

		/**
		 * @copy feathers.controls.Scroller#INTERACTION_MODE_MOUSE
		 *
		 * @see feathers.controls.Scroller#interactionMode
		 */
		public static const INTERACTION_MODE_MOUSE:String = "mouse";

		/**
		 * @copy feathers.controls.Scroller#INTERACTION_MODE_TOUCH_AND_SCROLL_BARS
		 *
		 * @see feathers.controls.Scroller#interactionMode
		 */
		public static const INTERACTION_MODE_TOUCH_AND_SCROLL_BARS:String = "touchAndScrollBars";

		/**
		 * Constructor.
		 */
		public function ScrollContainer()
		{
			super();
			this.layoutViewPort = new LayoutViewPort();
			this.viewPort = this.layoutViewPort;
		}

		/**
		 * A flag that indicates if the display list functions like <code>addChild()</code>
		 * and <code>removeChild()</code> will be passed to the internal view
		 * port.
		 */
		protected var displayListBypassEnabled:Boolean = true;

		/**
		 * @private
		 */
		protected var layoutViewPort:LayoutViewPort;

		/**
		 * @private
		 */
		protected var _layout:ILayout;

		/**
		 * Controls the way that the container's children are positioned and
		 * sized.
		 *
		 * <p>The following example tells the container to use a horizontal layout:</p>
		 *
		 * <listing version="3.0">
		 * var layout:HorizontalLayout = new HorizontalLayout();
		 * layout.gap = 20;
		 * layout.padding = 20;
		 * container.layout = layout;</listing>
		 *
		 * @default null
		 */
		public function get layout():ILayout
		{
			return this._layout;
		}

		/**
		 * @private
		 */
		public function set layout(value:ILayout):void
		{
			if(this._layout == value)
			{
				return;
			}
			this._layout = value;
			this.invalidate(INVALIDATION_FLAG_LAYOUT);
		}

		/**
		 * @private
		 */
		protected var _mxmlContentIsReady:Boolean = false;

		/**
		 * @private
		 */
		protected var _mxmlContent:Array;

		[ArrayElementType("feathers.core.IFeathersControl")]
		/**
		 * @private
		 */
		public function get mxmlContent():Array
		{
			return this._mxmlContent;
		}

		/**
		 * @private
		 */
		public function set mxmlContent(value:Array):void
		{
			if(this._mxmlContent == value)
			{
				return;
			}
			if(this._mxmlContent && this._mxmlContentIsReady)
			{
				const childCount:int = this._mxmlContent.length;
				for(var i:int = 0; i < childCount; i++)
				{
					var child:DisplayObject = DisplayObject(this._mxmlContent[i]);
					this.removeChild(child, true);
				}
			}
			this._mxmlContent = value;
			this._mxmlContentIsReady = false;
			this.invalidate(INVALIDATION_FLAG_MXML_CONTENT);
		}

		/**
		 * @private
		 */
		override public function get numChildren():int
		{
			if(!this.displayListBypassEnabled)
			{
				return super.numChildren;
			}
			return DisplayObjectContainer(this.viewPort).numChildren;
		}

		/**
		 * @inheritDoc
		 */
		public function get numRawChildren():int
		{
			var oldBypass:Boolean = this.displayListBypassEnabled;
			this.displayListBypassEnabled = false;
			var result:int = super.numChildren;
			this.displayListBypassEnabled = oldBypass;
			return result;
		}

		/**
		 * @private
		 */
		override public function getChildByName(name:String):DisplayObject
		{
			if(!this.displayListBypassEnabled)
			{
				return super.getChildByName(name);
			}
			return DisplayObjectContainer(this.viewPort).getChildByName(name);
		}

		/**
		 * @inheritDoc
		 */
		public function getRawChildByName(name:String):DisplayObject
		{
			var oldBypass:Boolean = this.displayListBypassEnabled;
			this.displayListBypassEnabled = false;
			var child:DisplayObject = super.getChildByName(name);
			this.displayListBypassEnabled = oldBypass;
			return child;
		}

		/**
		 * @private
		 */
		override public function getChildAt(index:int):DisplayObject
		{
			if(!this.displayListBypassEnabled)
			{
				return super.getChildAt(index);
			}
			return DisplayObjectContainer(this.viewPort).getChildAt(index);
		}

		/**
		 * @inheritDoc
		 */
		public function getRawChildAt(index:int):DisplayObject
		{
			var oldBypass:Boolean = this.displayListBypassEnabled;
			this.displayListBypassEnabled = false;
			var child:DisplayObject = super.getChildAt(index);
			this.displayListBypassEnabled = oldBypass;
			return child;
		}

		/**
		 * @inheritDoc
		 */
		public function addRawChild(child:DisplayObject):DisplayObject
		{
			var oldBypass:Boolean = this.displayListBypassEnabled;
			this.displayListBypassEnabled = false;
			if(child.parent == this)
			{
				super.setChildIndex(child, super.numChildren);
			}
			else
			{
				child = super.addChildAt(child, super.numChildren);
			}
			this.displayListBypassEnabled = oldBypass;
			return child;
		}

		/**
		 * @private
		 */
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject
		{
			if(!this.displayListBypassEnabled)
			{
				return super.addChildAt(child, index);
			}
			return DisplayObjectContainer(this.viewPort).addChildAt(child, index);
		}

		/**
		 * @inheritDoc
		 */
		public function addRawChildAt(child:DisplayObject, index:int):DisplayObject
		{
			var oldBypass:Boolean = this.displayListBypassEnabled;
			this.displayListBypassEnabled = false;
			child = super.addChildAt(child, index);
			this.displayListBypassEnabled = oldBypass;
			return child;
		}

		/**
		 * @inheritDoc
		 */
		public function removeRawChild(child:DisplayObject, dispose:Boolean = false):DisplayObject
		{
			var oldBypass:Boolean = this.displayListBypassEnabled;
			this.displayListBypassEnabled = false;
			var index:int = super.getChildIndex(child);
			if(index >= 0)
			{
				super.removeChildAt(index, dispose);
			}
			this.displayListBypassEnabled = oldBypass;
			return child;
		}

		/**
		 * @private
		 */
		override public function removeChildAt(index:int, dispose:Boolean = false):DisplayObject
		{
			if(!this.displayListBypassEnabled)
			{
				return super.removeChildAt(index, dispose);
			}
			return DisplayObjectContainer(this.viewPort).removeChildAt(index, dispose);
		}

		/**
		 * @inheritDoc
		 */
		public function removeRawChildAt(index:int, dispose:Boolean = false):DisplayObject
		{
			var oldBypass:Boolean = this.displayListBypassEnabled;
			this.displayListBypassEnabled = false;
			var child:DisplayObject =  super.removeChildAt(index, dispose);
			this.displayListBypassEnabled = oldBypass;
			return child;
		}

		/**
		 * @private
		 */
		override public function getChildIndex(child:DisplayObject):int
		{
			if(!this.displayListBypassEnabled)
			{
				return super.getChildIndex(child);
			}
			return DisplayObjectContainer(this.viewPort).getChildIndex(child);
		}

		/**
		 * @inheritDoc
		 */
		public function getRawChildIndex(child:DisplayObject):int
		{
			var oldBypass:Boolean = this.displayListBypassEnabled;
			this.displayListBypassEnabled = false;
			return super.getChildIndex(child);
			this.displayListBypassEnabled = oldBypass;
		}

		/**
		 * @private
		 */
		override public function setChildIndex(child:DisplayObject, index:int):void
		{
			if(!this.displayListBypassEnabled)
			{
				super.setChildIndex(child, index);
				return;
			}
			DisplayObjectContainer(this.viewPort).setChildIndex(child, index);
		}

		/**
		 * @inheritDoc
		 */
		public function setRawChildIndex(child:DisplayObject, index:int):void
		{
			var oldBypass:Boolean = this.displayListBypassEnabled;
			this.displayListBypassEnabled = false;
			super.setChildIndex(child, index);
			this.displayListBypassEnabled = oldBypass;
		}

		/**
		 * @inheritDoc
		 */
		public function swapRawChildren(child1:DisplayObject, child2:DisplayObject):void
		{
			var index1:int = this.getRawChildIndex(child1);
			var index2:int = this.getRawChildIndex(child2);
			if(index1 < 0 || index2 < 0)
			{
				throw new ArgumentError("Not a child of this container");
			}
			var oldBypass:Boolean = this.displayListBypassEnabled;
			this.displayListBypassEnabled = false;
			this.swapRawChildrenAt(index1, index2);
			this.displayListBypassEnabled = oldBypass;
		}

		/**
		 * @private
		 */
		override public function swapChildrenAt(index1:int, index2:int):void
		{
			if(!this.displayListBypassEnabled)
			{
				super.swapChildrenAt(index1, index2);
				return;
			}
			DisplayObjectContainer(this.viewPort).swapChildrenAt(index1, index2);
		}

		/**
		 * @inheritDoc
		 */
		public function swapRawChildrenAt(index1:int, index2:int):void
		{
			var oldBypass:Boolean = this.displayListBypassEnabled;
			this.displayListBypassEnabled = false;
			super.swapChildrenAt(index1, index2);
			this.displayListBypassEnabled = oldBypass;
		}

		/**
		 * @private
		 */
		override public function sortChildren(compareFunction:Function):void
		{
			if(!this.displayListBypassEnabled)
			{
				super.sortChildren(compareFunction);
				return;
			}
			DisplayObjectContainer(this.viewPort).sortChildren(compareFunction);
		}

		/**
		 * @inheritDoc
		 */
		public function sortRawChildren(compareFunction:Function):void
		{
			var oldBypass:Boolean = this.displayListBypassEnabled;
			this.displayListBypassEnabled = false;
			super.sortChildren(compareFunction);
			this.displayListBypassEnabled = oldBypass;
		}

		/**
		 * Readjusts the layout of the container according to its current
		 * content. Call this method when changes to the content cannot be
		 * automatically detected by the container. For instance, Feathers
		 * components dispatch <code>FeathersEventType.RESIZE</code> when their
		 * width and height values change, but standard Starling display objects
		 * like <code>Sprite</code> and <code>Image</code> do not.
		 */
		public function readjustLayout():void
		{
			this.layoutViewPort.readjustLayout();
			this.invalidate(INVALIDATION_FLAG_SIZE);
		}

		/**
		 * @private
		 */
		override protected function initialize():void
		{
			super.initialize();
			this.refreshMXMLContent();
		}

		/**
		 * @private
		 */
		override protected function draw():void
		{
			const sizeInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_SIZE);
			const stylesInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_STYLES);
			const stateInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_STATE);
			const layoutInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_LAYOUT);
			const mxmlContentInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_MXML_CONTENT);

			if(mxmlContentInvalid)
			{
				this.refreshMXMLContent();
			}

			if(layoutInvalid)
			{
				if(this._layout is IVirtualLayout)
				{
					IVirtualLayout(this._layout).useVirtualLayout = false;
				}
				this.layoutViewPort.layout = this._layout;
			}

			super.draw();
		}

		/**
		 * @private
		 */
		protected function refreshMXMLContent():void
		{
			if(!this._mxmlContent || this._mxmlContentIsReady)
			{
				return;
			}
			const childCount:int = this._mxmlContent.length;
			for(var i:int = 0; i < childCount; i++)
			{
				var child:DisplayObject = DisplayObject(this._mxmlContent[i]);
				this.addChild(child);
			}
			this._mxmlContentIsReady = true;
		}
	}
}
