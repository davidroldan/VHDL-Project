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
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.tipos.all;

entity audiocod is
	port(
		-- Señal digital de entrada
		onda	: in std_logic;
		-- Señal de entrada del codec
		au_sdti	: out std_logic;
		-- Reloj maestro
		au_mclk	: out std_logic;
		-- Reloj de la entrada
		au_bclk	: out std_logic;
		-- Selector de canal
		au_lrck	: out std_logic;

		-- Reloj de la FPGA
		reloj	: in std_logic;
		-- Señal de reinicio asíncrona
		reset	: in std_logic
	);
end entity audiocod;

architecture audioAK4565 of audiocod is
	-- Contador para los relojes del códec
	signal cnt: std_logic_vector(9 downto 0);
begin
	-- Contador
	cnt_proc : process (reloj, reset, cnt)
	begin
		if reset = '1' then
			cnt <= (others => '0');

		elsif reloj'event and reloj='1' then
			cnt <= cnt + 1;
		end if;
	end process cnt_proc;

	-- Relojes del códec (ver manual)
	au_mclk <= cnt(1);
	au_bclk <= cnt(3);
	au_lrck <= cnt(9);

	au_sdti <= onda;
end architecture audioAK4565;
