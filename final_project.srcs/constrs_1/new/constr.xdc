# Clock signal
set_property PACKAGE_PIN W5 [get_ports clock]
set_property IOSTANDARD LVCMOS33 [get_ports clock]

# Reset button
set_property PACKAGE_PIN W19 [get_ports reset]
set_property IOSTANDARD LVCMOS33 [get_ports reset]

# Start button
set_property PACKAGE_PIN T17 [get_ports start]
set_property IOSTANDARD LVCMOS33 [get_ports start]

# Random button
set_property PACKAGE_PIN T18 [get_ports random]
set_property IOSTANDARD LVCMOS33 [get_ports random]

# Seven segment LED display
set_property PACKAGE_PIN W7 [get_ports {LED_segment[6]}]
set_property PACKAGE_PIN W6 [get_ports {LED_segment[5]}]
set_property PACKAGE_PIN U8 [get_ports {LED_segment[4]}]
set_property PACKAGE_PIN V8 [get_ports {LED_segment[3]}]
set_property PACKAGE_PIN U5 [get_ports {LED_segment[2]}]
set_property PACKAGE_PIN V5 [get_ports {LED_segment[1]}]
set_property PACKAGE_PIN U7 [get_ports {LED_segment[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports LED_segment[*]]

# Decimal Point
set_property PACKAGE_PIN V7 [get_ports dp]
set_property IOSTANDARD LVCMOS33 [get_ports dp]

set_property PACKAGE_PIN U2 [get_ports {anode_activation[0]}]
set_property PACKAGE_PIN U4 [get_ports {anode_activation[1]}]
set_property PACKAGE_PIN V4 [get_ports {anode_activation[2]}]
set_property PACKAGE_PIN W4 [get_ports {anode_activation[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports anode_activation[*]]

# LED answer
set_property PACKAGE_PIN V14 [get_ports {LED_answer[7]}]
set_property PACKAGE_PIN U14 [get_ports {LED_answer[6]}]
set_property PACKAGE_PIN U15 [get_ports {LED_answer[5]}]
set_property PACKAGE_PIN W18 [get_ports {LED_answer[4]}]
set_property PACKAGE_PIN V19 [get_ports {LED_answer[3]}]
set_property PACKAGE_PIN U19 [get_ports {LED_answer[2]}]
set_property PACKAGE_PIN E19 [get_ports {LED_answer[1]}]
set_property PACKAGE_PIN U16 [get_ports {LED_answer[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports LED_answer[*]]

# LED input
set_property PACKAGE_PIN L1 [get_ports {LED_input[7]}]
set_property PACKAGE_PIN P1 [get_ports {LED_input[6]}]
set_property PACKAGE_PIN N3 [get_ports {LED_input[5]}]
set_property PACKAGE_PIN P3 [get_ports {LED_input[4]}]
set_property PACKAGE_PIN U3 [get_ports {LED_input[3]}]
set_property PACKAGE_PIN W3 [get_ports {LED_input[2]}]
set_property PACKAGE_PIN V3 [get_ports {LED_input[1]}]
set_property PACKAGE_PIN V13 [get_ports {LED_input[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports LED_input[*]]

# Password answer ports
set_property PACKAGE_PIN W13 [get_ports {password_answer[7]}]
set_property PACKAGE_PIN W14 [get_ports {password_answer[6]}]
set_property PACKAGE_PIN V15 [get_ports {password_answer[5]}]
set_property PACKAGE_PIN W15 [get_ports {password_answer[4]}]
set_property PACKAGE_PIN W17 [get_ports {password_answer[3]}]
set_property PACKAGE_PIN W16 [get_ports {password_answer[2]}]
set_property PACKAGE_PIN V16 [get_ports {password_answer[1]}]
set_property PACKAGE_PIN V17 [get_ports {password_answer[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports password_answer[*]]

# Password input ports
set_property PACKAGE_PIN R2 [get_ports {password_input[7]}]
set_property PACKAGE_PIN T1 [get_ports {password_input[6]}]
set_property PACKAGE_PIN U1 [get_ports {password_input[5]}]
set_property PACKAGE_PIN W2 [get_ports {password_input[4]}]
set_property PACKAGE_PIN R3 [get_ports {password_input[3]}]
set_property PACKAGE_PIN T2 [get_ports {password_input[2]}]
set_property PACKAGE_PIN T3 [get_ports {password_input[1]}]
set_property PACKAGE_PIN V2 [get_ports {password_input[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports password_input[*]]

# UART TX
set_property PACKAGE_PIN A18 [get_ports tx]
set_property IOSTANDARD LVCMOS33 [get_ports tx]
