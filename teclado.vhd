----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:05:58 11/18/2013 
-- Design Name: 
-- Module Name:    teclado - Behavioral 
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

library unisim;
use unisim.vcomponents.RAMB18;

use work.tipos.all;

entity teclado is
	port(
		PS2DATA, PS2CLK : inout std_logic;
		reloj, reset : in std_logic;
		onda	: out std_logic;
		au_sdti, au_mclk, au_bclk, au_lrck : out std_logic;
		r, t: out std_logic_vector (6 downto 0);
      hsyncb: inout std_logic;	-- horizontal (line) sync
		vsyncb: out std_logic;	-- vertical (frame) sync
		rgb: out std_logic_vector(8 downto 0) -- red,green,blue colors
	);
end teclado;

architecture Behavioral of teclado is
	-- Cable para eschufar entradas y salidas unos módulos a otros
	signal cableNota : Nota;
	signal cableSharp : std_logic;
	signal cableOctava : std_logic_vector(2 downto 0);
	signal cableOnda : std_logic;

	-- Contador del divisor de la señal del reloj
	signal contdivisor : std_logic_vector(5 downto 0); -- Tamaño al azar

	-- Reloj dividido
	signal relojdiv	: std_logic;
begin
	-- Divisor de la señal de reloj para grabación y reprodución
	divisor_clk : process (reset, reloj)
	begin
		if reset = '1' then
			contdivisor <= (others => '0');

		elsif reloj'event and reloj = '1' then
			contdivisor <= contdivisor + 1;

		end if;
	end process divisor_clk;
	
	-- Memoria RAM de doble puerto (palabra 16 bits)
	mem_ram : RAMB18 port map (
		ssra => '0',
		ssrb => '0'
	);

	-- Señal de reloj dividida
	relojdiv <= contdivisor(contdivisor'length - 1);

	-- Reconocedor del teclado
	recon : entity work.reconocedor port map (
		PS2DATA => PS2DATA,
		PS2CLK => PS2CLK,
		reloj => reloj,
		reset => reset,
		octava => cableOctava,
		sharp => cableSharp,
		onota => cableNota,
		r => r,
		t => t
	);
	
	-- Códec de audio
	codec : entity work.audiocod port map (
		onda	=> cableOnda,
		au_sdti	=> au_sdti,
		au_mclk	=> au_mclk,
		au_bclk	=> au_bclk,
		au_lrck	=> au_lrck,
		reloj		=> reloj,
		reset		=> reset
	);

	-- Generador de sonidos (ondas cuadradas)
	generador : entity work.gensonido port map (
		nota => cableNota,
		sharp => cableSharp,
		octave => cableOctava,
		reloj => reloj,
		reset => reset,
		onda => cableOnda
	);
	
   pantalla: entity work.vgacore port map (
		reset => reset,	
		clock => reloj,
      hsyncb => hsyncb,
      vsyncb => vsyncb,
      rgb => rgb,
      nota => cableNota,
		sharp => cableSharp,
		octave => cableOctava
	);
   
	onda <= cableOnda;

end Behavioral;
