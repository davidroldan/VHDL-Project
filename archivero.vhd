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
		en_transferencia: out std_logic;
		
		bloqueact	: out std_logic_vector(7 downto 0);

		-- Reset
		reset	: in std_logic;

		-- Fuente de datos
		nota	: in TNota;
		octava 	: in std_logic_vector(2 downto 0);
		sos	: in std_logic;
		
		-- Puerto de serie (entrada)
		rx : in std_logic;
		
		-- Puerto de serie (salida)
		tx : out std_logic;
		
		-- Salida de datos
		onota	: out TNota;
		ooctava : out std_logic_vector(2 downto 0);
		osos	: out std_logic
	);
end entity archivero;

architecture archivero_arq of archivero is
	-- Número de bloques de RAM
	constant NRam	: Positive	:= 20;
	
	constant petOrdFpga: std_logic_vector(7 downto 0) := "10000001";
	constant petFpgaOrd: std_logic_vector(7 downto 0) := "10000010";
	constant petSaludo : std_logic_vector(7 downto 0) := "10000011";
	constant respAdmit : std_logic_vector(7 downto 0) := "10001000";
	constant respOcup : std_logic_vector(7 downto 0)  := "10001001";
	constant respSaludo: std_logic_vector(7 downto 0) := "10001011";
	
	
	type EstadosTransmisor is (reposo, saludando, espbloqlec, espbloqesc, enviandoh, enviandol, enviandoult, recibiendoh, recibiendol, recibiendoult);
	signal estransa, estranssig : EstadosTransmisor;
	
	signal dtx, drx : std_logic_vector(7 downto 0);
	signal drxh :std_logic_vector(7 downto 0);
	signal baudcnt : std_logic_vector (4 downto 0);
	signal baudclk : std_logic;
	
	signal rx_done, tx_start, tx_done : std_logic;
	
	-- Tipos array de datos (del tamaño de datos de la memoria)
	type ArrayDatos is array (0 to NRam-1) of std_logic_vector(15 downto 0);
	type ArrayDirs is array (0 to NRam-1) of std_logic_vector(9 downto 0);
	
	-- Salida y entrada de datos de la memoria
	signal do_repr, di_grab	: std_logic_vector(15 downto 0);
	signal do_trans, di_trans : std_logic_vector(15 downto 0);

	-- Señales de dirección de los componentes
	signal addr_repr, addr_grab, addr_trans, addr_trans_sig : std_logic_vector(9 downto 0);

	-- Array de direcciones para los puertos A y B de las memorias
	signal addra, addrb	: ArrayDirs;
	
	-- Array de salidas de datos para los puertos A y B de las memorias
	signal adoa, adob : ArrayDatos;

	-- Capacitación de escritura (B)
	signal aweb : std_logic_vector(0 to NRam-1);
	signal we_grab, we_trans : std_logic;

	-- Señales booleanas grabando y reproduciendo
	signal grabando, grabando_sig : std_logic;
	signal reproduciendo, reproduciendo_sig : std_logic;
	signal transfiriendo : std_logic;

	-- Salida indicadora del fin de la reproducción por el
	-- reproductor
	signal fin_repr : std_logic;

	-- Memoria activa
	-- Obs: comprobado que se sintetiza como un
	-- std_logic_vector de tamaño mínimo
	signal mem_grab, mem_grab_sig : Integer range 0 to NRam-1;
	signal mem_repr, mem_repr_sig : Integer range 0 to NRam-1;
	signal mem_trans, mem_trans_sig: Integer range 0 to NRam-1;
