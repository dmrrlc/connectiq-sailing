import Toybox.WatchUi;
import Toybox.Application;
import Toybox.System;

class SailingMenuDelegate extends WatchUi.MenuInputDelegate {

    function onMenuItem(item) {
        System.println("SailingMenuDelegate: onMenuItem: " + item);
        if (item == :start_timer) {
            System.println("SailingMenuDelegate: onMenuItem: start time pressed");
            Application.getApp().startTimer();
        } else if (item == :set_timer) {
            System.println("SailingMenuDelegate: onMenuItem: set timer pressed");
            if (WatchUi has :Picker) {
                WatchUi.pushView(new TimePicker(), new TimePickerDelegate(), WatchUi.SLIDE_UP);
            }
        }
    }

    function initialize() {
        System.println("SailingMenuDelegate: initialize");
        MenuInputDelegate.initialize();
    }
}
