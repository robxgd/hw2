library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_servo is
end entity;

architecture test of tb_servo is
  -- input signalen
  signal clk, rst, sc, set : std_logic := '0';
  signal data_bus : std_logic_vector(7 downto 0) := (others => '0');

  -- output signalen
  signal pwm: std_logic := '0';
  signal done : std_logic := '1';
  -- extra
  signal EndOfSim    : boolean := false;
  signal pos         : integer := 0;
  signal aantal      : integer := 0;
  constant clkPeriod : time := 20 ms;
  constant scPeriod : time := 0.001961 ms;
  constant dutyCycle : real := 0.5;
  constant PERIOD : time :=  1 us;

begin

  -- Clock Generation process
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

  -- Servoclock Generation process
  servoclock: process
  begin
    while not EndOfSim loop
      sc <= '1';
      wait for (1.0 - dutyCycle) * scPeriod;
      sc <= '0';
      wait for dutyCycle * scPeriod;
    end loop;
    wait;
  end process;


  U1: entity work.servo_controller(behaviour)
  generic map(controller_address => "01010101")
  port map (
    -- inputs
    rst    => rst,
    clk    => clk,
    sc     => sc,
    set    => set,
    data_bus   => data_bus,
    --outputs
    pwm    => pwm,
    done   => done
    );

    test: process
    begin
      -- Initialiseren
      rst <='1';
      wait for clkPeriod;
      rst <= '0';
      wait for clkPeriod;

      -- Juiste Adress
      report "      JUIST ADRESS TEST         ";
      pos <= 31;
      wait for clkPeriod;
      while (pos < 256) loop
        wait until rising_edge(clk);
        set <= '1';
        data_bus <= "01010101";
        wait until rising_edge(clk);
        data_bus <= std_logic_vector(to_unsigned(pos, 8));
        wait until rising_edge(clk);
        data_bus <= (others => '0');
			  set <= '0';
        wait for 2*clkPeriod;
	      pos <= pos + 32;
        wait for clkPeriod;
      end loop;

      -- Verkeerde Adress
      report "      FOUTE ADRESS TEST         ";
      pos <= 20;
      wait for clkPeriod;
      while (pos < 256) loop
        wait until rising_edge(clk);
        set <= '1';
        data_bus <= "01010000";
        wait until rising_edge(clk);
        data_bus <= std_logic_vector(to_unsigned(pos, 8));
        wait until rising_edge(clk);
        data_bus <= (others => '0');
			  set <= '0';
        wait for 2*clkPeriod;
	      pos <= pos + 100;
        wait for clkPeriod;
      end loop;

      -- Broadcast adress
      report "      BROADCAST ADRESS TEST         ";
      pos <= 10;
      wait for clkPeriod;
      while (pos < 256) loop
        wait until rising_edge(clk);
        set <= '1';
        data_bus <= "11111111";
        wait until rising_edge(clk);
        data_bus <= std_logic_vector(to_unsigned(pos, 8));
        wait until rising_edge(clk);
        data_bus <= (others => '0');
			  set <= '0';
        wait for 2*clkPeriod;
	      pos <= pos + 60;
        wait for clkPeriod;
      end loop;

      -- Reset test
      report "      RESET TEST         ";
      pos <= 0;
      wait for clkPeriod;
      while (pos < 256) loop
        set <= '1';
        data_bus <= "11111111";
        wait until rising_edge(clk);
        if (pos = 224) then
          rst <= '1';
          wait for clkPeriod;
          rst <= '0';
        end if;
        data_bus <= std_logic_vector(to_unsigned(pos, 8));
        wait until rising_edge(clk);
        if (pos = 64) then
          rst <= '1';
          wait for clkPeriod;
          rst <= '0';
        end if;
        data_bus <= (others => '0');
			  set <= '0';
        wait for 2*clkPeriod;
	      pos <= pos + 32;
        wait for clkPeriod;
      end loop;

      -- Foute data
      report "      FOUTE DATA         ";
      pos <= 255;
      wait for clkPeriod;

      -- verkeerde set tijd
      wait until rising_edge(clk);
      data_bus <= "01010101";
      wait until rising_edge(clk);
      set <= '1';
      data_bus <= std_logic_vector(to_unsigned(pos, 8));
      wait until rising_edge(clk);
      data_bus <= (others => '0');
		  set <= '0';
      wait for 3*clkPeriod;
      -- set valt uit
      wait until rising_edge(clk);
      set <= '1';
      data_bus <= "01010101";
      wait until rising_edge(clk);
      set <= '0';
      data_bus <= std_logic_vector(to_unsigned(pos, 8));
      wait until rising_edge(clk);
      data_bus <= "00000000";
		  set <= '0';
      wait for 3*clkPeriod;
      -- set te lang
      wait until rising_edge(clk);
      set <= '1';
      data_bus <= (others => '0');
      wait until rising_edge(clk);
      data_bus <= std_logic_vector(to_unsigned(pos, 8));
      wait until rising_edge(clk);
      data_bus <= "11000000";
		  set <= '0';
      wait until rising_edge(clk);
      data_bus <= (others => '0');
      wait until rising_edge(clk);
      wait for 3*clkPeriod;
      -- twee maal instellen
      wait until rising_edge(clk);
      set <= '1';
      data_bus <= "01010101";
      wait until rising_edge(clk);
      data_bus <= std_logic_vector(to_unsigned(pos, 8));
      wait until rising_edge(clk);
      data_bus <= "01010101";
      wait until rising_edge(clk);
      data_bus <= "11001100";
      wait until rising_edge(clk);
      data_bus <= (others => '0');
      set <='0';
      wait for 3*clkPeriod;

      EndOfSim <= true;
      report "Test done";
      wait;
    end process;


    meet: process
    begin
      while not EndOfSim loop
          -- Ben niet zeker of het genoeg is zonder dit: wait until falling_edge(set);
          aantal <= 0;
          wait until done = '1';
          wait until rising_edge(pwm);
          report "Start meten met ingestelde positie " & integer'image(pos);
          while pwm = '1' loop
            aantal <= aantal+ 1;
            wait for 1 us;
          end loop;
          report "Gemeten Ton: " & real'image(real(aantal)/1000.0) & " ms";
          if (pos = integer(real(aantal - 1250)/1.961)) then
            report "Succes: Gemeten positie klopt met gewenste positie";
          else
            report "Error: Gemeten en gewenste positie komen niet overeen";
          end if;
          -- report "Gemeten Ton: " & real'image(real(aantal)/1000.0) & " ms en dus " & integer'image(integer(real(aantal - 1250)/1.961)) & "de positie";
          -- report "Gewenste Ton: " & real'image((real(pos)*0.001961)+1.25) & " ms";
          -- report "Resultaten van servo pwm: Ton= "
          -- & real'image(aantal/1000.0) & " ms, positie is " & real'image(((aantal*0.001)-1.25)/real(scPeriod/1 ms))
          -- & ". De verwachte positie is " & real'image(real(pos));
      end loop;
      wait;
    end process;

end architecture test;
