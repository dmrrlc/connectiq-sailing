import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

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
    public function onUpdate(dc as Dc) as Void {
        System.println("TimePicker: onUpdate");
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        Picker.onUpdate(dc);
    }
}

//! Responds to a time picker selection or cancellation
class TimePickerDelegate extends WatchUi.PickerDelegate {

    //! Constructor
    public function initialize() {
        System.println("TimePickerDelegate: initialize");
        PickerDelegate.initialize();
    }

    //! Handle a cancel event from the picker
    //! @return true if handled, false otherwise
    public function onCancel() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        return true;
    }

    //! Handle a confirm event from the picker
    //! @param values The values chosen in the picker
    //! @return true if handled, false otherwise
    (:typecheck(false))
    public function onAccept(values as Array<Number?>) as Boolean {
        System.println("TimePickerDelegate: onAccept");
        Application.getApp().setDefaultTimerCount(values[0]);
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        return true;
    }
}
