export DESIGN_NICKNAME = TinyTPU
export DESIGN_NAME = top
export PLATFORM    = sky130hd

export VERILOG_FILES = ./designs/TinyTPU/src/*.v
#export VERILOG_FILES = $(sort $(wildcard ./designs/src/$(DESIGN_NICKNAME)/src/*.v))
export SDC_FILE      = ./designs/$(PLATFORM)/$(DESIGN_NICKNAME)/constraint.sdc

export PLACE_PINS_ARGS = -min_distance 4 -min_distance_in_tracks

export CORE_UTILIZATION = 20
export CORE_ASPECT_RATIO = 1
export CORE_MARGIN = 2

export PLACE_DENSITY = 0.6
export TNS_END_PERCENT = 100
