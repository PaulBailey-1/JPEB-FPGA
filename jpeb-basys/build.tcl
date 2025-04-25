# Open the project
# open_project jpeb-basys.xpr

reset_run synth_1
reset_run impl_1

# Run synthesis
puts "Starting synthesis..."
launch_runs synth_1
if {[catch {wait_on_run synth_1} result]} {
    puts "Error during synthesis: $result"
    # exit 1
}

# Run implementation
puts "Starting implementation..."
launch_runs impl_1
if {[catch {wait_on_run impl_1} result]} {
    puts "Error during implementation: $result"
    # exit 1
}

# Generate the bitstream
puts "Generating bitstream..."
launch_runs impl_1 -to_step write_bitstream
if {[catch {wait_on_run impl_1} result]} {
    puts "Error during bitstream generation: $result"
    exit 1
}

puts "Bitstream generation completed successfully!"