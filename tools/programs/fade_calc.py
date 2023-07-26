#!/usr/bin/env python3
from collections import namedtuple
from math import ceil

FadeTimeInfo = namedtuple(
    "FadeTimeInfo", "in_tics out_tics start_scale end_scale particle_class")

def fade_time(
        in_amount, out_amount, start_alpha, start_scale, scale_delta=1.0,
        tics_per_in_call=1, tics_per_out_call=1, max_alpha=1.0,
        spawns_per_tic=1, particle_class="Particle"):
    min_alpha = 0.0
    in_tics = (max_alpha - start_alpha) / (in_amount * tics_per_in_call)
    in_tics = ceil(in_tics)
    out_tics = (max_alpha - min_alpha) / (out_amount * tics_per_out_call)
    out_tics = ceil(out_tics)
    # Scaling is only done when fading out
    end_scale = start_scale * (scale_delta ** out_tics)
    return FadeTimeInfo(in_tics, out_tics, start_scale, end_scale, particle_class)

def print_fade_time_info(fade_time_info):
    guig = ("{0.particle_class}:\n\t"
            "{0.in_tics} tics to fade in, "
            "{0.out_tics} tics to fade out,\n\t"
            "Scale starts at {0.start_scale}, "
            "and ends at {0.end_scale}")
    return guig.format(fade_time_info)

PuffSmoke = fade_time(0.04, 0.025, 0.1, 0.04, 1.02, particle_class="PuffSmoke")
print(print_fade_time_info(PuffSmoke))

WaterSmoke = fade_time(0.03, 0.015, 0.2, 0.03, tics_per_out_call=2, max_alpha=0.44, particle_class="WaterSmoke")
print(print_fade_time_info(WaterSmoke))
