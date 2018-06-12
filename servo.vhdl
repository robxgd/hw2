library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity servo is
    port(
        rst : in std_logic;
        clk : in std_logic;
        sc: in std_logic;
        data  : in std_logic_vector(7 downto 0);
        pwm : out std_logic
    );
end entity;

architecture behaviour of servo is

    constant servo_freq : positive := 510200;
	constant servo_period_ms : real :=  0.001961;

begin

    process(sc, clk, rst)
    variable pwm_timer : integer := 0;

    begin
        if rising_edge(clk) then
            pwm_timer := 0;
        end if;

        if rst = '1' then
            pwm <= '0';
            pwm_timer := 0;
        elsif rising_edge(sc) then
            pwm_timer := pwm_timer + 1;
            if(real(pwm_timer) < ((1.25/servo_period_ms) + real(to_integer(unsigned(data))))) then
                pwm <= '1';
            else
                pwm<= '0';
            end if;
        end if;
    end process;

end architecture;
