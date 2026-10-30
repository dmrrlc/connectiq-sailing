using Toybox.Graphics as Gfx;
using Toybox.System as Sys;

//! Display-capability helpers shared by views
module DisplayUtil {
    //! True on Instinct-style semi-octagon displays
    function hasCornerSubscreen(view) {
        if (!(view has :getSubscreen) || (Sys.getDeviceSettings().screenShape != Sys.SCREEN_SHAPE_SEMI_OCTAGON)) {
            return false;
        }
        // Semi-octagon devices without a subscreen window (e.g. Instinct Crossover) return null
        return view.getSubscreen() != null;
    }

    //! Instinct displays are 1-bit, where colours collapse to black and the glyphs vanish
    function resolveInstinctColor(view, color) {
        if (hasCornerSubscreen(view)) {
            return Gfx.COLOR_WHITE;
        }
        return color;
    }
}
