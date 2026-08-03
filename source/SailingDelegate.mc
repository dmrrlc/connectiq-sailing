using Toybox.WatchUi as Ui;
using Toybox.Application as App;


class SailingDelegate extends Ui.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onKey(evt){
        if (evt.getKey() == WatchUi.KEY_ESC){
            Ui.pushView(new Rez.Menus.StopMenu(), new ExitMenuDelegate(), Ui.SLIDE_UP);
            Ui.requestUpdate();
            return true;
        }
        return false;
    }

    function onSelect(){
            App.getApp().startStopTimer();
            Ui.requestUpdate();
            return true;
    }

    function onBack(){
            Ui.pushView(new Rez.Menus.StopMenu(), new ExitMenuDelegate(), Ui.SLIDE_UP);
            Ui.requestUpdate();
            return true;
    }

    function onMenu(){
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
