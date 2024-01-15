using Toybox.Application;
using Toybox.Graphics;
using Toybox.System;
using Toybox.WatchUi;
using Toybox.Lang;


//! Picker that allows the user to choose a time
class TimePicker extends WatchUi.Picker {

    //! Constructor
    public function initialize() {
        System.println("TimePicker: initialize");
        var title = new WatchUi.Text({
            :text=>"Time",
            :locX=>WatchUi.LAYOUT_HALIGN_CENTER,
            :locY=>WatchUi.LAYOUT_VALIGN_BOTTOM,
            :color=>Graphics.COLOR_WHITE});

        var factory = new TimeFactory(0, 30, 1, {});
        var time = Application.getApp().getDefaultTimerCount();
        var index = factory.getIndex(time);

        Picker.initialize({:title=>title, :pattern=>[factory], :defaults=>[index]});
    }

    //! Update the view
    //! @param dc Device Context
    public function onUpdate(dc as Graphics.Dc) as Void {
        System.println("TimePicker: onUpdate");
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        Picker.onUpdate(dc);
    }
}
