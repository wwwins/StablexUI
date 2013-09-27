package ru.stablex.ui.widgets;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.Lib;
import ru.stablex.ui.events.ScrollEvent;
import ru.stablex.ui.events.WidgetEvent;


/**
 * Add VScroll widget for ios scrolling effect.
 */
class VScroll extends Widget{

    //allow vertical scrolling
    public var vScroll : Bool = true;
    //allow scrolling by dragging
    public var dragScroll : Bool = true;

    /**
    * Container for content. Content is scrolled by moving this container.
    * This is always the first child of Scroll widget
    */
    public var box (get_box, never) : Widget;
    //vertical scroll bar
    public var vBar (default, set_vBar) : Widget;
	
    /**
    * For neko and html5 targets onMouseDown dispatched several times (depends on display list depth)
    * We want to process it only once
    */
    private var _processingDrag : Bool = false;

	// ios scrolling
    private var mouseY1:Float = 0;
    private var mouseY2:Float = 0;
    private var downStageY:Float = -1;
    private var downListY:Float = -1;
    private var moveY:Float = 0;

    /**
    * Constructor
    *  `.overflow` = false by default
    */
    public function new () : Void {
        super();
        this.overflow = false;
		
        this.vBar = UIBuilder.create(Widget);

        this.addUniqueListener(MouseEvent.MOUSE_DOWN, this._beforeScroll);
    }

    /**
    * Getter for `.box`
    *
    */
    private function get_box () : Widget {
        if( this.numChildren == 0 ){
            Err.trigger('Scroll widget must have at least one child.');
            return null;
        }else{

            var child : DisplayObject = this.getChildAt(0);
            if( !Std.is(child, Widget) ){
                Err.trigger('Instance of Widget must be the first child for Scroll widget');
            }
            return cast(child, Widget);
        }
    }

    /**
    * Setter for '.vBar'
    *
    */
    private function set_vBar(bar:Widget) : Widget {
        if( bar == null && this.vBar != null ){
            this.vBar.free();
        }
        return this.vBar = bar;
    }//function set_vBar()

    /**
    * Refresh container too
    *
    */
    override public function refresh () : Void {
        this.box.refresh();
        super.refresh();

        //vertical bar
        if( this.vBar != null ){
            this.addChildAt(this.vBar, 1);
			this.vBar.h = this.h - (this.box.h - this.h) * 0.5;
			if (this.vBar.h < 50) this.vBar.h = 50;
			if (this.vBar.h > this.h) this.vBar.h = this.h;
            this.vBar.refresh();
            //this.vBar.addUniqueListener(WidgetEvent.CHANGE, this._onVBarChange);
        }
    }

    /**
    * When user want to scroll, dispatch ScrollEvent.BEFORE_SCROLL
    *
    */
    private function _beforeScroll(e:MouseEvent) : Void {
        this.addUniqueListener(ScrollEvent.BEFORE_SCROLL, this._startScroll);

        var e : ScrollEvent = new ScrollEvent(ScrollEvent.BEFORE_SCROLL, e);
        this.dispatchEvent(e);
    }//function _beforeScroll()


    /**
    * Start scrolling
    *
    */
    private function _startScroll(e:ScrollEvent) : Void {
        this.removeEventListener(ScrollEvent.BEFORE_SCROLL, this._startScroll);

        //scrolling cancaled
        if( e.canceled ) return;

        //scrolling by drag
        if( e.srcEvent.type == MouseEvent.MOUSE_DOWN && this.dragScroll ){
            this._dragScroll( e.srcAs(MouseEvent) );
        }
    }


