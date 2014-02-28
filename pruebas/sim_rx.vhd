--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:53:17 02/28/2014
-- Design Name:   
-- Module Name:   C:/hlocal/pruebas/sim_rx.vhd
-- Project Name:  pruebas
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: uart_rx
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
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY sim_rx IS
END sim_rx;
 
ARCHITECTURE behavior OF sim_rx IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT uart_rx
    PORT(
         reloj : IN  std_logic;
         reset : IN  std_logic;
         rx : IN  std_logic;
         rbaud : IN  std_logic;
         fin : OUT  std_logic;
         dout : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal reloj : std_logic := '0';
   signal reset : std_logic := '0';
   signal rx : std_logic := '0';
   signal rbaud : std_logic := '0';

 	--Outputs
   signal fin : std_logic;
   signal dout : std_logic_vector(7 downto 0);
   -- No clocks detected in port list. Replace reloj below with 
   -- appropriate port name 
 
   constant reloj_period : time := 10 ns;
	constant rbaud_period : time := 100 ns;
	
	signal indicador : std_logic := '0';
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: uart_rx PORT MAP (
          reloj => reloj,
          reset => reset,
          rx => rx,
          rbaud => rbaud,
          fin => fin,
          dout => dout
        );

   -- Clock process definitions
   reloj_process :process
   begin
		reloj <= '0';
		wait for reloj_period/2;
		reloj <= '1';
		wait for reloj_period/2;
   end process;
	
	rbaud_process :process
   begin
		rbaud <= '0';
		wait for rbaud_period/2;
		rbaud <= '1';
		wait for rbaud_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
		rx <= '1';
		reset <= '1';
      wait for 100 ns;
		indicador <= '0';
		reset <= '0';

		rx <= '0';
		indicador <= not indicador;
		wait for rbaud_period * 16;
		rx <= '1';
		indicador <= not indicador;
		wait for rbaud_period * 16;
		rx <= '1';
		indicador <= not indicador;
		wait for rbaud_period * 16;
		rx <= '0';
		indicador <= not indicador;
		wait for rbaud_period * 16;
		rx <= '1';
		indicador <= not indicador;
		wait for rbaud_period * 16;
		rx <= '1';
		indicador <= not indicador;
		wait for rbaud_period * 16;
		rx <= '0';
		indicador <= not indicador;
		wait for rbaud_period * 16;
		rx <= '1';
		indicador <= not indicador;
		wait for rbaud_period * 16;
		rx <= '0';
		indicador <= not indicador;
		wait for rbaud_period * 16;
		indicador <= not indicador;
		rx <= '1';

      wait;
   end process;

END;
