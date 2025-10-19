<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works
It’s an 8-bit PWM generator. An internal counter cnt counts from 0 up to reload_sync, then wraps to 0. Period (clocks) = reload_sync + 1 ⇒ f_PWM = f_clk / (reload_sync + 1).
Three inputs are sampled into the clock domain each cycle (single-stage sync):
set_thres_sync, clr_thres_sync, reload_sync. Reset is async, active-low (res_ni='0' clears everything).
Output rule (edge-driven, Moore-style hold between edges):
              When cnt = set_thres_sync → pwm_o <= '1' (turn ON).
              When cnt = clr_thres_sync → pwm_o <= '0' (turn OFF, priority over set if equal).
Between these events, pwm_o holds its last value.

The high window starts at set_thres_sync and ends at clr_thres_sync. Width (in ticks) is width = (clr − set) mod (reload + 1).
              set < clr → non-wrapping window within the period.
              set > clr → window wraps across the counter rollover.
              set = clr → clear wins ⇒ 0% duty.
Any threshold > reload is never hit (that edge never occurs).

## How to test
Simulation quick checks:   Hold res_ni='0', then release to '1'.
Use reload=255 and try a few pairs:
                  set=0, clr=128 → width=128 → 50% duty.
                  set=64, clr=192 → width=128 → 50% duty, phase shifted.
                  set=200, clr=40 → width=(40−200) mod 256=96 → 37.5% duty (wrap).
                  set=100, clr=100 → 0% duty.
Change reload (e.g., 127) and verify frequency doubles (since period halves).

## External hardware

Minimal demo:
 - 8 DIP switches → ui_in (set), 8 DIP switches → uio_in (clear).
 - LED on uo_out(0) (PWM).
 - System clock and active-low reset.

With reload=255, f_PWM ≈ f_clk/256 (e.g., 1 MHz), too fast to see LED brightness change directly.
If you want visible brightness control: Lower the PWM frequency by exposing reload to pins, adding a clock divider, or widening the counter. 

 
