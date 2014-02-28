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
	
	-- Constantes del transmisor
	constant petOrdFpga	: std_logic_vector(7 downto 0) := "10000001";
	constant petFpgaOrd	: std_logic_vector(7 downto 0) := "10000010";
	constant petSaludo	: std_logic_vector(7 downto 0) := "10000011";
	constant respAdmit	: std_logic_vector(7 downto 0) := "10001000";
	constant respOcup		: std_logic_vector(7 downto 0) := "10001001";
	constant respSaludo	: std_logic_vector(7 downto 0) := "10001011";
	
	-- Estado del transmisor
	type EstadosTransmisor is (reposo, terminando, bloque_env, bloque_rec, confirmando_env,
		confirmando_rec, enviando_h, enviando_l, recibiendo_h, recibiendo_l);
	signal estransa, estrans_sig : EstadosTransmisor;
	
	-- Buses de datos del transmisor y receptor de la UART
	signal dtx, drx : std_logic_vector(7 downto 0);
	-- Registro para la parte superior del cuadro del formato
	signal drxh, drxh_sig :std_logic_vector(7 downto 0);
	-- Contador del divisor para el reloj de la UART
	signal baudcnt : std_logic_vector (9 downto 0);
	-- Reloj de la UART
	signal baudclk : std_logic;
	
	-- Señales de activación y notificación
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
			if baudcnt = conv_std_logic_vector(325, 10) then
				baudcnt <= (others => '0');
				baudclk <= not baudclk;
			else
				baudcnt <= baudcnt + 1;
			end if;
		end if;
	end process baud_gen;
	
	-- Parte síncrona del transmisor
	sinc_trans: process (reloj, reset, estrans_sig, addr_trans_sig)
	begin
		if reset = '1' then
			estransa <= reposo;
			addr_trans <= (others => '0');

		elsif reloj'event and reloj = '1' then
			estransa <= estrans_sig;
			addr_trans <= addr_trans_sig;
			drxh <= drxh_sig;

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
		   INIT_00 => x"B207A2078007D207F207E20E9407B407A4078007D407F407E40E9607B607A607",	
			INIT_01 => x"940EB207940EB207940EB207A307A207D40EA00ED00ED107E007F007E00E9207",
			INIT_02 => x"940EB207A307A207800E941CA40EF207B40EA4079407B407A507A4079407801C",
			INIT_03 => x"E2079407A407B40E9407E207C307D207E20780078001801C940EB207940EB207",
			INIT_04 => x"9407B407A507A4079407801C940EB207940EB207940EB207A307A207800EA41C",
			INIT_05 => x"B4079407A4079407B40EA4079407B407A4079407800E941CA40EF207B40EA407",
			INIT_06 => x"C407B4078007941CA40EF207B40EA4079407B4079407A4079407B40EA4079407",
			INIT_07 => x"E207D2079407B4078007D407E407D40EC507C407B4078007D407E407D40EC507",
			INIT_08 => x"807f4e80ef41ce4ec5ea4ed43980eb4ec4ec5ed41ce4ed4e80eb4ec4ec5ed41c",
			INIT_09 => x"D40EC407B407D407E407D407C407B407D207A4079407A407B407A4079407F207",
			INIT_10 => x"F4078003F403E507E407D4078007D407E407D40EC507C407B4078007D407E407",
			INIT_11 => x"C407B4078007D407E407D40EC507C407B4078007D41CA407C507E407F40E8007",		
			INIT_12 => x"A4079407A407B407A4079407F207E207D2079407B4078007D407E407D40EC507",
			INIT_13 => x"B407D40EB4079407D207E2079407E207940EE207940ED207C307D2078007941C",
			INIT_14 => x"0000000000000000000000000000000000000000A40EB407940EE20ED2079407"
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
			aweb(i) <=	we_trans		when i = mem_trans and transfiriendo = '1' else
							we_grab		when i = mem_grab else
							'0';
	end generate we_gen;


	--
	-- ## Transmisor ##
	--

	-- Señal activa sólo cuando el transmisor está interactuando con la memoria
	with estransa select
		transfiriendo <=	'1' when enviando_h,
								'1' when enviando_l,
								'1' when recibiendo_l,
								'1' when recibiendo_h,
								'0' when others;
	
	-- Dirección de lectura/escritura en la memoria

	-- Obs: al recibir datos incrementa en el flanco en el que se escribe en la memoria,
	-- al enviar incrementa después de la última lectura de la dirección, es decir,
	-- al enviar la parte menos significativa, para anticiparse a la próxima lectura.
	addr_trans_sig <= addr_trans + 1		when estransa = recibiendo_l and rx_done = '1' else
							addr_trans + 1		when estransa = enviando_h and rx_done = '1' else 
							(others => '0')	when estransa = reposo else
							addr_trans;
	
	-- Señal de activación del emisor
	tx_start <=	-- Contestación del saludo
					'1'	when estransa = reposo		and rx_done = '1'	and drx = petSaludo else
					-- Envío de respuesta (aceptación/ocupado) sobre la transferencia
					'1'	when estransa = bloque_env and rx_done = '1' else
					'1'	when estransa = bloque_rec and rx_done = '1' else
					-- Envío del contenido de la memoria (en el modo de envío)
					'1'	when estransa = enviando_h and tx_done = '1' else
					'1'	when estransa = enviando_l and tx_done = '1' else
					'0';
	
	-- Fuente de datos del emisor (un byte)
	-- Obs: no hay que mantener en el emisor el mensaje a transmitir más allá
	-- del ciclo inicial de carga.

	-- Obs: aunque parezca raro dtx tiene la parte h (de high) en l y viceversa
	-- pues "enviando_?" es un estado de espera para finalizar el envío pero se
	-- inicia en el ciclo inmediatamente anterior. 
	dtx <=	respSaludo	when estransa = reposo		and drx = petSaludo else
				respOcup		when estransa = bloque_env and mem_repr = drx 	and (reproduciendo = '1' or grabando = '1') else
				respOcup		when estransa = bloque_rec and mem_repr = drx	and (reproduciendo = '1' or grabando = '1') else
				do_trans(15 downto 8)	when estransa = confirmando_env else
				do_trans(15 downto 8)	when estransa = enviando_l else
				do_trans(7 downto 0)		when estransa = enviando_h else
				respAdmit;

	-- Entrada de escritura de la memoria para el transmisor 
	di_trans <= drxh & drx;

	-- Registro temporal para la parte superior del cuadro del formato
	with estransa select
		drxh_sig <=	drx	when recibiendo_h,
						drxh	when others;

	-- Capacitación de escritura para el transmisor
	we_trans <= '1'  when estransa = recibiendo_l and rx_done = '1' else
					'0';

	-- Bloque de memoria de transmisor
	mem_trans_sig <=	conv_integer(drx)	when estransa = bloque_env and rx_done = '1' else
							conv_integer(drx)	when estransa = bloque_rec and rx_done = '1' else
							mem_trans;
	
	-- Transiciones del estado del transmisor
	estrans_sig <=	-- Inicio de operación en función de la petición
						terminando	when estransa = reposo	and rx_done = '1' and drx = petSaludo else
						bloque_rec	when estransa = reposo	and rx_done = '1' and drx = petOrdFpga else
						bloque_env	when estransa = reposo	and rx_done = '1' and drx = petFpgaOrd else
						-- Espera del envío de mensajes de denegación (por memoria ocupada)
						terminando	when estransa = bloque_env	and rx_done = '1' and mem_repr = drx
							and (reproduciendo = '1' or grabando = '1') else
						terminando	when estransa = bloque_rec	and rx_done = '1' and mem_repr = drx
							and (reproduciendo = '1' or grabando = '1') else
						-- En caso contrario, espera del envío de respuesta afirmativa
						confirmando_env	when estransa = bloque_env and rx_done = '1' else
						confirmando_rec	when estransa = bloque_rec and rx_done = '1' else
						-- Inicia las operaciones con la memoria (envío o recepción)
						enviando_h		when estransa = confirmando_env	and rx_done = '1' else
						recibiendo_h	when estransa = confirmando_rec	and rx_done = '1' else

						-- # Estados de espera de envíos o recepciones
						-- Termina el envío tras enviar un carácter de final (está bien: es _h)
						terminando		when estransa = enviando_h	and tx_done = '1' and mem_trans = 0 else
						reposo			when estransa = recibiendo_l and rx_done = '1' and drxh = 0 and drx = 0 else
						enviando_l		when estransa = enviando_h		and tx_done = '1' else
						recibiendo_l	when estransa = recibiendo_h	and rx_done = '1' else
						enviando_h		when estransa = enviando_l		and tx_done = '1' else
						recibiendo_h	when estransa = recibiendo_l	and rx_done = '1' else
 
						-- Vuelve al estado de reposo tras terminar la transmisión
						reposo			when estransa = terminando and tx_done = '1' else
						estransa;

end architecture archivero_arq;
