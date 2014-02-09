--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date: 
-- Design Name:   
-- Module Name:
-- Project Name:
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: grabador
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
 
entity sim_grab is
end sim_grab;
 
ARCHITECTURE behavior OF sim_grab IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    component grabador
    port(
         reloj : in  std_logic;
         rjdiv : in  std_logic;
         reset : in  std_logic;
         nota : in  std_logic_vector(2 downto 0);
         octava : in  std_logic_vector(2 downto 0);
         sos : in  std_logic;
         dir_ini : in  std_logic_vector(9 downto 0);
         mem_dir : out  std_logic_vector(9 downto 0);
         mem_dat : out  std_logic_vector(15 downto 0);
         mem_we : out  std_logic;
         grabar : in  std_logic
        );
    end component;
    

   --Inputs
   signal reloj : std_logic := '0';
   signal rjdiv : std_logic := '0';
   signal reset : std_logic := '0';
   signal nota : std_logic_vector(2 downto 0) := (others => '0');
   signal octava : std_logic_vector(2 downto 0) := (others => '0');
   signal sos : std_logic := '0';
   signal dir_ini : std_logic_vector(9 downto 0) := (others => '0');
   signal grabar : std_logic := '0';

 	--Outputs
   signal mem_dir : std_logic_vector(9 downto 0);
   signal mem_dat : std_logic_vector(15 downto 0);
   signal mem_we : std_logic;
	
	-- Memoria para la escritura
	type TMem is array (0 to 10) of std_logic_vector(15 downto 0);
	
	signal mem : TMem := (others => x"0000");
	
   -- Señales de reloj
   constant reloj_period : time := 1 ns;
	constant rjdiv_period : time := 10 ns;

begin
 
	-- Instantiate the Unit Under Test (UUT)
   uut: grabador port map (
          reloj => reloj,
          rjdiv => rjdiv,
          reset => reset,
          nota => nota,
          octava => octava,
          sos => sos,
          dir_ini => dir_ini,
          mem_dir => mem_dir,
          mem_dat => mem_dat,
          mem_we => mem_we,
          grabar => grabar
        );

   -- Clock process definitions
   reloj_process :process
   begin
		reloj <= '0';
		wait for reloj_period/2;
		reloj <= '1';
		wait for reloj_period/2;
   end process;
	
	rjdiv_process :process
   begin
		rjdiv <= '0';
		wait for rjdiv_period/2;
		rjdiv <= '1';
		wait for rjdiv_period/2;
   end process;

	-- Escritura síncrona en la memoria con capacitación	
	mem_rec : process (reloj, mem_dir, mem_we, mem_dat)
	begin
		if reloj'event and reloj = '1' then
			if mem_we = '1' then
				mem(conv_integer(mem_dir)) <= mem_dat;
			end if;
		end if;
	end process mem_rec;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
		reset <= '1';
      wait for 100 ns;

		reset		<= '0';
      wait for reloj_period;
		
		-- Comienza la grabación
		nota		<= "001";
		octava	<= "001";
		sos		<= '0';
		
		grabar <= '1';
		wait for reloj_period * 3.2;
		
		-- Cambia a Re durante 3 ut
		nota		<= "010";
		wait for rjdiv_period * 3.1;
		
		-- Cambia a Si durante 4 ut
		nota		<= "111";
		wait for rjdiv_period * 4.1;
		
		grabar <= '0';
      wait;
   end process;

end architecture behavior;
