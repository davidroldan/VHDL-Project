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

use work.tipos.all;

entity teclado is
	port(
		-- Bits de datos y reloj del teclado
		PS2DATA, PS2CLK	: inout std_logic;
		reloj, reset		: in std_logic;
		
		-- Salida binaria de onda
		onda					: out std_logic;
		
		-- Salidas para el códec de audio
		au_sdti, au_mclk, au_bclk, au_lrck : out std_logic;
		
		-- Displays de 7 segmentos informativos
		dspiz, dspdr : out std_logic_vector (6 downto 0);
		
		-- LEDs informativos de activación de la grabación, la reproducción
		-- y la transferencia
		led_repr, led_grab, led_trans : out std_logic;
		
		rx : in std_logic;
		tx : out std_logic;
		
		-- Señales de comunicación VGA
      hsyncb: inout std_logic;	-- horizontal (line) sync
		vsyncb: out std_logic;	-- vertical (frame) sync
		rgb: out std_logic_vector(8 downto 0) -- red,green,blue colors
	);
end teclado;

architecture Behavioral of teclado is
	-- Cable para eschufar entradas y salidas unos módulos a otros
	signal cableNota, notaTeclado, notaRepr : TNota;
	signal cableSharp, sharpTeclado, sharpRepr : std_logic;
	signal cableOctava, cableOctavaBaja, octavaTeclado, octavaRepr : std_logic_vector(2 downto 0);
	signal cableOnda : std_logic;
	signal cableBloqueAct : std_logic_vector(7 downto 0);

	-- Contador del divisor de la señal del reloj
	signal contdivisor : std_logic_vector(24 downto 0);

	-- Reloj dividido (para el archivero)
	signal relojdiv	: std_logic;
	
	-- Relojes para VGA
	signal vga_clk		: std_logic;
	signal vga_clkdiv	: std_logic;
	
	-- Activadores de reproducción, grabación, etc.
	signal btn_play, btn_rec, btn_stop, btn_bsig, btn_bant : std_logic;
	
	-- Indicadores de estado del archivero
	signal en_reproduccion, en_grabacion, en_transferencia : std_logic;
begin

	-- Divisor de la señal de reloj
	divisor_clk : process (reset, reloj)
	begin
		if reset = '1' then
			contdivisor <= (others => '0');

		elsif reloj'event and reloj = '1' then
			contdivisor <= contdivisor + 1;

		end if;
	end process divisor_clk;

	-- Señal de reloj dividida
	relojdiv <= contdivisor(24);
	
	-- Señales divididas para pantalla
	vga_clk <= contdivisor(2);
	vga_clkdiv <= contdivisor(19);



	-- Reconocedor del teclado
	recon : entity work.reconocedor port map (
		PS2DATA		=> PS2DATA,
		PS2CLK		=> PS2CLK,
		reloj			=> reloj,
		reset			=> reset,
		octava		=> octavaTeclado,
		octava_baja => cableOctavaBaja,
		sharp			=> sharpTeclado,
		onota			=> notaTeclado,
		btn_play		=> btn_play,
		btn_rec		=> btn_rec,
		btn_stop		=> btn_stop,
		btn_bsig		=> btn_bsig,
		btn_bant		=> btn_bant
	);
	
	-- Códec de audio
	codec : entity work.audiocod port map (
		onda		=> cableOnda,
		au_sdti	=> au_sdti,
		au_mclk	=> au_mclk,
		au_bclk	=> au_bclk,
		au_lrck	=> au_lrck,
		reloj		=> reloj,
		reset		=> reset
	);

	-- Generador de sonidos (ondas cuadradas)
	generador : entity work.gensonido port map (
		nota		=> cableNota,
		sharp 	=> cableSharp,
		octave	=> cableOctava,
		reloj		=> reloj,
		reset		=> reset,
		onda		=> cableOnda
	);
	
	-- Pantalla
   pantalla: entity work.vgacore port map (
		reset		=> reset,	
		clk		=> vga_clk,
		clkdiv	=> vga_clkdiv,
      hsyncb	=> hsyncb,
      vsyncb	=> vsyncb,
      rgb		=> rgb,
      nota		=> cableNota,
		sharp		=> cableSharp,
		octave	=> cableOctavaBaja,
		en_grabacion 	=> en_grabacion,
		en_reproduccion => en_reproduccion
	);
	
	-- Display de 7 segmentos
	disp7 : entity work.display port map (
		bloqueact	=> cableBloqueAct,
		nota			=> cableNota,
		sos			=> cableSharp,
		octava		=> cableOctava,
		dspiz			=> dspiz,
		dspdr			=> dspdr
	);
	
	-- Archivero (reproductor y grabador)
	archivero: entity work.archivero port map (
		reloj		=> reloj,
		rjdiv		=> relojdiv,
		reset		=> reset,
		nota		=> notaTeclado,
		octava	=> octavaTeclado,
		sos		=> sharpTeclado,
		onota 	=> notaRepr,
		ooctava	=> octavaRepr,
		osos		=> sharpRepr,
		play		=> btn_play,
		stop		=> btn_stop,
		rec		=> btn_rec,
		bsig		=> btn_bsig,
		bant		=> btn_bant,
		en_reproducion	=> en_reproduccion,
		en_grabacion 	=> en_grabacion,
		en_transferencia => en_transferencia,
		bloqueact		=> cableBloqueAct,
		rx => rx,
		tx => tx
	);
	
	
	-- Conecta adecuadamente los datos a reproducir dependiendo
	-- de si se está grabando o no
	with en_reproduccion select
		cableNota	<= notaRepr		when '1',
							notaTeclado	when others;
	
	with en_reproduccion select
		cableOctava <= octavaRepr		when '1',
							octavaTeclado	when others;
							
	with en_reproduccion select
		cableSharp	<= sharpRepr		when '1',
							sharpTeclado	when others;
							
	-- LEDs indicativos del estado del archivero
	led_repr <= en_reproduccion;
	led_grab <= en_grabacion;
	led_trans <= en_transferencia;
	

	-- Conecta a la salida onda la onda generada
	onda <= cableOnda;
	
end Behavioral;