package jiglib.debug {
	import away3d.containers.View3D;

	import jiglib.physics.PhysicsSystem;
	import jiglib.plugin.away3d4.Away3D4Physics;

	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.system.System;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.getTimer;

	public class Stats extends Sprite {
		//private const WIDTH : uint = 182;
		//private const HEIGHT : uint = 126;
		private var textFpsLabel : TextField;
		private var textFps : TextField;
		private var textMsLabel : TextField;
		private var textMs : TextField;
		//private var textCDT : TextField;
		private var textBottomLeft : TextField;
		private var textBottomRight : TextField;
		private var textBottom : TextField;
		private var timer : uint;
		private var fps : uint;
		private var ms : uint;
		private var ms_prev : uint;
		private var mem : Number;
		private var mem_max : Number;
		private var statsSkinBm : Bitmap;
		private var physics : Away3D4Physics;
		// TODO only away3d4 atm
		private var view3d : View3D;
		// TODO only away3d4 atm
		private var grid : Boolean = false;
		[Embed(source="stats-skin.jpg")]
		private var StatsSkinBitmap : Class;

		/**
		 * Stats FPS, 3D, JIGLIB, MS and MEM, etc.
		 * CDC is Collision Dection Checks
		 * Rigid bodies - active (bodies) is bodies sleep
		 * info UPDATES once per second
		 */
		public function Stats(view3d : View3D, physics : Away3D4Physics, grid : Boolean = false) : void {
			this.view3d = view3d;
			this.physics = physics;
			this.grid = grid;
			// TODO: is temp var, make auto detection
			mem_max = 0;
			textFpsLabel = new TextField();
			textFps = new TextField();
			textMsLabel = new TextField();
			textMs = new TextField();
			textBottom = new TextField();
			textBottomLeft = new TextField();
			textBottomRight = new TextField();
			addTextField(textFpsLabel, 0xFFFFFF, 10, true, "left", 1, 10, 10);
			addTextField(textFps, 0x1abfff, 10, true, "left", 1, 40, 10);
			addTextField(textMsLabel, 0xFFFFFF, 10, true, "left", 1, 96, 10);
			addTextField(textMs, 0xffcc1a, 10, true, "left", 1, 135, 10, 44);
			addTextField(textBottomLeft, 0x000000, 10, true, "right", 6, 10, 65, 80, 36);
			addTextField(textBottomRight, 0x000000, 10, true, "left", 6, 88, 65, 80, 36);
			addTextField(textBottom, 0x000000, 10, true, "center", 0, 10, 101, 160, 14);

			// headers
			textFpsLabel.htmlText = "FPS:<br>CDC:<br>TRI.:";
			textMsLabel.htmlText = "TOTAL:<br>JIGLIB:<br>3D:";
			textBottom.htmlText = "CDT BRUTEFORCE";
			// TODO once we got a grid system

			// skin used
			statsSkinBm = new StatsSkinBitmap();

			// add listeners
			addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);
			addEventListener(Event.REMOVED_FROM_STAGE, destroy, false, 0, true);
		}

		private function init(e : Event) : void {
			addChild(statsSkinBm);
			addChild(textFpsLabel);
			addChild(textFps);
			addChild(textMsLabel);
			addChild(textMs);
			addChild(textBottomLeft);
			addChild(textBottomRight);
			addChild(textBottom);

			addEventListener(Event.ENTER_FRAME, update);
		}

		public function disableSkin() : void {
			removeChild(statsSkinBm);
		}

		private function update(e : Event) : void {
			timer = getTimer();

			if ( timer - 1000 > ms_prev ) {
				ms_prev = timer;
				mem = Number((System.totalMemory * 0.000000954).toFixed(2));
				mem_max = mem_max > mem ? mem_max : mem;

				fps = fps > stage.frameRate ? stage.frameRate : fps;

				textFps.htmlText = fps + " / " + stage.frameRate + "<br>" + PhysicsSystem.getInstance().getCollisionSystem().numCollisionsChecks + "<br>" + view3d.renderedFacesCount;

				// todo temp. till away3d got _deltatime avail.
				var ms3D : uint = (timer - ms) - physics.frameTime;

				textMs.htmlText = (timer - ms) + " ms<br>" + physics.frameTime + " ms<br>" + ms3D + " ms";
				textBottomLeft.htmlText = "MEM " + mem + "<br>RIGIDB. " + PhysicsSystem.getInstance().bodies.length;
				textBottomRight.htmlText = "/ MAX <font color='#cb2929'>" + mem_max + "</font><br>/ ACTIVE <font color='#cb2929'>" + PhysicsSystem.getInstance().activeBodies.length + "</font>";
				if (grid) {
					textBottom.htmlText = "CDT GRID";
				} else {
					textBottom.htmlText = "CDT BRUTEFORCE";
				}
				fps = 0;
			}
			fps++;
			ms = timer;
		}

		private function destroy(event : Event) : void {
			while (numChildren > 0)
				removeChildAt(0);

			removeEventListener(Event.ENTER_FRAME, update);
		}

		private function addTextField(text : TextField, colorText : uint, textSize : int, bold : Boolean, alignText : String, leading : int = 0, xPos : int = 0, yPos : int = 0, widthText : int = 52, heightText : int = 45) : void {
			text.x = xPos;
			text.y = yPos;
			// setup format
			var format : TextFormat = new TextFormat();
			format.font = "_sans";
			format.color = colorText;
			format.bold = bold;
			format.size = textSize;
			format.align = alignText;
			format.leading = leading;
			text.defaultTextFormat = format;
			// setup text
			text.antiAliasType = AntiAliasType.ADVANCED;
			text.multiline = true;
			text.width = widthText;
			text.height = heightText;
			text.selectable = false;
			text.mouseEnabled = false;
		}
	}
}