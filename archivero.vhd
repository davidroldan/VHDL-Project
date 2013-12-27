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
		nota	: in TNota;
		octava 	: in std_logic_vector(2 downto 0);
		sos	: in std_logic;

		-- Salida de datos
		onota	: out TNota;
		ooctava : out std_logic_vector(2 downto 0);
		osos	: out std_logic
	);
end entity archivero;

architecture archivero_arq of archivero is
	-- Número de bloques de RAM
	constant NRam	: Positive	:= 20;

	-- Tipos array de vectores
	type ArrayDatos is array (0 to NRam-1) of std_logic_vector(15 downto 0);

	-- Salida y entrada de datos de la memoria
	signal doa, dib: std_logic_vector(15 downto 0);
	
	-- Buses de direcciones
	signal addra, addrb	: std_logic_vector(9 downto 0);

	-- Capacitación de escritura (B)
	signal web : std_logic;

	-- Array de salidas y entradas de la memoria
	signal adoa : ArrayDatos;
	signal adib : ArrayDatos;

	-- Memoria activa
	-- Obs: comprobado que se sintetiza como un
	-- std_logic_vector de tamaño mínimo
	signal mem_grab : Integer range 0 to NRam-1;
	signal mem_repr : Integer range 0 to NRam-1;
begin
	-- Temporalmente
	mem_grab	<= 1;
	mem_repr	<= 2;

	-- Memorias RAM de doble puerto (para grabación y reproducción)
	mem_gen : for i in 0 to NRam-1 generate
		mem : RAMB16_S18_S18 port map (
			doa => adoa(i),
			addra => addra,
			addrb => addrb,
			dib => adib(i),
			ena => '1',
			enb => '1',
			ssra => '0',
			ssrb => '0',
			wea => '0',
			web => web
		);
	end generate mem_gen;
	
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
	
	doa <= adoa(mem_repr);
	
	-- Grabador
	grab : entity work.grabador port map (
		reloj => reloj,
		rjdiv => rjdiv,
		reset	=> reset,
		nota	=> inota,
		octava=> octava,
		sos	=> sos,
		dir_ini => (others => '0'),
		mem_dir => addrb,
		mem_dat => dib,
		grabar => '0'
	);
	
	dib <= adib(mem_grab);

end architecture archivero_arq;
