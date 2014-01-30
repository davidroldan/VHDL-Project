library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.tipos.all;

library unisim;
use unisim.vcomponents.RAMB16_S18_S18;
use unisim.vcomponents.RAMB16_S4;

entity archivero is
	port (
		-- Reloj de la FPGA
		reloj	: in std_logic;
		-- Reloj
		rjdiv	: in std_logic;
		
		-- Activadores (se supone que su activación dura al menos un ciclo)
		-- Inicia la reproducción
		play	: std_logic;
		-- Inicia la grabación
		rec	: std_logic;
		-- Detiene la reproducción o la grabación
		stop	: std_logic;
		-- Selecciona el siguiente bloque de r/g
		bsig	: std_logic;
		-- Selecciona el bloque anterior de r/g
		bant	: std_logic;
		
		-- Información sobre el estado de r/g
		en_reproducion	: out std_logic;
		en_grabacion	: out std_logic;
		
		bloqueact	: out std_logic_vector(7 downto 0);

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

	-- Tipos array de datos (del tamaño de datos de la memoria)
	type ArrayDatos is array (0 to NRam-1) of std_logic_vector(15 downto 0);
	
	-- Salida y entrada de datos de la memoria
	signal doa, dib: std_logic_vector(15 downto 0);
	
	-- Buses de direcciones
	signal addra, addrb	: std_logic_vector(9 downto 0);

	-- Capacitación de escritura (B)
	signal aweb : std_logic_vector(0 to NRam-1);
	signal web : std_logic;

	-- Array de salidas de la memoria
	signal adoa : ArrayDatos;

	-- Señales booleanas grabando y reproducción
	signal grabando, grabando_sig : std_logic;
	signal reproduciendo, reproduciendo_sig : std_logic;
	
	-- Salida indicadora del fin de la reproducción por el
	-- reproductor
	signal fin_repr : std_logic;

	-- Memoria activa
	-- Obs: comprobado que se sintetiza como un
	-- std_logic_vector de tamaño mínimo
	signal mem_grab, mem_grab_sig : Integer range 0 to NRam-1;
	signal mem_repr, mem_repr_sig : Integer range 0 to NRam-1;
begin

	-- Parte síncrona (registros y demás)
	sinc : process (reloj, reset, mem_grab_sig, mem_repr_sig, reproduciendo_sig, grabando_sig)
	begin
		if reset = '1' then
			mem_grab <= 0;
			mem_repr <= 0;
		
		elsif reloj'event and reloj = '1' then
			
			mem_grab <= mem_grab_sig;
			mem_repr <= mem_repr_sig;

			reproduciendo	<= reproduciendo_sig;
			grabando			<= grabando_sig;
			
		end if;
	end process sinc;
	

	-- Memoria seleccionada para la grabación
	-- (a priori la memoria para grabación y reprodución
	-- es la misma)
	mem_grab_sig <=	0	when bsig = '1' and mem_grab = NRam-1 else
							mem_grab + 1		when bsig = '1' else
							NRam-1			when bant = '1' and mem_grab = 0 else
							mem_grab - 1		when bant = '1' else
							mem_grab;
								
	mem_repr_sig <= mem_grab_sig;

	
	-- Control del estado de grabación y reproducción
	grabando_sig	<= '1'		when rec = '1' and reproduciendo = '0' else
							'0'		when stop = '1' else
							
							-- Desactiva la grabación automáticamente cuando
							-- observa que se va a pasar
							'0'		when grabando = '1' and addrb = -2 else
							grabando;
							
	reproduciendo_sig <=	'1'	when play = '1' and grabando = '0' else
								'0'	when stop = '1' else
								
								-- Se desactiva automáticamente cuando el reproductor
								-- informa de que se ha alcanzado el final del medio
								'0'	when reproduciendo = '1' and fin_repr = '1' else
								
								reproduciendo;
								
	-- Salidas informativas de este estado
	en_reproducion	<= reproduciendo;
	en_grabacion	<= grabando;

	bloqueact	<= conv_std_logic_vector(mem_repr, bloqueact'Length);
	
	-- Memoria RAM para metadatos (de momento simple puerto)
--	mtd_mem : RAMB16_S4 port map (
--		do	=> metadatos,
--		addr	=> mtd_addr,
--		clk	=> reloj,
--		di	=> metadatos_w,
--		we	=> we_mtd,
--		en	=> '1',
--		ssr	=> '0'		
--	);


	-- Memorias RAM de doble puerto (para grabación y reproducción)
	
	-- El reproductor usará el puerto A para lectura y el
	-- grabador el puerto B para escritura
	mem_gen : for i in 0 to NRam-1 generate
		mem : RAMB16_S18_S18 generic map (
			INIT_01 => x"E60380019601B601E601F6038001B601D701F60198038001B601B801A901B801",
			INIT_02 => x"A901B801F601A8019801E60380019601B601E601F6038001B6019801F601E607",
			INIT_03 => x"B801A901B801A901B801F601A8019801E60380019601B601E601F6038001B601",
			INIT_04 => x"D701F60198038001B601B801A901B801A901B801F601A8019801E60380019601",
			INIT_05 => x"B601E601F6038001B6019801F601E6038001F6019801A801B804D601C801B801",
			INIT_06 => x"A804C601B801A8019804B601A8019801F6038001B601B8018003B801BA018003",
			INIT_07 => x"A901B8018003A901B801A901B801A901B801F601A8019801E60380019601B601",
			INIT_08 => x"E601F6038001B601D701F60198038001B601B801A901B801A901B801F601A801",
			INIT_09 => x"9801E60380019601B601E601F6038001B6019801F601E60A0000000000000000"
		) port map (
			doa 	=> adoa(i),
			addra => addra,
			addrb => addrb,
			dib 	=> dib,
			dipb	=> (others => '0'),
			ena 	=> '1',
			enb 	=> '1',
			ssra 	=> '0',
			ssrb	=> '0',
			wea 	=> '0',
			web 	=> aweb(i),
			clka	=> reloj,
			clkb	=> reloj
		);
	end generate mem_gen;
	
	-- Reproductor
	repr : entity work.reproductor port map (
		clk		=> reloj,
		clkdiv	=> rjdiv,
		rst		=> reset,
		play		=> reproduciendo,
		-- Dirección inicial a 0
		addr		=> (others => '0'),
		memdir	=> addra,
		--memdata	=> doa,
		memdata	=> (x"8000"),
		fin		=> fin_repr,
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
		-- Dirección inicial a 0
		dir_ini	=> (others => '0'),
		mem_dir	=> addrb,
		mem_dat	=> dib,
		mem_we 	=> web,
		grabar	=> grabando
	);
	
	-- Activa la escritura sólo en la memoria ocupada
	-- por el grabador
	we_gen : for i in aweb'Range generate
			aweb(i) <= 	web	when i = mem_grab else
							'0';
	end generate we_gen;
	
	-- TODO: activar la lectura también condicionalmente
	-- si es conveniente
	
end architecture archivero_arq;
