ghdl -a data_controller.vhdl
ghdl -a servo.vhdl
ghdl -a servo_controller.vhdl
ghdl -a tb_servo.vhdl
ghdl -e tb_servo
ghdl -r tb_servo --vcd=foute_data_servo_test.vcd
