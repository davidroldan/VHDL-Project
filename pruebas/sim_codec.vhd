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
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
 
entity sim_codec is
end sim_codec;
 
architecture behavior of sim_codec is 

   --Inputs
   signal reloj : std_logic;
   signal reset : std_logic := '0';
	signal onda	 : std_logic;

 	--Outputs
   signal au_sdti : std_logic;
   signal au_mclk : std_logic;
   signal au_bclk : std_logic;
   signal au_lrck : std_logic;

   -- Clock period definitions
   constant reloj_period : time := 10 ns;
begin

	-- Unidad en pruebas
	uut : entity work.audiocod	generic map (
		I_AMPL 	=> 1
	) port map (
		onda		=> onda,
		au_sdti	=> au_sdti,
		au_mclk	=> au_mclk,
		au_bclk	=> au_bclk,
		au_lrck	=> au_lrck,
		reloj		=> reloj,
		reset		=> reset
	);

   -- Reloj
   reloj_process : process
   begin
		reloj <= '0';
		wait for reloj_period / 2;
		reloj <= '1';
		wait for reloj_period / 2;
   end process reloj_process;
 

   -- Pruebas
   stim_proc: process
		variable sec	: string(1 to 20);
		variable linea	: line;
   begin		
      -- mantiene el estado de reset 100 ns
		reset <= '1';
		onda	<= '1';
      wait for 100 ns;
		reset	<= '0';
		
		while true loop
			wait until au_lrck'event;
		
			for i in 1 to 20 loop
				wait until rising_edge(au_bclk);
			
				sec(i) := std_logic'Image(au_sdti)(2);
			end loop;
		
			if au_lrck = '1' then
				write(linea, "canal derecho ");
			else
				write(linea, "canal izquierdo ");
			end if;
			
			write(linea, sec);
			writeline(output, linea);
		end loop;
		
		wait;
   end process;
END;
