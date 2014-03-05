---------------------------------------------------------------------------------
-- Company: Equipo 1
-- Engineer:
-- 
-- Design Name: Prueba del archivero
-- Module Name: sim_archivero
-- Project Name: Proyecto de TOC
-- Target Devices: Xilinx Spartan 3
-- Tool versions: Xilinx ISE 14.1 
-- 
-- VHDL Test Bench Created by ISE for module: archivero
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
 
entity sim_archivero is
end sim_archivero;
 
architecture behavior of sim_archivero is 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    component archivero
    port(
         reloj : in  std_logic;
         rjdiv : in  std_logic;
         play : in  std_logic;
         rec : in  std_logic;
         stop : in  std_logic;
         bsig : in  std_logic;
         bant : in  std_logic;
         en_reproducion : out  std_logic;
         en_grabacion : out  std_logic;
         bloqueact : out  std_logic_vector(7 downto 0);
         reset : in  std_logic;
         nota : in  std_logic_vector(2 downto 0);
         octava : in  std_logic_vector(2 downto 0);
         sos : in  std_logic;
         onota : out  std_logic_vector(2 downto 0);
         ooctava : out  std_logic_vector(2 downto 0);
         osos : out  std_logic
        );
    end component;
    

   --Inputs
   signal reloj : std_logic := '0';
   signal rjdiv : std_logic := '0';
   signal play : std_logic := '0';
   signal rec : std_logic := '0';
   signal stop : std_logic := '0';
   signal bsig : std_logic := '0';
   signal bant : std_logic := '0';
   signal reset : std_logic := '0';
   signal nota : std_logic_vector(2 downto 0) := (others => '0');
   signal octava : std_logic_vector(2 downto 0) := (others => '0');
   signal sos : std_logic := '0';

 	--Outputs
   signal en_reproducion : std_logic;
   signal en_grabacion : std_logic;
   signal bloqueact : std_logic_vector(7 downto 0);
   signal onota : std_logic_vector(2 downto 0);
   signal ooctava : std_logic_vector(2 downto 0);
   signal osos : std_logic;
	
	-- Clock period definitions
   constant reloj_period : time := 10 ns;
   constant rjdiv_period : time := 100 ns;
 
begin
 
	-- Instantiate the Unit Under Test (UUT)
   uut: archivero PORT MAP (
          reloj => reloj,
          rjdiv => rjdiv,
          play => play,
          rec => rec,
          stop => stop,
          bsig => bsig,
          bant => bant,
          en_reproducion => en_reproducion,
          en_grabacion => en_grabacion,
          bloqueact => bloqueact,
          reset => reset,
          nota => nota,
          octava => octava,
          sos => sos,
          onota => onota,
          ooctava => ooctava,
          osos => osos
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
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
		reset <= '1';
      wait for 100 ns;	

		reset <= '0';
      wait for reloj_period * 2;
		
		-- Activa la señal de inicio de reproducción durante un ciclo
		play <= '1';
		wait until reloj'event and reloj = '1';
		play <= '0';
		
		
		-- Espera hasta que termina la reproducción
		wait until fin = '1';

		-- Sigue esperando
      wait;
   end process;
end;
