library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


--this file wiil link the ports between the servo and de data_controller
entity servo_controller is
generic(
		controller_address : std_logic_vector
	);

port(
    clk           : in  std_logic                    := '0';
    rst           : in  std_logic                    := '0';
    sc            : in  std_logic                    := '0';
    set           : in  std_logic                    := '0';
    data_bus      : in  std_logic_vector(7 downto 0) := (others => '0');
    done          : out std_logic                    := '1';
    pwm           : out std_logic                    := '0'


);
end entity servo_controller;

architecture behaviour of servo_controller is
    --TODO: wat met de data? we zetten dit standaard op 0 en de entities gaan hier zelf een waarde aan geven?
    signal data : std_logic_vector(7 downto 0) := (others=> '0');
begin
    datacontroller : entity work.data_controller(behaviour)
        generic map(controller_address => controller_address)
        port map(
            clk => clk,
            rst => rst,
            set => set,
            data_out => data,
            data_bus => data_bus,
            done => done
        );

    servo : entity work.servo(behaviour)
        port map(
            clk => clk,
            rst => rst,
						sc => sc,
            data => data,
            pwm => pwm
        );
end architecture behaviour;
