library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

use work.tipos.all;

entity vga_teclado is
	port
	(
		hcnt: in std_logic_vector(8 downto 0);
		vcnt: in std_logic_vector(9 downto 0);
      nota	: in TNota;
		sharp	: in std_logic;
		octave : in std_logic_vector(2 downto 0);
		pintar: out std_logic;
      currentobject: out vga_object -- el tipo vga_obejct esta definido en tipos.vhd
	);
end vga_teclado;

architecture Behavioral of vga_teclado is

signal teclaB_Pulsada, teclaB_pos : std_logic_vector(8 downto 0);

begin

   pintar_teclado: process(hcnt, vcnt, sharp, nota, octave, teclaB_pulsada)
   begin
   --NOTAS NEGRAS
         --C#
         if hcnt > 13 and hcnt < 13 + 8 and vcnt < 415 then
				pintar <= '1';
            if sharp = '1' and octave = "000" and nota = do then
               currentobject <= teclaPulsada;
				else
					currentobject <= teclaN;
            end if;
         --D#
			elsif hcnt > 28 and hcnt < 28 + 8 and vcnt < 415 then
				pintar <= '1';
            if sharp = '1' and octave = "000" and nota = re then
               currentobject <= teclaPulsada;
            else
               currentobject <= teclaN;
            end if;
			--F#
			elsif hcnt > 52 and hcnt < 52 + 8 and vcnt < 415 then
				pintar <= '1';
            if sharp = '1' and octave = "000" and nota = fa then
               currentobject <= teclaPulsada;
            else
               currentobject <= teclaN;
            end if;
			--G#
			elsif hcnt > 66 and hcnt < 66 + 8 and vcnt < 415 then
				pintar <= '1';
            if sharp = '1' and octave = "000" and nota = sol then
               currentobject <= teclaPulsada;
            else
               currentobject <= teclaN;
            end if;
			--A#
			elsif hcnt > 80 and hcnt < 80 + 8 and vcnt < 415 then
				pintar <= '1';
            if sharp = '1' and octave = "000" and nota = la then
               currentobject <= teclaPulsada;
            else
               currentobject <= teclaN;
            end if;
			--C#
			elsif hcnt > 104 and hcnt < 104 + 8 and vcnt < 415 then
				pintar <= '1';
            if sharp = '1' and octave = "001" and nota = do then
               currentobject <= teclaPulsada;
            else
               currentobject <= teclaN;
            end if;
			--D#
			elsif hcnt > 119 and hcnt < 119 + 8 and vcnt < 415 then
				pintar <= '1';
            if sharp = '1' and octave = "001" and nota = re then
               currentobject <= teclaPulsada;
            else
               currentobject <= teclaN;
            end if;
			--F#
			elsif hcnt > 143 and hcnt < 143 + 8 and vcnt < 415 then
				pintar <= '1';
            if sharp = '1' and octave = "001" and nota = fa then
               currentobject <= teclaPulsada;
            else
               currentobject <= teclaN;
            end if;
			--G#
			elsif hcnt > 157 and hcnt < 157 + 8 and vcnt < 415 then
				pintar <= '1';
            if sharp = '1' and octave = "001" and nota = sol then
               currentobject <= teclaPulsada;
            else
               currentobject <= teclaN;
            end if;
			--A#
			elsif hcnt > 171 and hcnt < 171 + 8 and vcnt < 415 then
				pintar <= '1';
            if sharp = '1' and octave = "001" and nota = la then
               currentobject <= teclaPulsada;
            else
               currentobject <= teclaN;
            end if;
			 --C#
			 elsif hcnt > 195 and hcnt < 195 + 8 and vcnt < 415 then
				pintar <= '1';
            if sharp = '1' and octave = "010" and nota = do then
               currentobject <= teclaPulsada;
            else
               currentobject <= teclaN;
            end if;
			--D#
			elsif hcnt > 210 and hcnt < 210 + 8 and vcnt < 415 then
				pintar <= '1';
            if sharp = '1' and octave = "010" and nota = re then
               currentobject <= teclaPulsada;
            else
               currentobject <= teclaN;
            end if;
			--F#
			elsif hcnt > 234 and hcnt < 234 + 8 and vcnt < 415 then
				pintar <= '1';
            if sharp = '1' and octave = "010" and nota = fa then
               currentobject <= teclaPulsada;
            else
               currentobject <= teclaN;
            end if;
			-- BORDES NEGROS DE LAS NOTAS
         elsif hcnt = 5 or hcnt = 18 or hcnt = 31 or hcnt = 44 or hcnt = 57
					or hcnt = 70 or hcnt = 83 or hcnt = 96 or hcnt = 109
					or hcnt = 122 or hcnt = 135 or hcnt = 148 or hcnt = 161
               or hcnt = 174 or hcnt = 187 or hcnt = 200 or hcnt = 213
               or hcnt = 226 or hcnt = 239 or hcnt = 251 then
				pintar <= '1';
            currentobject <= borde;
			-- NOTAS BLANCAS
			elsif hcnt > teclaB_Pulsada and hcnt < teclaB_Pulsada + 13 then
            pintar <= '1';
				currentobject <= teclaPulsada;
         elsif vcnt > 443 then
            pintar <= '1';
				currentobject <= teclaB_gris;
         else
            pintar <= '1';
				currentobject <= teclaB;
         end if;
   end process pintar_teclado;
   
   -- Determino en que posicion esta la nota que quiero pulsar (Solo notas blancas).
teclaB_pos <= conv_std_logic_vector(5,9) when nota = do else
            conv_std_logic_vector(18,9) when nota = re else
            conv_std_logic_vector(31,9) when nota = mi else
            conv_std_logic_vector(44,9) when nota = fa else
            conv_std_logic_vector(57,9) when nota = sol else
            conv_std_logic_vector(70,9) when nota = la else
            conv_std_logic_vector(83,9) when nota = si else
            conv_std_logic_vector(0,9);		
teclaB_Pulsada <= "111111111" when sharp = '1' or nota = silencio else --fuera del piano, no pinta nada
						teclaB_pos when octave = "000" else
						teclaB_pos + conv_std_logic_vector(91,9) when octave = "001" else
						teclaB_pos + conv_std_logic_vector(182,9) when octave = "010" else
						"111111111";
end Behavioral;

