using Toybox.Graphics;
using Toybox.WatchUi;
using Toybox.System;
using Toybox.Lang;

//! Factory that controls which numbers can be picked
class TimeFactory extends WatchUi.PickerFactory {
    private var _start as Lang.Number;
    private var _stop as Lang.Number;
    private var _increment as Lang.Number;
    private var _formatString as Lang.String;
    //private var _font as FontDefinition;

    //! Constructor
    //! @param start Number to start with
    //! @param stop Number to end with
    //! @param increment How far apart the numbers should be
    //! @param options Dictionary of options
    //! @option options :font The font to use
    //! @option options :format The number format to display
    public function initialize(start as Lang.Number, stop as Lang.Number, increment as Lang.Number, options as {:format as Lang.String}) {
        System.println("TimeFactory: initialize");
        PickerFactory.initialize();

        _start = start;
        _stop = stop;
        _increment = increment;

        var format = options.get(:format);
        if (format != null) {
            _formatString = format;
        } else {
            _formatString = "%d";
        }

        /*var font = options.get(:font);
        if (font != null) {
            _font = font;
        } else {
            _font = Graphics.FONT_NUMBER_HOT;
        }*/
    }

    //! Get the index of a number item
    //! @param value The number to get the index of
    //! @return The index of the number
    public function getIndex(value as Lang.Number) as Lang.Number {
        return (value / _increment) - _start;
    }

    //! Generate a Drawable instance for an item
    //! @param index The item index
    //! @param selected true if the current item is selected, false otherwise
    //! @return Drawable for the item
    public function getDrawable(index as Lang.Number, selected as Lang.Boolean) as WatchUi.Drawable? {
        var value = getValue(index);
        var text = "No item";
        if (value instanceof Lang.Number) {
            text = value.format(_formatString);
        }
        return new WatchUi.Text({
            :text=>text,
            :color=>Graphics.COLOR_WHITE,
            :font=>Graphics.FONT_LARGE,
            :locX=>WatchUi.LAYOUT_HALIGN_CENTER,
            :locY=>WatchUi.LAYOUT_VALIGN_CENTER});
    }

    //! Get the value of the item at the given index
    //! @param index Index of the item to get the value of
    //! @return Value of the item
    public function getValue(index as Lang.Number) as Lang.Object? {
        return _start + (index * _increment);
    }

    //! Get the number of picker items
    //! @return Number of items
    public function getSize() as Lang.Number {
        return (_stop - _start) / _increment + 1;
    }

}
