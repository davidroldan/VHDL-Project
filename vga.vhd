library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

use work.tipos.all;

entity vgacore is
	port
	(
		reset: in std_logic;	-- reset
		clk: in std_logic;
		clkdiv: in std_logic;
		hsyncb: inout std_logic;	-- horizontal (line) sync
		vsyncb: out std_logic;	-- vertical (frame) sync
		rgb: out std_logic_vector(8 downto 0); -- red,green,blue colors
      nota	: in TNota;
		sharp	: in std_logic;
		octave : in std_logic_vector(2 downto 0)
	);
end vgacore;

architecture vgacore_arch of vgacore is

signal hcnt: std_logic_vector(8 downto 0);	-- horizontal pixel counter
signal vcnt: std_logic_vector(9 downto 0);	-- vertical line counter
signal pintar: std_logic;					-- video blanking signal
signal teclaB_Pulsada, teclaB_pos : std_logic_vector(8 downto 0);
signal entradaRAM : std_logic_vector(31 downto 0);
signal entradaRAM_aux : std_logic_vector(11 downto 0);
signal tocando : std_logic;
signal d_out : std_logic_vector(31 downto 0);
signal addr2_aux : std_logic_vector(8 downto 0);
signal addr2 : std_logic_vector(7 downto 0);

type object is (teclaN, teclaB, teclaB_gris, teclaPulsada, borde, bordeNotaMov, notaMov);
signal currentobject : object;

begin

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
que_pintar: process(hcnt, vcnt, sharp, nota, octave, teclaB_pulsada, d_out)
begin
	pintar<='0';
   currentobject <= borde;
	if ((hcnt = 4 or hcnt = 252) and vcnt < 452 and vcnt > 69) then
		currentobject <= bordeNotaMov;
		pintar <= '1';
	elsif (hcnt > 3 and hcnt < 253 and (vcnt = 451 or vcnt = 70)) then
		currentobject <= bordeNotaMov;
		pintar <= '1';
	elsif hcnt > 4 and hcnt < 252 then
      if vcnt = 375 then
			pintar <= '1';
         currentobject <= borde;
		elsif vcnt = 450 then
			pintar <= '1';
         currentobject <= borde;
		--TECLADO
		elsif vcnt > 375 and vcnt < 450 then
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
		-- PARTE DE LAS NOTAS EN MOVIMIENTO
      elsif vcnt > 70 and vcnt < 371 then
			currentobject <= notaMov;
			for i in 0 to 2 loop
				if hcnt > 5 + 91*i and hcnt < 14 + 91*i and d_out(31 - 12*i) = '1' then pintar <= '1';
				elsif hcnt > 13 + 91*i and hcnt < 20 + 91*i and d_out(30 - 12*i) = '1' then pintar <= '1';
				elsif hcnt > 20 + 91*i and hcnt < 28 + 91*i and d_out(29 - 12*i) = '1' then pintar <= '1';
				elsif hcnt > 28 + 91*i and hcnt < 35 + 91*i and d_out(28 - 12*i) = '1' then pintar <= '1';
				elsif hcnt > 35 + 91*i and hcnt < 44 + 91*i and d_out(27 - 12*i) = '1' then pintar <= '1';
				elsif hcnt > 44 + 91*i and hcnt < 52 + 91*i and d_out(26 - 12*i) = '1' then pintar <= '1';
				elsif hcnt > 52 + 91*i and hcnt < 59 + 91*i and d_out(25 - 12*i) = '1' then pintar <= '1';
				elsif hcnt > 59 + 91*i and hcnt < 66 + 91*i and d_out(24 - 12*i) = '1' then pintar <= '1';
				end if;
			end loop;
			for i in 0 to 1 loop
				if hcnt > 66 + 91*i and hcnt < 73 + 91*i and d_out(23 - 12*i) = '1' then pintar <= '1';
				elsif hcnt > 73 + 91*i and hcnt < 80 + 91*i and d_out(22 - 12*i) = '1' then pintar <= '1';
				elsif hcnt > 80 + 91*i and hcnt < 87 + 91*i and d_out(21 - 12*i) = '1' then pintar <= '1';
				elsif hcnt > 87 + 91*i and hcnt < 96 + 91*i and d_out(20 - 12*i) = '1' then pintar <= '1';
				end if;
			end loop;
      end if;
   end if;
end process que_pintar;



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
						
entradaRAM_aux <= "100000000000" when nota = do and sharp = '0' else
						"010000000000" when nota = do and sharp = '1' else
						"001000000000" when nota = re and sharp = '0' else
						"000100000000" when nota = re and sharp = '1' else
						"000010000000" when nota = mi and sharp = '0' else
						"000001000000" when nota = fa and sharp = '0' else
						"000000100000" when nota = fa and sharp = '1' else
						"000000010000" when nota = sol and sharp = '0' else
						"000000001000" when nota = sol and sharp = '1' else
						"000000000100" when nota = la and sharp = '0' else
						"000000000010" when nota = la and sharp = '1' else
						"000000000001" when nota = si and sharp = '0' else
						"000000000000";

entrada_ram : process(entradaRAM_aux, octave)
begin
   if octave = "000" then
      entradaRAM <= 	entradaRAM_aux & conv_std_logic_vector(0,20);
   elsif octave = "001" then
      entradaRAM <= conv_std_logic_vector(0,12) & entradaRAM_aux & conv_std_logic_vector(0,8);
   else
      entradaRAM <= conv_std_logic_vector(0,24) & entradaRAM_aux(11 downto 4);
   end if;
end process;
				
tocando <= '0' when nota = silencio else '1';
addr2_aux <= "101110010" - vcnt(8 downto 0);
addr2 <= addr2_aux(8 downto 1);

--RAM (parte de la pantalla de arriba)
vgaRam : entity work.ram_vga port map (
		clk		=> clkdiv,
		entrada	=> entradaRAM,
      addr2    => addr2,
      do    	=> d_out
	);
						

colorear: process(pintar, hcnt, vcnt, currentobject)
begin
	if pintar='1' then rgb<="000111110";
      case currentobject is
			when teclaN => rgb <= "000000000";
			when teclaB => rgb <= "111111111";
         when teclaB_gris => rgb <= "110110110";
         when teclaPulsada => rgb <= "111000000";
			when notaMov => rgb <= "000000111";
			when borde => rgb <= "000000000";
			when bordeNotaMov => rgb <= "000111000";
			when others => rgb <= "000000000";
		end case;
	else rgb<="000000000";
	end if;
end process colorear;
---------------------------------------------------------------------------
end vgacore_arch;
