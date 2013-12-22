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
	signal cnt: std_logic_vector(7 downto 0);

	-- Amplitud de la onda
	constant ampl : std_logic_vector(19 downto 0) := ('0', '1', others => '0');

	-- Registro de desplazamiento de 20 bits
	signal regds : std_logic_vector(19 downto 0);

	-- Ciclo y subciclo de la transmisión
	signal ciclo	: std_logic_vector(4 downto 0);
	signal subCiclo : std_logic_vector(1 downto 0);

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
	au_mclk <= reloj;
	au_bclk <= cnt(1);
	au_lrck <= cnt(7);

	-- Indicadores de ciclo
	ciclo <= cnt(6 downto 2);
	subCiclo <= cnt(1 downto 0);

	-- Registro de desplazamiento
	des_proc : process (reloj, reset, cnt)
	begin
		if reloj'event and reloj = '1' then
			-- Desplaza para el envío en serie
			if ciclo < 20 and subCiclo = 2 then
				regds <= regds(18 downto 0) & '0';
			
			-- Carga en paralelo la muestra
			elsif ciclo = 31 and subCiclo = 3 then
				if onda = '1' then
					regds <= ampl;
				else
					regds <= (not ampl) + 1; -- Complemento a 2
				end if;	
			end if;
		end if;
	end process des_proc;

	-- Salida en serie para el codec
	au_sdti <= regds(19);
end architecture audioAK4565;
