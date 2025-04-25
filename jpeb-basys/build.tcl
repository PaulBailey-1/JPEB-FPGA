# Open the project
# open_project jpeb-basys.xpr

reset_run synth_1
reset_run impl_1

# Run synthesis
launch_runs synth_1
wait_on_run synth_1

# Run implementation
launch_runs impl_1
wait_on_run impl_1

# Generate the bitstream
launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1
