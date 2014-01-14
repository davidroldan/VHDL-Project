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
		
		-- Activadores de reproducci�n y grabaci�n
		play	: std_logic;
		rec	: std_logic;
		stop	: std_logic;

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
	-- N�mero de bloques de RAM
	constant NRam	: Positive	:= 20;

	-- Tipos array de vectores
	type ArrayDatos is array (0 to NRam-1) of std_logic_vector(15 downto 0);

	-- Salida y entrada de datos de la memoria
	signal doa, dib: std_logic_vector(15 downto 0);
	
	-- Buses de direcciones
	signal addra, addrb	: std_logic_vector(9 downto 0);

	-- Capacitaci�n de escritura (B)
	signal aweb : std_logic_vector(0 to NRam-1);
	signal web : std_logic;

	-- Array de salidas de la memoria
	signal adoa : ArrayDatos;

	-- Memoria activa
	-- Obs: comprobado que se sintetiza como un
	-- std_logic_vector de tama�o m�nimo
	signal mem_grab : Integer range 0 to NRam-1;
	signal mem_repr : Integer range 0 to NRam-1;
begin
	-- Temporalmente
	mem_grab	<= 1;
	mem_repr	<= 2;

	-- Memorias RAM de doble puerto (para grabaci�n y reproducci�n)
	mem_gen : for i in 0 to NRam-1 generate
		mem : RAMB16_S18_S18 port map (
			doa 	=> adoa(i),
			addra => addra,
			addrb => addrb,
			dib 	=> dib,
			ena 	=> '1',
			enb 	=> '1',
			ssra 	=> '0',
			ssrb	=> '0',
			wea 	=> '0',
			web 	=> aweb(i)
		);
	end generate mem_gen;
	
	-- Reproductor
	repr : entity work.reproductor port map (
		clk		=> reloj,
		clkdiv	=> rjdiv,
		rst		=> reset,
		play		=> '0',
		addr		=> (others => '0'),
		memdir	=> addra,
		memdata	=> doa,
		fin		=> open,
		onota		=> onota,
		ooctava	=> ooctava,
		osos		=> osos
	);
	
	doa <= adoa(mem_repr);
	
	-- Grabador
	grab : entity work.grabador port map (
		reloj 	=> reloj,
		rjdiv 	=> rjdiv,
		reset		=> reset,
		nota		=> nota,
		octava	=> octava,
		sos		=> sos,
		dir_ini	=> (others => '0'),
		mem_dir	=> addrb,
		mem_dat	=> dib,
		mem_we 	=> web,
		grabar	=> '0'
	);
	
	-- Activa la escritura s�lo en la memoria ocupada
	-- por el grabador
	we_gen : for i in aweb'Range generate
			aweb(i) <= 	web	when i = mem_grab else
							'0';
	end generate we_gen;

end architecture archivero_arq;
