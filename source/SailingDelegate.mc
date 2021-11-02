using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Application as App;


class SailingDelegate extends Ui.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onKey(evt){
        Sys.println("key evt : " +evt);
        if (evt.getKey() == WatchUi.KEY_ESC){
            Sys.println("back pressed (from event)");
            Ui.pushView(new Rez.Menus.StopMenu(), new ExitMenuDelegate(), Ui.SLIDE_UP);
            Ui.requestUpdate();
            return true;
        }
        return false;
    }

    function onBack(){
            Sys.println("back pressed");
            Ui.pushView(new Rez.Menus.StopMenu(), new ExitMenuDelegate(), Ui.SLIDE_UP);
            Ui.requestUpdate();
            return true;
    }

    function onMenu(){
            Sys.println("menu pressed");
            Ui.pushView(new Rez.Menus.MainMenu(), new SailingMenuDelegate(), Ui.SLIDE_UP);
            Ui.requestUpdate();
            return true;
    }

    function onPreviousPage(){
            App.getApp().fixTimeUp();
            return true;
    }

    function onNextPage(){
            App.getApp().fixTimeDown();
            return true;
    }
}
