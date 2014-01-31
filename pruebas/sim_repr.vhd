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
-- VHDL Test Bench Created by ISE for module: reproductor
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
 
entity sim_repr is
end sim_repr;
 
architecture behavior of sim_repr is 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    component reproductor
    port(
         clk : in  std_logic;
         clkdiv : in  std_logic;
         rst : in  std_logic;
         play : in  std_logic;
         addr : in  std_logic_vector(9 downto 0);
         memdir : out  std_logic_vector(9 downto 0);
         memdata : in  std_logic_vector(15 downto 0);
         onota : out  std_logic_vector(2 downto 0);
         ooctava : out  std_logic_vector(2 downto 0);
         osos : out  std_logic;
         fin : out  std_logic
        );
    end component;
    

   --Inputs
   signal clk : std_logic := '0';
   signal clkdiv : std_logic := '0';
   signal rst : std_logic := '0';
   signal play : std_logic := '0';
   signal addr : std_logic_vector(9 downto 0) := (others => '0');
   signal memdata : std_logic_vector(15 downto 0) := (others => '0');

 	--Outputs
   signal memdir : std_logic_vector(9 downto 0);
   signal onota : std_logic_vector(2 downto 0);
   signal ooctava : std_logic_vector(2 downto 0);
   signal osos : std_logic;
   signal fin : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
   constant clkdiv_period : time := 100 ns;
 
begin
 
	-- Instantiate the Unit Under Test (UUT)
   uut: reproductor PORT MAP (
          clk => clk,
          clkdiv => clkdiv,
          rst => rst,
          play => play,
          addr => addr,
          memdir => memdir,
          memdata => memdata,
          onota => onota,
          ooctava => ooctava,
          osos => osos,
          fin => fin
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 
   clkdiv_process :process
   begin
		clkdiv <= '0';
		wait for clkdiv_period/2;
		clkdiv <= '1';
		wait for clkdiv_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
		rst <= '1';
      wait for 100 ns;

		-- Fija un valor no final para la lectura del reproductor
		rst <= '0';
		memdata <= x"8004";
      wait for clk_period * 2;
		
		-- Comienza la reproducción hasta la palabra 4
		play <= '1';
		wait until memdir = 4;
		
		-- Envía el valor de finalización
		memdata <= x"0000";
		wait until fin = '1';
		
		-- Fin de la simulación
		play <= '0';
      wait;
   end process;
end;
