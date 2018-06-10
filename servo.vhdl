library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


--this entity will tell the motor what to do
entity servo is
    port(
        rst : in std_logic;
        clk : in std_logic;
        sc: in std_logic;
        -- set  : in std_logic;
        data  : in std_logic_vector(7 downto 0); --data and address
        pwm : out std_logic
    );
end entity;

architecture behaviour of servo is

    signal pwm_timer : integer := 0;
    constant servo_freq : positive := 510200;
	constant servo_period_ms : real :=  0.00196;

begin
    process(clk,rst)
    begin
      if rst = '1' then
        --we start the pwm signal every clock. if it is not neceserry, de sc process will stop it.
        if rising_edge(clk) then
            --pwm <= '1';
        end if;
        end if;
    end process;


    process(sc)
    begin
        --check how long sc was high to give right value.
        --We know the SC is 50hz
        -- each time we com in this function we add 1 to the timer. to know tehe time we multiply the counter with the period = 20ms
        if rising_edge(sc) then
            pwm_timer <= pwm_timer + 1;
            --Ton = (n_offset +  n_position)*Tsc
            --data is 8 bits to represent the position we want the motor to be.
            -- the pwm should be high for a time between 1.25ms and 1.75ms
            -- this means we have to divide the 0.5ms in between over the 256 possibilities of the data
            --we decide to make the servo period 1.96 microsec = 0.5ms/256

            --1.25/0.00196 = 637.755102041

            if(real(pwm_timer) >= ((1.25/servo_period_ms) + real(to_integer(unsigned(data))))) then
                pwm <= '0';
                pwm_timer <= 0;
            else
                pwm <= '1';
            end if;

        end if;
    end process;

end architecture;
