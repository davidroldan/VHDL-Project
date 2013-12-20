library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

use work.tipos.all;

entity vgacore is
	port
	(
		reset: in std_logic;	-- reset
		clock: in std_logic;
		hsyncb: inout std_logic;	-- horizontal (line) sync
		vsyncb: out std_logic;	-- vertical (frame) sync
		rgb: out std_logic_vector(8 downto 0); -- red,green,blue colors
      nota	: in Nota;
		sharp	: in std_logic;
		octave : in std_logic_vector(2 downto 0)
	);
end vgacore;

architecture vgacore_arch of vgacore is

signal hcnt: std_logic_vector(8 downto 0);	-- horizontal pixel counter
signal vcnt: std_logic_vector(9 downto 0);	-- vertical line counter
signal pintar: std_logic;					-- video blanking signal
signal clk, clkdiv : std_logic; 
signal contador : std_logic_vector(20 downto 0);
signal teclaB_Pulsada : integer;
signal teclaB_pos : integer;
signal entradaRAM_aux, entradaRAM : std_logic_vector(4 downto 0);
signal tocando : std_logic;
signal d_out : std_logic_vector(4 downto 0);
signal addr2 : std_logic_vector(4 downto 0);

type object is (teclaN,teclaB,teclaB_gris,teclaPulsada,borde);
signal currentobject : object;

begin

divisor: process(clock, contador, reset)

begin
if reset = '1' then
contador <= (others => '0');
elsif clock'event and clock = '1' then
	contador <= contador + 1;
end if;

clk <= contador(2);
clkdiv <= contador(20);

end process;

