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

entity estabilizador is
	generic (
		DELAY		: Positive
	);
	port(
		-- Reloj
		reloj		: in std_logic;
		-- Reset
		reset		: in std_logic;
		-- Entrada
		input		: in std_logic;
		-- Salida filtrada
		output	: out std_logic
	);
end entity estabilizador;

architecture stab of estabilizador is
	-- Contador
	signal delay_cnt	: Natural range 0 to DELAY;

	-- Biestable que almacena lo captado hasta que se envía
	signal interno		: std_logic;

	-- 'output' también actúa como un biestable
begin

	filtro : process (reset, reloj, input, delay_cnt, interno)
	begin

		if reset = '1' then
			delay_cnt	<= 0;
			interno		<= '0';
			output		<= '0';

		elsif reloj'event and reloj = '1' then
			if input /= interno then
				interno		<= input;
				delay_cnt	<= 0;

			elsif delay_cnt = DELAY then
				output <= interno;

			else
				delay_cnt <= delay_cnt + 1;

			end if;
		end if;

	end process filtro;

end architecture stab;
