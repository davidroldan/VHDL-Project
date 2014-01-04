--
-- Tabla de notas en la séptima octava (con sostenido)
-- De los apuntes de J.M. Mendías
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.ALL;

-- Tipos locales
use work.tipos.all;

entity tablanotassos is 
	port (
		nota		: in TNota;
		semiper	: out std_logic_vector(11 downto 0)
	);
end entity tablanotassos;

architecture rom_tablanotassos of tablanotassos is
	-- Señal de tipo entero para escribir menos
	signal tmp : Integer range 0 to 2819;
begin

	-- Asigna el semiperiodo en función de la nota
	with nota select
		tmp	<=	2819	when do,
					2511	when re,
					2237	when mi,
					2112	when fa,
					1881	when sol,
					1676	when la,
					1493	when si,
					0	when others;
					
	semiper <= conv_std_logic_vector(tmp, 12);
end architecture rom_tablanotassos;
