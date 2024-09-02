using Toybox.WatchUi as Ui;
using Toybox.Application as App;
using Toybox.System as Sys;

class ModeMenuDelegate extends Ui.MenuInputDelegate {

    function initialize() {
        // Call the setMode function with the desired enum value
        MenuInputDelegate.initialize();
    }

    function onMenuItem(item) {
        Sys.println("onMenuItem: " + item);
        if (item == :mode_standard) {'
            Sys.println("selected standard mode");
            App.getApp().setMode(MODE_TYPE_STANDARD);
        } else if (item == :mode_dynamic) {
            Sys.println("selected dynamic mode");
            App.getApp().setMode(MODE_TYPE_DYNAMIC);
        }
    }

}