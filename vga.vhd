library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

use work.tipos.all;

entity vgacore is
	port
	(
		reset: in std_logic;	-- reset
		clk: in std_logic; -- clk con la frecuencia de la pantalla
		clkdiv: in std_logic; -- clk para el movimiento de las barras de la pantalla
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
signal pintar, p_teclado, p_barras, p_rec: std_logic;					-- video blanking signal
signal currentobject, c_o_teclado, c_o_barras, c_o_rec : vga_object; -- el tipo vga_obejct esta definido en tipos.vhd

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
que_pintar: process(hcnt, vcnt, sharp, nota, octave, c_o_teclado, p_teclado, c_o_barras, p_barras, p_rec, c_o_rec)
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
		elsif hcnt > 220 and vcnt < 70 and vcnt > 43 then
			pintar <= p_rec;
			currentobject <= c_o_rec;
		--TECLADO
		elsif vcnt > 375 and vcnt < 450 then
			currentobject <= c_o_teclado;
         pintar <= p_teclado;
		-- PARTE DE LAS NOTAS EN MOVIMIENTO
      elsif vcnt > 70 and vcnt < 371 then
			currentobject <= c_o_barras;
         pintar <= p_barras;
      end if;
   end if;
end process que_pintar;
   
--Piano (teclas)
vga_tecl : entity work.vga_teclado port map	(
		hcnt  => hcnt,
		vcnt  => vcnt,
      nota  => nota,
		sharp	=> sharp,
		octave => octave,
		pintar => p_teclado,
      currentobject => c_o_teclado
	);
   
--Barras
vga_brr : entity work.vga_barras port map(
      clk   => clkdiv,
		hcnt  => hcnt,
		vcnt  => vcnt,
      nota	=> nota,
		sharp	=> sharp,
		octave => octave,
		pintar => p_barras,
      currentobject => c_o_barras
	);
	
--REC
vgarc: entity vga_recButton	port map(
		hcnt  => hcnt,
		vcnt  => vcnt,
		hcnt_aux => conv_std_logic_vector(220,9),
		vcnt_aux => conv_std_logic_vector(43,10),
		pintar => p_rec,
      currentobject => c_o_rec
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
