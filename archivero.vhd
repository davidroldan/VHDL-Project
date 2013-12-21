library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.tipos.all;

library unisim;
use unisim.vcomponents.RAMB16_S18_S18;

entity archivero is
	port (
		-- Reloj de la FPGA
		reloj	: in std_logic;
		-- Reloj
		rjdiv	: in std_logic;

		-- Reset
		reset	: in std_logic;

		-- Fuente de datos
		nota	: in Nota;
		octava 	: in std_logic_vector(2 downto 0);
		sos	: in std_logic;

		-- Salida de datos
		onota	: out Nota;
		ooctava : out std_logic_vector(2 downto 0);
		osos	: out std_logic
	);
end entity archivero;

architecture archivero_arq of archivero is
	-- Salida y entrada de datos de la memoria
	signal doa, dib: std_logic_vector(15 downto 0);
	
	-- Buses de direcciones
	signal addra, addrb	: std_logic_vector(9 downto 0);

	-- Capacitación de escritura (B)
	signal web : std_logic;
begin

	-- Memoria RAM de doble puerto (palabra 16 bits)
	mem : RAMB16_S18_S18 port map (
		doa => doa,
		addra => addra,
		addrb => addrb,
		dib => dib,
		ena => '1', -- De momento
		enb => '1', -- De momento
		ssra => '0',
		ssrb => '0',
		wea => '0',
		web => web
	);
	
	-- Reproductor
	repr : entity work.reproductor port map (
		clk	=> reloj,
		clkdiv => rjdiv,
		rst => reset,
		play => '0',
		addr => (others => '0'),
		memdir => addra,
		memdata => doa,
		fin => open,
		onota	=> onota
	);
	
	-- Grabador
	grab : entity work.grabador port map (
		reloj => reloj,
		rjdiv => rjdiv,
		reset	=> reset,
		nota	=> nota,
		octava=> octava,
		sos	=> sos,
		dir_ini => (others => '0'),
		mem_dir => addrb,
		mem_dat => dib,
		grabar => '0'
	);

end architecture archivero_arq;
