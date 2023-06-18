using Toybox.Application as App;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

import Toybox.Lang;
import Toybox.Graphics;


//! Picker that allows the user to choose a time
class TimePicker extends Ui.Picker {

    //! Constructor
    public function initialize() {
        Sys.println("TimePicker: initialize");
        var title = new Ui.Text({
            :text=>"Time",
            :locX=>Ui.LAYOUT_HALIGN_CENTER,
            :locY=>Ui.LAYOUT_VALIGN_BOTTOM,
            :color=>Gfx.COLOR_WHITE});

        var factory = new TimeFactory(0, 30, 1, {});
        var time = App.getApp().getDefaultTimerCount();
        var index = factory.getIndex(time);

        Picker.initialize({:title=>title, :pattern=>[factory], :defaults=>[index]});
    }

    //! Update the view
    //! @param dc Device Context
    public function onUpdate(dc as Dc) as Void {
        Sys.println("TimePicker: onUpdate");
        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
        dc.clear();
        Picker.onUpdate(dc);
    }
}
