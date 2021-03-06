---------------------------------------------------------------------------------
-- Company: Equipo 1
-- Engineer:
-- 
-- Design Name: Prueba del reproductor
-- Module Name: sim_reproductor
-- Project Name: Proyecto de TOC
-- Target Devices: Xilinx Spartan 3
-- Tool versions: Xilinx ISE 14.1 
-- 
-- VHDL Test Bench Created by ISE for module: reproductor
--
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
	
	-- Memoria para la lectura
	type TMem is array (0 to 10) of std_logic_vector(15 downto 0);
	
	signal mem : TMem := ("1000000000000010", "1000001000000100",
			"1000001100000001", "1111111000101111", others => x"0000");
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

	-- Datos de memoria
	memdata <= mem(conv_integer(memdir));

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
		rst <= '1';
      wait for 100 ns;

		-- Fija un valor no final para la lectura del reproductor
		rst <= '0';
      wait for clk_period * 2;

		-- Comienza la reproducción hasta el fin
		play <= '1';
		wait until fin = '1';

		-- Fin de la simulación
		play <= '0';
      wait;
   end process;
end;