    /**
    * Start scroll by drag
    *
    */
    private function _dragScroll (e:MouseEvent) : Void {
        if( this._processingDrag ) return;
        this._processingDrag = true;

		var dy       : Float = this.mouseY - this.box.top;
        var lastX    : Float = this.mouseX;
        var lastY    : Float = this.mouseY;
        var lastDx   : Float = 0;
        var lastDy   : Float = 0;
        var startX   : Float = this.mouseX;
        var startY   : Float = this.mouseY;
        var scrolled : Bool = false;
        //allowed scroll directions
        var vScroll : Bool = (this.vScroll && this.box.h > this.h);

		// ios scrolling
        mouseY2 = this.box.top;
        mouseY1 = this.box.top;
        downStageY = e.stageY;
        downListY = this.box.top;

        //stop previous scrolling
		removeEventListener(Event.ENTER_FRAME, ent);
		
        //Looks like html5 target does not respect .mouseChildren
        #if html5
            var blocker : Sprite = new Sprite();
            blocker.graphics.beginFill(0x000000, 0);
            blocker.graphics.drawRect(0, 0, this.w, this.h);
            blocker.graphics.endFill();
        #end

        //follow mouse pointer
        var fn = function(e:Event) : Void {
            if( scrolled ){
				if (this.box.h > this.h) {
					if (this.box.h > this.h) vBar.visible = true;
				}
                if ( vScroll ) {
					//this.scrollY = this.mouseY - dy;
					//ios scrolling
					this.box.top = this.mouseY - dy;
					mouseY2 = mouseY1;
					mouseY1 = this.box.top;
					barEnt();
				}
            }
			else if ((vScroll && !scrolled && Math.abs(this.mouseY - startY) >= 5))
            {
				//if user realy wants to scroll instead of interacting with content,
				//disable processing mouse events by children
                #if html5 this.addChild(blocker); #end
				
                scrolled = true;
                this.box.mouseEnabled = false;
                this.box.mouseChildren = false;
                this.dispatchEvent(new WidgetEvent(WidgetEvent.SCROLL_START));
            }
			else {
				this.vBar.visible = false;
			}

        }//fn()

        //follow pointer
        this.addUniqueListener(Event.ENTER_FRAME, fn);

        //stop following
		var fnStop : MouseEvent->Void = null;
		fnStop = function(e:MouseEvent) : Void {
			this._processingDrag = false;

			this.removeEventListener(Event.ENTER_FRAME, fn);
			Lib.current.stage.removeEventListener(MouseEvent.MOUSE_UP, fnStop);

			if( scrolled ){
				#if html5 if( blocker.parent == this) this.removeChild(blocker); #end
				this.box.mouseEnabled  = true;
				this.box.mouseChildren = true;

				//ios scrolling
				downStageY = -1;
				downListY = -1;
				addUniqueListener(Event.ENTER_FRAME, ent);
				moveY = (mouseY1 - mouseY2) * (Std.int(Math.abs((mouseY1 - mouseY2) / 20)) + 1);

				// pull&push to refresh
				if ((this.box.top > this.h * 0.5) && (this.box.top < this.h)) {
					this.dispatchEvent(new WidgetEvent(WidgetEvent.SCROLL_PULL_TO_REFRESH));
					return;
				}
				if ((this.box.top < this.h * 0.5 - this.box.h) && (this.box.top > -this.box.h)) {
					this.dispatchEvent(new WidgetEvent(WidgetEvent.SCROLL_PUSH_TO_REFRESH));
					return;
				}

			}
		}//fnStop()

        //stop scrolling
        Lib.current.stage.removeEventListener(MouseEvent.MOUSE_UP, fnStop);
        Lib.current.stage.addEventListener(MouseEvent.MOUSE_UP, fnStop);
    }//function _dragScroll()

	// ----------- ios scrolling start --------- //
	private function ent(e:Event):Void {
        moveY *= 0.95;
		
        if (this.box.top > 0 || this.box.top < -this.box.h + this.h) moveY *= 0.5;
        if (Math.abs(moveY) < 0.1 && this.box.top > 0) { this.box.top -= this.box.top / 4; }
        if (Math.abs(moveY) < 0.1 && this.box.top < -this.box.h + Math.min(this.h, this.box.h)) { this.box.top += (Math.min(this.h, this.box.h) - (this.box.top + this.box.h)) / 4; }
        if (Math.abs(moveY) < 50) this.box.top += moveY;
        else this.box.top += moveY / Math.abs(moveY) * 50;
        if (Math.abs(moveY) < 0.1 && this.box.top <= 0 && (this.box.top >= -this.box.h + this.h || (this.h > this.box.h && this.box.top == 0))) {
            removeEventListener(Event.ENTER_FRAME, ent);
            vBar.visible = false;
			this.dispatchEvent(new WidgetEvent(WidgetEvent.SCROLL_STOP));
        }
		barEnt();
	}

    private function barEnt(e:Event = null):Void {
        vBar.top = -this.box.top / (this.box.h - this.h) * (this.h - this.vBar.h);
    }
	// ----------- ios scrolling end --------- \\
}//class Scroll
