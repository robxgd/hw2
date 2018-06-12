library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity data_controller is
    generic(
		controller_address : std_logic_vector(7 downto 0)
	);

    port(
        rst : in std_logic;
        clk : in std_logic;
        set  : in std_logic;
        data_bus  : in std_logic_vector(7 downto 0); --data and address is shared on this bus
        data_out : out std_logic_vector(7 downto 0) := (others => '0');
        done : out std_logic := '1'
        );
end entity;

architecture behaviour of data_controller is
    --we have three types of states
    type state is (idle, readAddress,waiting);
    signal currentState : state := idle;

begin


    process(clk,rst)
    begin
      if (rst = '1') then
          --servo to 0 rad ==> data is 127
          data_out <= "01111111";
          currentState <= idle;
      elsif rising_edge(clk) then
        case currentState is
            when idle =>
                if(set = '1') then
                    if((data_bus = controller_address) or (data_bus="11111111")) then
                        currentState <= readAddress;
                        done <= '0';
                    end if;
                end if;
            when readAddress =>
                if (set = '1') then
                  data_out <= data_bus;
                end if;
                currentState <= waiting;
            when waiting =>
              done <= '1';
              currentState <= idle;
            end case;
        end if;
    end process;
end architecture;
