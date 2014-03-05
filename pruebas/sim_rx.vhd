---------------------------------------------------------------------------------
-- Company: Equipo 1
-- Engineer:
-- 
-- Design Name: Prueba del receptor de la UART
-- Module Name: sim_rx
-- Project Name: Proyecto de TOC
-- Target Devices: Xilinx Spartan 3
-- Tool versions: Xilinx ISE 14.1 
-- 
-- VHDL Test Bench Created by ISE for module: sim_rx
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity sim_rx is
end sim_rx;
 
architecture behavior of sim_rx is 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    component uart_rx
    port(
         reloj : in  std_logic;
         reset : in  std_logic;
         rx : in  std_logic;
         rbaud : in  std_logic;
         fin : out  std_logic;
         dout : out  std_logic_vector(7 downto 0)
        );
    end component;
    

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
begin
 
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

end;
