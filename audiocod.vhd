----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:
-- Design Name: 
-- Module Name:
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

use work.tipos.all;

entity audiocod is
	port(
		-- Se�al digital de entrada
		onda	: in std_logic;
		-- Se�al de entrada del codec
		au_stdi	: out std_logic;
		-- Reloj maestro
		au_mclk	: out std_logic;
		-- Reloj de la entrada
		au_bclk	: out std_logic;
		-- Selector de canal
		au_lrck	: out std_logic;

		-- Reloj de la FPGA
		reloj	: in std_logic;
		-- Se�al de reinicio as�ncrona
		reset	: in std_logic
	);
end entity audiocod;

architecture audioAK4565 of audiocod is
	-- Contador para los relojes del c�dec
	signal cnt: std_logic_vector(9 downto 0);
begin
	-- Contador
	cnt_proc : process (reloj, reset, cnt)
		if reset = '1' then
			cnt <= (others => '0');

		elsif reloj'event and reloj='1' then
			cnt <= cnt + 1;
		end if;
	end process cont_proc;

	-- Relojes del c�dec (ver manual)
	au_mclk <= cnt(1);
	au_bclk <= cnt(3);
	au_lrck <= cnt(9);

	au_stdi <= onda;
end architecture audioAK4565;
