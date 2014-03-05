---------------------------------------------------------------------------------
-- Company: Equipo 1
-- Engineer:
-- 
-- Design Name: Receptor de la UART
-- Module Name: uart_rx
-- Project Name: Proyecto de TOC
-- Target Devices: Xilinx Spartan 3
-- Tool versions: Xilinx ISE 14.1
--
-- Dependencies:
--
-- Description:
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity uart_rx is
	generic (
		-- N�mero de bits de datos
		DBIT	: Positive	:= 8;
		-- Duraci�n del bit de stop
		-- (ha de ser mayor o igual que 16)
		SB_TICK	: Positive	:= 16
	);
	port (
		-- Reloj principal y reset
		reloj, reset	: in std_logic;
		-- Bit del datos del puerto serie
		rx		: in std_logic;
		-- Reloj divisor por 16 de la frecuencia de transmisi�n
		rbaud		: in std_logic;
		-- Se�al de fin (se activar� durante un solo ciclo)
		fin	: out std_logic;
		-- Salida de datos recibidos en paralelo
		dout		: out std_logic_vector(DBIT-1 downto 0)
	);
end entity uart_rx;

architecture uart_rx_arq of uart_rx is
	-- Tipo estado
	type TEstado is (reposo, inicio, datos, bitstop);

	-- Registro de estado
	signal estado, estado_sig : TEstado;

	-- Registro de dato recibido
	signal dato, dato_sig : std_logic_vector(DBIT-1 downto 0);

	-- Se�al de finalizaci�n
	signal fin_reg, fin_sig : std_logic;

	-- N�mero de bits de datos recibidos
	signal nbr, nbr_sig	: Integer range 0 to DBIT-1;

	-- Fracci�n actual del periodo de transmisi�n
	-- (m�todo de sobremuestreo)
	signal frac, frac_sig	: Integer range 0 to SB_TICK-1;

	-- Valor anterior de rbaud (para detectar eventos de reloj)
	signal rbaud_ant	: std_logic;

	-- Flanco de subida de rbaud (por legibilidad)
	signal rbaud_event	: std_logic;
begin
	sec_proc : process (reloj, rbaud, reset, estado_sig, dato_sig, nbr_sig, frac_sig)
	begin
		if reset = '1' then
			estado	 <= reposo;
			dato	 <= (others => '0');	-- prescindible
			nbr	 <= 0;
			frac 		<= 0;
			rbaud_ant <= '0';
			fin_reg <= '0';

		elsif reloj'event and reloj = '1' then
			-- Actualiza el valor de rbaud_ant
			rbaud_ant <= rbaud;

			estado	 <= estado_sig;
			dato	 <= dato_sig;
			nbr	 <= nbr_sig;
			frac	 <= frac_sig;
			fin_reg <= fin_sig;

		end if;			
	end process sec_proc;

	-- # Actualizaci�n de valores en registro

	-- Se�al auxiliar que hace de evento de reloj de rbaud
	rbaud_event <=	'1'	when rbaud /= rbaud_ant and rbaud = '1' else
			'0';
	
	-- Registro de desplazamiento del dato
	dato_sig <=	rx & dato(DBIT-1 downto 1)	when estado = datos and rbaud_event = '1' and frac = 15 else
		  	dato;

	-- N�mero de bits le�dos (se incrementa de m�s)
	nbr_sig	 <=	nbr + 1	when estado = datos and rbaud_event = '1' and frac = 15 else
			0	when estado = inicio else
			nbr;

	-- Fracci�n del periodo de transmisi�n
	frac_sig <=	0	 when estado = datos and frac = 15 and rbaud_event = '1' else
					frac + 1 when estado = datos and rbaud_event = '1' else
					0			when estado = inicio and frac = 7 and rbaud_event = '1' else
					frac + 1 when estado = inicio and rbaud_event = '1' else
					frac + 1 when estado = bitstop and rbaud_event = '1' else
					0	 when estado = reposo else
					frac;
	
	-- Transici�n de estado
	estado_sig <=	inicio	when estado = reposo and rx = '0' else
						datos		when estado = inicio and frac = 7 and rbaud_event = '1' else
						bitstop	when estado = datos  and nbr = (DBIT-1) and frac = 15 and
							rbaud_event = '1' else
						reposo	when estado = bitstop and frac = (SB_TICK-1) else
						estado;	


	-- # Salidas
	
	-- Se�al de fin (bloque completo recibido)
	-- Obs: activa durante el primer ciclo de reposo
	-- tras una recepci�n
	fin_sig <=	'1'	when estado = bitstop and frac = (SB_TICK-1) else '0';

	fin <= fin_reg;

	-- Salida de datos
	dout	<= dato;

end architecture uart_rx_arq;
