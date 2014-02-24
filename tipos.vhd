--
-- Definiciones generales
--

library ieee;
use ieee.std_logic_1164.all;

package tipos is
	-- La codificación de nota es un vector de 3 elementos
	subtype TNota is std_logic_vector(2 downto 0);

	-- Constantes de tipo TNota
	constant silencio	: TNota	:= "000";
	constant do		: TNota	:= "001";
	constant re		: TNota	:= "010";
	constant mi		: TNota	:= "011";
	constant fa		: TNota	:= "100";
	constant sol		: TNota	:= "101";
	constant la		: TNota	:= "110";
	constant si		: TNota	:= "111";
   
   -- Enumerado para saber que se está pintando en la pantalla
   type vga_object is (teclaN, teclaB, teclaB_gris, teclaPulsada, borde, bordeNotaMov, notaMov, colorVerde, colorRojo, colorAmarillo);

end package tipos;
