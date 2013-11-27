--
-- Definiciones generales
--

library ieee;
use ieee.std_logic_1164.all;

package tipos is
	-- La codificación de nota es un vector de 3 elementos
	subtype Nota is std_logic_vector(2 downto 0);

	-- Constantes de tipo Nota
	constant silencio	: Nota	:= "000";
	constant do		: Nota	:= "001";
	constant re		: Nota	:= "010";
	constant mi		: Nota	:= "011";
	constant fa		: Nota	:= "100";
	constant sol		: Nota	:= "101";
	constant la		: Nota	:= "110";
	constant si		: Nota	:= "111";

end package tipos;
