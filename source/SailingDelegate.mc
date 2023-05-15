import Toybox.WatchUi;
import Toybox.System;
import Toybox.Application;


class SailingDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onKey(evt){
        System.println("SailingDelegate: onKey: evt : " + evt);
        if (evt.getKey() == WatchUi.KEY_ESC){
            System.println("SailingDelegate: back pressed (from event)");
            WatchUi.pushView(new Rez.Menus.StopMenu(), new ExitMenuDelegate(), WatchUi.SLIDE_UP);
            WatchUi.requestUpdate();
            return true;
        }
        return false;
    }

    function onSelect(){
            System.println("SailingDelegate: onSelect");
            Application.getApp().startStopTimer();
            WatchUi.requestUpdate();
            return true;
    }

    function onBack(){
            System.println("SailingDelegate: onBack");
            WatchUi.pushView(new Rez.Menus.StopMenu(), new ExitMenuDelegate(), WatchUi.SLIDE_UP);
            WatchUi.requestUpdate();
            return true;
    }

    function onMenu(){
            System.println("SailingDelegate: onMenu");
            WatchUi.pushView(new Rez.Menus.MainMenu(), new SailingMenuDelegate(), WatchUi.SLIDE_UP);
            WatchUi.requestUpdate();
            return true;
    }

    function onPreviousPage(){
            System.println("SailingDelegate: onPreviousPage");
            Application.getApp().fixTimeUp();
            return true;
    }

    function onNextPage(){
            System.println("SailingDelegate: onNextPage");
            Application.getApp().fixTimeDown();
            return true;
    }
}
