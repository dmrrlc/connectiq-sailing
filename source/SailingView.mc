using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Application as App;
using Toybox.WatchUi as Ui;

class SailingView extends Ui.WatchFace {

    //! Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
        // init timer
        m_timer = new Timer.Timer();
        // load default timer count
        m_timerDefaultCount = App.getApp().getDefaultTimerCount();
        m_timerCount = m_timerDefaultCount;
        // load default repeat state
        m_repeat = App.getApp().getRepeat();
    }

    //! Called when this View is brought to the foreground. Restore
    //! the state of this View and prepare it to be shown. This includes
    //! loading resources into memory.
    function onShow() {
    }

    //! Update the view
    function onUpdate(dc) {
        var min = 0;
        var sec = m_timerCount;
        
        while (sec > 59) {
            min += 1;
            sec -= 60;
        }
        
    
        var string;
        if(min > 0) {
	        if (sec > 9) {
	            string = "" + min + ":" + sec;
	        } else {
	            string = "" + min + ":0" + sec + "";
	        }
        }else {
	            string = "" + sec + "";
        }
        
        // flip foreground and background colors based on invert colors boolean
        if (!m_invertColors) {
            dc.setColor( Gfx.COLOR_TRANSPARENT, Gfx.COLOR_BLACK );
        } else {
            dc.setColor( Gfx.COLOR_TRANSPARENT, Gfx.COLOR_WHITE );
        }
        dc.clear();
        if (!m_invertColors) {
            dc.setColor( Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT );
        } else {
            dc.setColor( Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT );
        }
        
		
	        // display time
	        dc.drawText( (dc.getWidth() / 2), (dc.getHeight() / 2) - 60, Gfx.FONT_NUMBER_THAI_HOT, string, Gfx.TEXT_JUSTIFY_CENTER );
        
        // display status
        if (m_timerReachedZero) {
            dc.drawText( (dc.getWidth() / 2), (dc.getHeight() / 2) + 45, Gfx.FONT_MEDIUM, "COMPLETE", Gfx.TEXT_JUSTIFY_CENTER );
            m_invertColors = !m_invertColors;
        } else if (!m_timerRunning) {
            dc.drawText( (dc.getWidth() / 2), (dc.getHeight() / 2) + 45, Gfx.FONT_MEDIUM, "PAUSED", Gfx.TEXT_JUSTIFY_CENTER );
        } else if (m_repeat) {
            dc.setColor( Gfx.COLOR_YELLOW, Gfx.COLOR_TRANSPARENT );
            dc.drawText( (dc.getWidth() / 2), (dc.getHeight() / 2) + 45, Gfx.FONT_MEDIUM, "REPEAT ON", Gfx.TEXT_JUSTIFY_CENTER );
        }
    }

    //! Called when this View is removed from the screen. Save the
    //! state of this View here. This includes freeing resources from
    //! memory.
    function onHide() {
    }

    //! The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
    }

    //! Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    }

}
