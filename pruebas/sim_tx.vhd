---------------------------------------------------------------------------------
-- Company: Equipo 1
-- Engineer:
-- 
-- Design Name: Prueba del emisor de la UART
-- Module Name: sim_tx
-- Project Name: Proyecto de TOC
-- Target Devices: Xilinx Spartan 3
-- Tool versions: Xilinx ISE 14.1 
-- 
-- VHDL Test Bench Created by ISE for module: sim_tx
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
 
entity sim_tx is
end sim_tx;
 
architecture behavior of sim_tx is 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    component uart_tx
    port(
         reloj : in  std_logic;
         reset : in  std_logic;
         tx_start : in  std_logic;
         rbaud : in  std_logic;
         din : in  std_logic_vector(7 downto 0);
         tx_done_tick : out  std_logic;
         tx : out  std_logic
        );
    end component;
    

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
 
begin
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

end;
