library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.tipos.all;

entity grabador is
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

		-- Dirección inicial de escritra
		dir_ini	: in std_logic_vector(9 downto 0);

		-- Salidas para la memoria
		mem_dir	: out std_logic_vector(9 downto 0);
		mem_dat	: out std_logic_vector(15 downto 0);
		mem_we	: out std_logic;

		-- Entrada de capacitación
		-- Cuando se desactiva la grabación tarda un ciclo
		-- en escribir el carácter de finalización
		grabar	: in std_logic
	);
end entity grabador;

architecture grab_arq of grabador is
	-- Estados
	type Estado is (parado, activo, cierre);

	-- Registro de estado
	signal estadoa, estado_sig : Estado;

	-- Datos registrados
	signal r_nota	: TNota;
	signal r_octava	: std_logic_vector(2 downto 0);
	signal r_sos	: std_logic;

	-- Señal que indica si ha habido cambio en las entradas
	signal cambio	: std_logic;

	-- Contador de tiempo
	signal contador, contador_sig	: std_logic_vector(7 downto 0);

	-- Dirección de escritura
	signal dir, dir_sig	: std_logic_vector(9 downto 0);

	-- Señal de reloj dividido anterior
	signal rjdiv_ant : std_logic;
begin
	-- Reloj principal
	process (reset, reloj, estado_sig, rjdiv, dir_ini, contador, dir, nota, octava, sos, contador_sig, dir_sig)
	begin
		if reset = '1' then
			estadoa	<= parado;
			r_nota	<= nota;
			r_octava	<= octava;
			r_sos		<= sos;
			contador <= conv_std_logic_vector(1, 8);
			dir		<= dir_ini;

		elsif reloj'event and reloj = '1' then
			-- Cambia de estado
			estadoa <= estado_sig;

			-- Almacena el valor del reloj del teclado
			-- (visible en el ciclo siguiente)
			rjdiv_ant <= rjdiv;

			-- Actualiza los contadores
			contador	<= contador_sig;
			dir		<= dir_sig;

			-- Actualiza los datos registrados
			r_nota	<= nota;
			r_octava	<= octava;
			r_sos		<= sos;
		end if;
	end process;

	-- Dirección de escritura en la memoria
	mem_dir <= dir;
	
	-- Contador de duración del cuadro
	contador_sig <=	contador + 1						when estadoa = activo and rjdiv_ant /= rjdiv else
							conv_std_logic_vector(1, 8)	when estadoa = activo and cambio = '1' else
							conv_std_logic_vector(1, 8)	when estadoa = parado else
							contador;

	-- Dirección de la memoria
	dir_sig <=	dir + 1			when estadoa = activo and cambio = '1' else
					dir_ini			when estadoa = parado else		
					dir;

	-- Dato de entrada para la memoria
	with estadoa select
		mem_dat <=	'1' & r_nota & r_octava & r_sos & contador	when activo,
						(others => '0')					when others;

	-- Escritura en la memoria
	mem_we <=	'1'	when estadoa = cierre else
					'1'	when estadoa = activo and cambio = '1' else
					'0';

	-- Señal de cambio (por legibilidad)
	cambio <=	'1'	when r_nota /= nota else
					'1'	when r_octava /= octava else
					'1'	when r_sos /= sos	else
					'1'	when contador = -1 else
					'1'	when estadoa = activo and grabar = '0' else
					'0';

	-- Cambio de estado
	estado_sig <=	activo	 	when estadoa = parado and grabar = '1' else
						cierre		when estadoa = activo and grabar = '0' else
						parado		when estadoa = cierre else
						estadoa;

end architecture grab_arq;
