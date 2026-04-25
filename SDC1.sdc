# # Define the 50MHz input clock
# create_clock -name CLOCK_50 -period 20.000 [get_ports {CLOCK_50}]

# # Automatically derive PLL clocks
# derive_pll_clocks
# derive_clock_uncertainty