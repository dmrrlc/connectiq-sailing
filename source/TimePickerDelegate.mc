using Toybox.WatchUi;
using Toybox.Application;
using Toybox.System;
using Toybox.Lang;

//! Responds to a time picker selection or cancellation
class TimePickerDelegate extends WatchUi.PickerDelegate {

    //! Constructor
    public function initialize() {
        System.println("TimePickerDelegate: initialize");
        PickerDelegate.initialize();
    }

    //! Handle a cancel event from the picker
    //! @return true if handled, false otherwise
    public function onCancel() as Lang.Boolean {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        return true;
    }

    //! Handle a confirm event from the picker
    //! @param values The values chosen in the picker
    //! @return true if handled, false otherwise
    public function onAccept(values as Lang.Array) as Lang.Boolean {
        System.println("TimePickerDelegate: onAccept");
        Application.getApp().setDefaultTimerCount(values[0]);
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        return true;
    }
}
