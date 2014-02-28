--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:37:17 02/28/2014
-- Design Name:   
-- Module Name:   C:/hlocal/pruebas/sim_tx.vhd
-- Project Name:  pruebas
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: uart_tx
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
 
ENTITY sim_tx IS
END sim_tx;
 
ARCHITECTURE behavior OF sim_tx IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT uart_tx
    PORT(
         reloj : IN  std_logic;
         reset : IN  std_logic;
         tx_start : IN  std_logic;
         rbaud : IN  std_logic;
         din : IN  std_logic_vector(7 downto 0);
         tx_done_tick : OUT  std_logic;
         tx : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal reloj : std_logic := '0';
   signal reset : std_logic := '0';
   signal tx_start : std_logic := '0';
   signal rbaud : std_logic := '0';
   signal din : std_logic_vector(7 downto 0) := (others => '0');

 	--Outputs
   signal tx_done_tick : std_logic;
   signal tx : std_logic;
   -- No clocks detected in port list. Replace reloj below with 
   -- appropriate port name 
 
   constant reloj_period : time := 10 ns;
	constant rbaud_period : time := 20 ns;
 
BEGIN
	-- Instantiate the Unit Under Test (UUT)
   uut: uart_tx PORT MAP (
          reloj => reloj,
          reset => reset,
          tx_start => tx_start,
          rbaud => rbaud,
          din => din,
          tx_done_tick => tx_done_tick,
          tx => tx
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
		reset <= '1';
      wait for 100 ns;	
		reset <= '0';
		
		wait for 10 ns;

		din <= "01000000";
		tx_start <= '1';
		wait until rising_edge(reloj);
		tx_start <= '0';
		
		wait until falling_edge(tx_done_tick);
		
      wait;
   end process;

END;
