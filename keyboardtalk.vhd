--
-- Ensayo de comunicador con el teclado reutilizando componentes
--

-- Observaciones:
-- El tiempo de 60 ns es aproximado podemos aproximarlo
-- por algo más fácil de comparar: 64 ns es una potencia de 2.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.ALL;

entity XX is
	port (
		-- Reloj del teclado
		PS2CLK	: inout std_logic;
		-- Puerto de datos del teclado (aquí sólo out)
		PS2DATA	: inout std_logic;
		-- Reloj de la FPGA
		reloj	: in std_logic;
		-- Reset
		reset : in std_logic
	);
end entity XX;

architecture AA of XX is

	-- Constante de tamaño del contador y de la secuencia
	constant TAMC	: Positive := 13;
	constant TAMS	: Positive := 11;

	-- Tipo 'estado de la comunicación'
	type EstComunic is (avisando, enviando, parado);

	-- Señal de estado de la comunicación (registro)
	signal estadc, estadc_sig : EstComunic;

	-- Entradas y salidas del contador de 12 bits (registro)
	signal cont, cont_sig	: std_logic_vector(TAMC-1 downto 0);

	-- Incremento de contador
	signal deltac : std_logic;

	-- Secuencia para el envío (registro de desplazamiento)
	signal secuencia	: std_logic_vector(TAMS-1 downto 0);

	-- Otra entrada del comparador de salida del contador
	signal comparando	: std_logic_vector(TAMC-1 downto 0);

	-- La salida del comparador
	signal iguales		: std_logic;

	-- La salida del sumador
	signal suma		: std_logic_vector(TAMC-1 downto 0);


	-- Biestables para la sincronización entre el subsistema que se maneja
	-- con el reloj del teclado y el que se maneja con la FPGA
	signal biestFPGA, biestPS2 : std_logic;

	-- Indica si hay que contar en fase de transmisión
	signal hayQueContar : std_logic;

begin
	-- Registros (reloj de la FPGA)
	fpga_proc : process (reloj, reset, cont_sig, estadc_sig, biestFPGA, hayQueContar)
	begin
		if reset = '1' then
			-- Reinicia el contador
			cont <= (others => '0');
	
			biestFPGA <= '0';
		elsif reloj'event and reloj = '1' then
			-- Registros de contador y estado
			cont	<= cont_sig;
			estadc	<= estadc_sig;

			-- Biestable de la FPGA (se invierte cuando cuenta)
			biestFPGA <= biestFPGA xor hayQueContar;
		end if;
	end process fpga_proc;

	-- Reflexión: ¿qué pasa con los biestables de sincronización en el
	-- primer ciclo en el que interesa leerlos?
	
	-- Reflexión: el primer golpe de reloj del teclado no tiene que consumir un
	-- dígito de la secuencia, ¿no?
	-- Biestable de sincronización por el teclado (se invierte en cada ciclo)
	ps2_proc : process (PS2CLK, reset, biestPS2)
	begin
		if reset = '1' then
			biestPS2 <= '0';
			
			secuencia <= '0' & x"F8" & '0' & '1'; --comentar
			
		elsif PS2CLK'event and PS2CLK = '1' then
			biestPS2 <= not biestPS2;
			
			-- Registro de desplazamiento de la secuencia (con enable a estado = enviando)
			if estadc = enviando then
				secuencia <= '0' & secuencia(TAMS-1 downto 1);
			end if;
		end if;
	end process ps2_proc;

	-- El 'comparando' (el otro término de la comparación) como mux
	with estadc select
		comparando <=	conv_std_logic_vector(6000, TAMC) when avisando,
				conv_std_logic_vector(11, TAMC) when others;

	-- ¿Hay que contar?
	hayQueContar <= biestFPGA xor biestPS2;

	-- El incremento de contador
	with estadc select
		deltac <=	'1' when avisando,
				hayQueContar when others;

	-- El comparador
	iguales <=	'1' when cont = comparando else
			'0';

	-- El sumador de 12 bits
	suma <=		cont + (conv_std_logic_vector(0, TAMC-1) & deltac);

	-- El cambio de estado del contador
	cont_sig <=	(others=>'0') when iguales = '1' else
			suma;

	-- Cambio de estado
	estadc_sig <=	avisando	when reset = '1' else
			avisando	when estadc = avisando and iguales = '0' else
			enviando	when estadc = avisando or (estadc = enviando and iguales = '0') else
			parado;


	-- Forzando el reloj del teclado (¿qué poner cuando no se quiere forzar?)
	with estadc select
		PS2CLK <=	'0' when avisando,
				'Z' when others;

	-- Comunicación de datos con el teclado (se quiere dejar libre cuando no se usa)
	with estadc_sig select
		PS2DATA <=	secuencia(0)	when enviando,
				'Z'		when others;

end architecture AA;
