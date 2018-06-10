library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_datacontroller is
end entity;

architecture test of tb_datacontroller is
  -- IN
  signal rst : std_logic := '0';
  signal clk : std_logic := '0';
  signal set : std_logic := '0';
  signal data_in : std_logic_vector(7 downto 0) := (others => '0');
  -- OUT
  signal done : std_logic := '1';
  signal data_out : std_logic_vector(7 downto 0) := (others => '0');
  -- extra
  signal EndOfSim    : boolean := false;
  signal staat : std_logic_vector(1 downto 0) := "00";
  constant clkPeriod : time := 20 ms;
  constant dutyCycle : real := 0.5;
  constant adress : std_logic_vector(7 downto 0) := "01010101";


  begin

    clock: process
    begin
      while not EndOfSim loop
        clk <= '1';
        wait for (1.0 - dutyCycle) * clkPeriod;
        clk <= '0';
        wait for dutyCycle * clkPeriod;
      end loop;
      wait;
    end process;

    U1: entity work.data_controller(behaviour)
    generic map(controller_address => "01010101")
    port map (
      -- inputs
      rst    => rst,
      clk    => clk,
      set    => set,
      data_bus   => data_in,
      --outputs
      data_out    => data_out,
      done   => done,
      staat => staat
      );

      process
      variable pos : integer := 0;
      begin
        -- Initialiseren
        rst <='1';
        wait for clkPeriod;
        rst <= '0';
        wait for 50 ms;
        -- Posities testen
        while (pos < 256) loop
          wait until rising_edge(clk);
          set <= '1';
          data_in <= "01010101";
          wait until rising_edge(clk);

          -- report integer'image(to_integer(unsigned(data_in))) & " , " & integer'image(to_integer(unsigned(adress)));
          -- if data_in = adress then
          --   report "adress is juist";
          -- else
          --   report "adress is fout";
          -- end if;
          data_in <= std_logic_vector(to_unsigned(pos, 8));
          wait until rising_edge(clk);
  			  set <= '0';
  	      wait for 50 ms;
  	      pos := pos + 32;
        end loop;
        EndOfSim <= true;
        report "Test done";
        wait;
      end process;











end architecture test;
