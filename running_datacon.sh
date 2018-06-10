ghdl -a data_controller.vhdl
ghdl -a tb_datacontroller.vhdl
ghdl -e tb_datacontroller
ghdl -r tb_datacontroller --vcd=datacon_test.vcd