A: process(clk,reset)
begin
	-- reset asynchronously clears pixel counter
	if reset='1' then
		hcnt <= "000000000";
	-- horiz. pixel counter increments on rising edge of dot clock
	elsif (clk'event and clk='1') then
		-- horiz. pixel counter rolls-over after 381 pixels
		if hcnt<380 then
			hcnt <= hcnt + 1;
		else
			hcnt <= "000000000";
		end if;
	end if;
end process;

B: process(hsyncb,reset)
begin
	-- reset asynchronously clears line counter
	if reset='1' then
		vcnt <= "0000000000";
	-- vert. line counter increments after every horiz. line
	elsif (hsyncb'event and hsyncb='1') then
		-- vert. line counter rolls-over after 528 lines
		if vcnt<527 then
			vcnt <= vcnt + 1;
		else
			vcnt <= "0000000000";
		end if;
	end if;
end process;

C: process(clk,reset)
begin
	-- reset asynchronously sets horizontal sync to inactive
	if reset='1' then
		hsyncb <= '1';
	-- horizontal sync is recomputed on the rising edge of every dot clock
	elsif (clk'event and clk='1') then
		-- horiz. sync is low in this interval to signal start of a new line
		if (hcnt>=291 and hcnt<337) then
			hsyncb <= '0';
		else
			hsyncb <= '1';
		end if;
	end if;
end process;

D: process(hsyncb,reset)
begin
	-- reset asynchronously sets vertical sync to inactive
	if reset='1' then
		vsyncb <= '1';
	-- vertical sync is recomputed at the end of every line of pixels
	elsif (hsyncb'event and hsyncb='1') then
		-- vert. sync is low in this interval to signal start of a new frame
		if (vcnt>=490 and vcnt<492) then
			vsyncb <= '0';
		else
			vsyncb <= '1';
		end if;
	end if;
end process;
----------------------------------------------------------------------------
--
-- A partir de aqui escribir la parte de dibujar en la pantalla
--
-- Tienen que generarse al menos dos process uno que actua sobre donde
-- se va a pintar, decide de qué pixel a que pixel se va a pintar
-- Puede haber tantos process como señales pintar (figuras) diferentes 
-- queramos dibujar
--
-- Otro process (tipo case para dibujos complicados) que dependiendo del
-- valor de las diferentes señales pintar genera diferentes colores (rgb)
-- Sólo puede haber un process para trabajar sobre rgb
--
----------------------------------------------------------------------------
--
----------------------------------------------------------------------------
--
-- Ejemplo
que_pintar: process(hcnt, vcnt, sharp, nota, octave, teclaB_pulsada)
begin
	pintar<='0';
   currentobject <= borde;
	if hcnt > 4 and hcnt < 252 then
      if vcnt = 375 then
			pintar <= '1';
         currentobject <= borde;
		elsif vcnt = 450 then
			pintar <= '1';
         currentobject <= borde;
		elsif vcnt > 375 and vcnt < 450 then
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
         elsif hcnt = 5 or hcnt = 18 or hcnt = 31 or hcnt = 44 or hcnt = 57
					or hcnt = 70 or hcnt = 83 or hcnt = 96 or hcnt = 109
					or hcnt = 122 or hcnt = 135 or hcnt = 148 or hcnt = 161
               or hcnt = 174 or hcnt = 187 or hcnt = 200 or hcnt = 213
               or hcnt = 226 or hcnt = 239 or hcnt = 251 then
				pintar <= '1';
            currentobject <= borde;
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
      elsif vcnt > 31 and vcnt < 63 then
         if hcnt > 100 and hcnt < 120 and d_out(4) = '1' then
               pintar <= '1';
               currentobject <= teclaB;
         elsif hcnt > 120 and hcnt < 140 and d_out(3) = '1' then
               pintar <= '1';
               currentobject <= teclaB;
         elsif hcnt > 140 and hcnt < 160 and d_out(2) = '1' then
               pintar <= '1';
               currentobject <= teclaB;
         elsif hcnt > 160 and hcnt < 180 and d_out(1) = '1' then
               pintar <= '1';
               currentobject <= teclaB;
         elsif hcnt > 180 and hcnt < 200 and d_out(0) = '1' then
               pintar <= '1';
               currentobject <= teclaB;
         end if;
      end if;
   end if;
end process que_pintar;

-- Determino en que posicion esta la nota que quiero pulsar (Solo notas blancas).
teclaB_pos <= 5 when nota = do else
            18 when nota = re else
            31 when nota = mi else
            44 when nota = fa else
            57 when nota = sol else
            70 when nota = la else
            83 when nota = si else
            0;		
teclaB_Pulsada <= 300 when sharp = '1' or nota = silencio else --fuera del piano, no pinta nada
						teclaB_pos when octave = "000" else
						teclaB_pos + 91 when octave = "001" else
						teclaB_pos + 182 when octave = "010" else
						300;
						
entradaRAM_aux <= "00000" when nota = do and sharp = '0' else
				  "00001" when nota = do and sharp = '1' else
				  "00010" when nota = re and sharp = '0' else
				  "00011" when nota = re and sharp = '1' else
				  "00100" when nota = mi and sharp = '0' else
				  "00101" when nota = fa and sharp = '0' else
				  "00110" when nota = fa and sharp = '1' else
				  "00111" when nota = sol and sharp = '0' else
				  "01000" when nota = sol and sharp = '1' else
				  "01001" when nota = la and sharp = '0' else
				  "01010" when nota = la and sharp = '1' else
				  "01011" when nota = si and sharp = '0' else
				  "00000";
              
entrada_ram : process(entradaRAM_aux)
begin
   if octave = "001" then
      entradaRAM <= 	entradaRAM_aux;
   elsif octave = "010" then
      entradaRAM <= 	entradaRAM_aux + "01100";
   else
      entradaRAM <= entradaRAM_aux + "11000";
   end if;
end process;
				
tocando <= '0' when nota = silencio else '1';
addr2 <= vcnt(4 downto 0);

--RAM (parte de la pantalla de arriba)
vgaRam : entity work.ram_vga port map (
		clk		=> clkdiv,
		addr1		=> entradaRAM,
      addr2    => addr2,
		we		=> tocando,
      do    => d_out
	);
						
-- Idea, poner sombra gris abajo.
						
--5 C
--13 C#
--20 D
--28 D#
--35 E
--44 F
--52 F#
--59 G
--66 G#
--73 A
--80 A#
--87 B

--96 C
----91 + 

colorear: process(pintar, hcnt, vcnt, currentobject)
begin
	if pintar='1' then rgb<="000111110";
      case currentobject is
			when teclaN => rgb <= "000000000";
			when teclaB => rgb <= "111111111";
         when teclaB_gris => rgb <= "110110110";
         when teclaPulsada => rgb <= "111000000";
			when borde => rgb <= "000000000";
			when others => rgb <= "000000000";
		end case;
	else rgb<="000000000";
	end if;
end process colorear;
---------------------------------------------------------------------------
end vgacore_arch;