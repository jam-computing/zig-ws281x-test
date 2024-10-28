const std = @import("std");

const c = @cImport({
    @cInclude("rpi_ws281x/ws2811.h");
});

pub const controller_init_error = error{
    COULD_NOT_INIT,
    COULD_NOT_RENDER,
};

const LED_COUNT = 50;

pub const controller = struct {
    ws281x: c.ws2811_t,

    pub fn init() controller_init_error!controller {
        var ledstring: c.ws2811_t = undefined;
        std.debug.print("initialising ledstring", .{});

        ledstring.freq = c.WS2811_TARGET_FREQ;
        ledstring.dmanum = 10;
        ledstring.channel[0].gpionum = 18;
        ledstring.channel[0].count = LED_COUNT;
        ledstring.channel[0].invert = 0;
        ledstring.channel[0].brightness = 255;
        ledstring.channel[0].strip_type = c.WS2811_STRIP_RGB;

        std.debug.print("setup ledstring parameters", .{});
        std.debug.print("gpionum: {}, count: {}, brightness: {}, strip_type: {any}", .{
            ledstring.channel[0].gpionum,
            ledstring.channel[0].count,
            ledstring.channel[0].brightness,
            ledstring.channel[0].strip_type,
        });

        if (c.ws2811_init(&ledstring) != c.WS2811_SUCCESS) {
            std.debug.print("Error initialising ws2811\n", .{});
            return controller_init_error.COULD_NOT_INIT;
        }

        std.debug.print("Calibrating, pixels 1, 2, 3 should be red green and blue", .{});

        ledstring.channel[0].leds[0] = 0xFF0000;
        ledstring.channel[0].leds[1] = 0x00FF00;
        ledstring.channel[0].leds[2] = 0x0000FF;

        if (c.ws2811_render(&ledstring) != c.WS2811_SUCCESS) {
            std.debug.print("Could not render", .{});
            return controller_init_error.COULD_NOT_RENDER;
        }
        std.debug.print("initialising done", .{});

        return controller{ .ws281x = ledstring };
    }

    pub fn all_col(ctrl: *const controller, col: u32) void {
        var i: usize = 0;

        while (i < LED_COUNT) : (i += 1) {
            ctrl.ws281x.channel[0].leds[i] = col;
        }
    }
};

pub fn main() !void {
    const ctrl = try controller.init();
    std.debug.print("Setting all leds to green", .{});
    ctrl.all_col(0x00ff00);
}
