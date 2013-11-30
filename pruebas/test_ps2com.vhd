--------------------------------------------------------------------------------
-- Prueba de comunicación con el teclado
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
 
entity test_ps2com is
end test_ps2com;

architecture behavior of test_ps2com is 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    component xx
    port(
         PS2CLK : inout  std_logic;
         PS2DATA : inout  std_logic;
         reloj : in  std_logic;
         reset : in  std_logic
        );
    end component;
    

   --Inputs
   signal reloj : std_logic := '0';
   signal reset : std_logic := '0';

	--BiDirs
   signal PS2CLK : std_logic;
   signal PS2DATA : std_logic;

   -- Clock period definitions
	constant FPGA_period   : time := 10 ns; -- 100 MHz
begin
 
	-- Instantiate the Unit Under Test (UUT)
   uut: XX port map (
          PS2CLK => PS2CLK,
          PS2DATA => PS2DATA,
          reloj => reloj,
          reset => reset
        );

   -- Clock process definitions
   reloj_process : process
   begin
		reloj <= '0';
		wait for FPGA_period/2;
		reloj <= '1';
		wait for FPGA_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin
      -- hold reset state for 100 ns.
		reset <= '1';
		wait for 100 ns;

		-- Se mantiene inactivo hasta que se libere el reloj
		PS2CLK <= 'Z';
		reset <= '0';
		wait until PS2CLK = 'Z';
		
		-- Espera un poco para ver algo azul
		wait for 10ns;
		
		PS2CLK <= '0';
		wait for 10 ns;
		
		-- Marca el reloj tal como lo haría el teclado para recibir el comando
		for i in 1 to 12 loop
			PS2CLK <= '1';
			wait for 10 ns;
			PS2CLK <= '0';
			wait for 10 ns;
		end loop;
      wait;
   end process;
end;
