using Toybox.WatchUi as Ui;
using Toybox.Application as App;
using Toybox.System as Sys;

class SailingMenuDelegate extends Ui.MenuInputDelegate {

    function onMenuItem(item) {
        Sys.println("menu item selected");
        if (item == :start_timer) {
            Sys.println("start time pressed");
            App.getApp().startTimer();
        } else if (item == :set_timer) {
            Sys.println("set timer pressed");
            if (Ui has :Picker) {
                Ui.pushView(new TimePicker(), new TimePickerDelegate(), Ui.SLIDE_UP);
            }
        }
    }

    function initialize() {
        MenuInputDelegate.initialize();
    }
}
