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
signal clk : std_logic; 
signal contador : std_logic_vector(2 downto 0);
signal teclaB_P : integer;

type object is (teclaN,teclaB,teclaPulsada,borde);
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
que_pintar: process(hcnt, vcnt)
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
			elsif hcnt > teclaB_P and hcnt < teclaB_P + 13 then
            pintar <= '1';
				currentobject <= teclaPulsada;
         else
            pintar <= '1';
				currentobject <= teclaB;
         end if;
		end if;
   end if;
end process que_pintar;

teclaB_P <= 300 when sharp = '1' else 
            5 when nota = do and octave = "000" else
            18 when nota = re and octave = "000" else
            31 when nota = mi and octave = "000" else
            44 when nota = fa and octave = "000" else
            57 when nota = sol and octave = "000" else
            70 when nota = la and octave = "000" else
            83 when nota = si and octave = "000" else
            96 when nota = do and octave = "001" else
            109 when nota = re and octave = "001" else
            122 when nota = mi and octave = "001" else
            135 when nota = fa and octave = "001" else
            148 when nota = sol and octave = "001" else
            161 when nota = la and octave = "001" else
            174 when nota = si and octave = "001" else
            187 when nota = do and octave = "010" else
            200 when nota = re and octave = "010" else
            213 when nota = mi and octave = "010" else
            226 when nota = fa and octave = "010" else
            239 when nota = sol and octave = "010" else
            300;

colorear: process(pintar, hcnt, vcnt, currentobject)
begin
	if pintar='1' then rgb<="000111110";
      case currentobject is
			when teclaN => rgb <= "000000000";
			when teclaB => rgb <= "111111111";
         when teclaPulsada => rgb <= "111000000";
			when borde => rgb <= "000000000";
			when others => rgb <= "000000000";
		end case;
	else rgb<="000000000";
	end if;
end process colorear;
---------------------------------------------------------------------------
end vgacore_arch;