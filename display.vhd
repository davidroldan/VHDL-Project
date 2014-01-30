library ieee;
use ieee.std_logic_1164.all;

use work.tipos.all;

entity display is
	port (
		-- Bloque de RAM seleccionado
		bloqueact		: in std_logic_vector(7 downto 0);
		
		-- Parámetros de la nota actual
		nota				: in TNota;
		octava			: in std_logic_vector(2 downto 0);	
		sos				: std_logic;
		
		-- Salidas para el display de 7 segmentos
		dspiz, dspdr	: out std_logic_vector(6 downto 0)
	);
end entity display;

architecture display_arq of display is
	-- Señal de octava ampliada
	signal octava_am	: std_logic_vector(3 downto 0);

	-- Señal para el display de la octava
	signal octava_ds	: std_logic_vector(6 downto 0);

	-- Señales para el display del bloque de memoria
	signal bloque_ms, bloque_ls : std_logic_vector(6 downto 0);
begin

	-- Conversor a display 7 segmentos para la octava
	octava_ds7 : entity work.segments port map (
		entrada => octava_am,
		salida 	=> octava_ds
	);
	
	octava_am	<= '0' & octava;

	-- Conversores a display de 7 segmentos para el número de bloque
	bloque_ms_ds7 : entity work.segments port map (
		entrada => bloqueact(7 downto 4),
		salida	=> bloque_ms
	);

	bloque_ls_ds7 : entity work.segments port map (
		entrada => bloqueact(3 downto 0),
		salida	=> bloque_ls
	);


	-- Display izquierdo
	-- Muestra la nota que se escucha actualmente o en
	-- silencio el bloque de memoria activo.
	with nota select
		dspiz <=	"1110111"	when LA,
					"1111100"	when SI,
					"0111001"	when DO,
					"1011110"	when RE,
					"1111001"	when MI,
					"1110001"	when FA,
					"0111101"	when SOL,
					bloque_ms	when others;

	-- Display derecho
	-- Muestra la octava de la nota pulsada excepto si
	-- hay sostenido. En silencio muestra el dígito
	-- menos significativo del bloque de memoria en uso.

	dspdr <=	"1110110"		when sos = '1' else	-- Una especie de H
				octava_ds		when nota /= SILENCIO else
		 		bloque_ls;
					

end architecture display_arq;