using Toybox.WatchUi as Ui;
using Toybox.Application as App;
using Toybox.System as Sys;

//! Responds to a time picker selection or cancellation
class TimePickerDelegate extends Ui.PickerDelegate {

    //! Constructor
    public function initialize() {
        Sys.println("TimePickerDelegate: initialize");
        PickerDelegate.initialize();
    }

    //! Handle a cancel event from the picker
    //! @return true if handled, false otherwise
    public function onCancel() as Boolean {
        Ui.popView(Ui.SLIDE_IMMEDIATE);
        return true;
    }

    //! Handle a confirm event from the picker
    //! @param values The values chosen in the picker
    //! @return true if handled, false otherwise
    public function onAccept(values as Array<Number?>) as Boolean {
        Sys.println("TimePickerDelegate: onAccept");
        App.getApp().setDefaultTimerCount(values[0]);
        Ui.popView(Ui.SLIDE_IMMEDIATE);
        return true;
    }
}