begin

	-- Parte síncrona (registros y demás)
	sinc : process (reloj, reset, mem_grab_sig, mem_repr_sig, reproduciendo_sig, grabando_sig, mem_trans_sig)
	begin
		if reset = '1' then
			mem_grab <= 0;
			mem_repr <= 0;
			mem_trans <= 0;
			reproduciendo <= '0';
			grabando <= '0';
		elsif reloj'event and reloj = '1' then
			mem_grab <= mem_grab_sig;
			mem_repr <= mem_repr_sig;
			mem_trans <= mem_trans_sig;
			reproduciendo	<= reproduciendo_sig;
			grabando			<= grabando_sig;
			
		end if;
	end process sinc;
	
	-- Generador de baudios
	baud_gen: process(reloj, reset)
	begin
		if reset = '1' then
			baudcnt <= (others => '0');
			baudclk <= '0';

		elsif reloj'event and reloj = '1' then
			if baudcnt = conv_std_logic_vector(325, 5) then
				baudcnt <= (others => '0');
				baudclk <= not baudclk;
			else
				baudcnt <= baudcnt + 1;
			end if;
		end if;
	end process baud_gen;
	
	sinc_trans: process (reloj, reset, estranssig, addr_trans_sig)
	begin
		if reset = '1' then
			estransa <= reposo;
			addr_trans <= (others => '0');

		elsif reloj'event and reloj = '1' then
			estransa <= estranssig;
			addr_trans <= addr_trans_sig;

		end if;
	end process sinc_trans;
	

	-- Memoria seleccionada para la grabación
	-- (a priori la memoria para grabación y reprodución
	-- es la misma)
	mem_grab_sig <=	0					when bsig = '1' and mem_grab = NRam-1 else
							mem_grab + 1	when bsig = '1' else
							NRam-1			when bant = '1' and mem_grab = 0 else
							mem_grab - 1	when bant = '1' else
							mem_grab;
								
	mem_repr_sig <= mem_grab_sig;

	
	-- Control del estado de grabación y reproducción
	grabando_sig	<= '1'		when rec = '1' and reproduciendo = '0' and transfiriendo = '0' else
							'0'		when stop = '1' else
							
							-- Desactiva la grabación automáticamente cuando
							-- observa que se va a pasar
							'0'		when grabando = '1' and addr_grab = -2 else
							grabando;
							
	reproduciendo_sig <=	'1'	when play = '1' and grabando = '0' and transfiriendo = '0' else
								'0'	when stop = '1' else
								
								-- Se desactiva automáticamente cuando el reproductor
								-- informa de que se ha alcanzado el final del medio
								'0'	when reproduciendo = '1' and fin_repr = '1' else
								
								reproduciendo;


	-- Señales informativas exteriores del estado
	en_reproducion	 <= reproduciendo;
	en_grabacion	 <= grabando;
	en_transferencia <= transfiriendo;

	bloqueact	<= conv_std_logic_vector(mem_repr, bloqueact'Length);
	

	-- Memorias RAM de doble puerto (para grabación y reproducción)
	
	-- El reproductor usará el puerto A para lectura y el
	-- grabador el puerto B para escritura
	-- El trasmisor usará el puerto B para lectura y el
	-- A para escritura
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
			dob	=> adob(i),
			addra => addra(i),
			addrb => addrb(i),
			dia	=> di_trans,
			dipa	=> (others => '0'),
			dib 	=> di_grab,
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
		memdir	=> addr_repr,
		memdata	=> do_repr,
		fin		=> fin_repr,
		onota		=> onota,
		ooctava	=> ooctava,
		osos		=> osos
	);
	
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
		mem_dir	=> addr_grab,
		mem_dat	=> di_grab,
		mem_we 	=> we_grab,
		grabar	=> grabando
	);
	
	-- Receptor 
	u_rx : entity work.uart_rx port map (
		reloj => reloj,
		reset => reset,
		rx 	=> rx,
		rbaud => baudclk,
		fin 	=> rx_done,
		dout 	=> drx
	);
	
	-- Transmisor
	u_tx : entity work.uart_tx port map (
		reloj 			=> reloj,
		reset 			=> reset,
		tx_start 		=> tx_start,
		rbaud 			=> baudclk,
		din 				=> dtx,
		tx_done_tick 	=> tx_done,
		tx 				=> tx
	);
	
	-- Distribución de la señal de salida de datos en A y B
	do_repr <= adoa(mem_repr);
	do_trans <= adob(mem_trans);
	

	-- Distribución de la señal de dirección de los puerto A y B

	-- Obs: por defecto las entradas de direcciones de todas las memorias
	-- en los puertos A y B son la salidas correspondientes del reproductor
	-- y del grabador respectivamente. Cuando está activa la transferencia
	-- se coloca su dirección en su bloque de memoria.
	addr_gen : for i in addra'Range generate
		addra(i)	<=	addr_trans	when i = mem_trans and transfiriendo = '1' else
						addr_repr;

		addrb(i) <=	addr_trans	when i = mem_trans and transfiriendo = '1' else
						addr_grab;
	end generate addr_gen;
	
	
	-- Activa la escritura sólo en la memoria ocupada
	-- por el grabador o por el transmisor
	we_gen : for i in aweb'Range generate
			aweb(i) <= 	we_grab		when i = mem_grab and grabando = '1' else
							we_trans		when i = mem_trans and transfiriendo = '1' else
							'0';
	end generate we_gen;


	--
	-- ## Transmisor ##
	--

	-- Señal activa sólo cuando el transmisor está interactuando con la memoria
	transfiriendo <= '1' when estransa /= reposo and estransa /= saludando and estransa /= espbloqlec and estransa /= espbloqesc else
							'0';
	
	-- Dirección de lectura/escritura en la memoria (TODO: está mal)
	addr_trans_sig <= addr_trans + 1 when rx_done = '1' and transfiriendo = '1' else
							conv_std_logic_vector(0, addr_trans'length) when estransa = reposo else
							addr_trans;
	
	-- Señal de activación del emisor
	tx_start <= '1' when estransa = reposo and dtx = petSaludo	and rx_done = '1' else
					'1' when estransa = espbloqlec and rx_done = '1' else
					'1' when estransa = espbloqesc and rx_done = '1' else
					'1' when (estransa = enviandoh or estransa = enviandol) and tx_done = '1' else
					'0';
	
	-- Fuente de datos del transmisor (un byte)
	dtx <= respSaludo when estransa = reposo and dtx = petSaludo	and rx_done = '1' else
					respOcup when estransa = espbloqlec and mem_repr = drx  and (reproduciendo = '1' or grabando = '1') else
					respOcup when estransa = espbloqesc and mem_repr = drx and (reproduciendo = '1' or grabando = '1') else
					do_trans(15 downto 8) when estransa = enviandoh else
					do_trans(7 downto 0) when estransa = enviandol else
					respAdmit;

	-- Entrada de escritura de la memoria para el transmisor 
	di_trans <= drxh & drx;
	
	-- Capacitación de escritura para el transmisor
	we_trans <= '1'  when estransa = recibiendol and rx_done = '1' else
					'0';

	-- Bloque de memoria de transmisor
	mem_trans_sig <= conv_integer(drx) when estransa = espbloqlec and rx_done = '1' else
							conv_integer(drx)	when estransa = espbloqesc and rx_done = '1' else
							mem_trans;
	
	-- Estado del transmisor
	estranssig <= saludando when estransa = reposo and dtx = petSaludo and rx_done = '1' else
					  espbloqlec when estransa = reposo and dtx = petOrdFpga and rx_done = '1' else
					  espbloqesc when estransa = reposo and dtx = petFpgaOrd and rx_done = '1' else
					  saludando when (estransa = espbloqlec or estransa = espbloqesc) and mem_repr = drx and (reproduciendo = '1' or grabando = '1') else
					  enviandoh when estransa = espbloqlec and rx_done = '1' else
					  enviandoult when estransa = enviandoh and rx_done = '1' and do_trans = 0 else
					  enviandol when estransa = enviandoh and tx_done = '1' else
					  enviandoh when estransa = enviandol and rx_done = '1' else
					  recibiendoh when estransa = espbloqesc and rx_done = '1' else
					  recibiendoult when estransa = recibiendoh and rx_done = '1' and drx = 0 else
					  recibiendol when estransa = recibiendoh and rx_done ='1' else
					  recibiendoh when estransa = recibiendol and rx_done ='1' else
					  reposo when estransa = enviandoult and tx_done ='1' else
					  reposo when estransa = saludando else
					  estransa;

end architecture archivero_arq;
