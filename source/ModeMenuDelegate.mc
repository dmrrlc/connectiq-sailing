using Toybox.WatchUi as Ui;
using Toybox.Application as App;

class ModeMenuDelegate extends Ui.MenuInputDelegate {

    function initialize() {
        MenuInputDelegate.initialize();
    }

    function onMenuItem(item) {
        if (item == :mode_standard) {
            App.getApp().setMode(MODE_TYPE_STANDARD);
        } else if (item == :mode_dynamic) {
            App.getApp().setMode(MODE_TYPE_DYNAMIC);
        }
    }

}
