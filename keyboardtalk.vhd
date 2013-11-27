--
-- Ensayo de comunicador con el teclado reutilizando componentes
--

-- Observaciones:
-- El tiempo de 60 ns es aproximado podemos aproximarlo
-- por algo m�s f�cil de comparar: 64 ns es una potencia de 2.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.ALL;

entity XX is
	port (
		-- Reloj del teclado
		PS2CLK	: inout std_logic;
		-- Puerto de datos del teclado (aqu� s�lo out)
		PS2DATA	: inout std_logic;
		-- Reloj de la FPGA
		reloj	: in std_logic;
		-- Reset 
		reset : in std_logic
	);
end entity XX;

architecture AA of XX is

	-- Constante de tama�o del contador y de la secuencia
	constant TAMC	: Positive := 13;
	constant TAMS	: Positive := 11;

	-- Tipo 'estado de la comunicaci�n'
	type EstComunic is (avisando, enviando, parado);

	-- Se�al de estado de la comunicaci�n (registro)
	signal estadc, estadc_sig : EstComunic;

	-- Entradas y salidas del contador de 12 bits (registro)
	signal cont, cont_sig	: std_logic_vector(TAMC-1 downto 0);

	-- Incremento de contador
	signal deltac : std_logic;

	-- Secuencia para el env�o (registro de desplazamiento)
	signal secuencia	: std_logic_vector(TAMS-1 downto 0);

	-- Otra entrada del comparador de salida del contador
	signal comparando	: std_logic_vector(TAMC-1 downto 0);

	-- La salida del comparador
	signal iguales		: std_logic;

	-- La salida del sumador
	signal suma		: std_logic_vector(TAMC-1 downto 0);


	-- Biestables para la sincronizaci�n entre el subsistema que se maneja
	-- con el reloj del teclado y el que se maneja con la FPGA
	signal biestFPGA, biestPS2 : std_logic;

	-- Indica si hay que contar en fase de transmisi�n
	signal hayQueContar : std_logic;

begin
	-- Implementaci�n del contador como registro
	reg_cont : process (reloj, cont_sig)
	begin
		if reloj'event and reloj = '1' then
			cont <= cont_sig;
		end if;
	end process reg_cont;

	-- Implementaci�n del estado como registro
	reg_estadc : process (reloj, estadc_sig)
	begin
		if reloj'event and reloj = '1' then
			estadc <= estadc_sig;
		end if;
	end process reg_estadc;

	-- Reflexi�n: �qu� pasa con los biestables de sincronizaci�n en el
	-- primer ciclo en el que interesa leerlos?

	-- Biestable de sincronizaci�n por la FPGA (se invierte cada vez que cuenta)
	reg_biestFPGA : process (reloj, biestFPGA, hayQueContar)
	begin
		if reloj'event and reloj = '1' then
			biestFPGA <= biestFPGA xor hayQueContar;
		end if;
	end process reg_biestFPGA;

	-- Biestable de sincronizaci�n por el teclado (se invierte en cada ciclo)
	reg_biestPS2 : process (PS2CLK, biestPS2)
	begin
		if PS2CLK'event and PS2CLK = '1' then
			biestPS2 <= not biestPS2;
		end if;
	end process reg_biestPS2;


	-- Registro de desplazamiento de la secuencia (con enable a estado = enviando)
	-- Reflexi�n: el primer golpe de reloj del teclado no tiene que consumir un
	-- d�gito de la secuencia, �no?
	regd_secuencia : process (PS2CLK, estadc, secuencia, reset)
	begin
		if reset = '1' then
			secuencia <= '0' & x"F8"  & '0' & '1';  ---comentar
		elsif PS2CLK'event and PS2CLK = '1'and estadc = enviando then
			secuencia <= secuencia(TAMS-1 downto 1) & '0';	
		end if;
	end process regd_secuencia;


	-- El 'comparando' (el otro t�rmino de la comparaci�n) como mux
	with estadc select
		comparando <=	conv_std_logic_vector(6000, TAMC) when avisando,
				conv_std_logic_vector(11, TAMC) when others;

	-- �Hay que contar?
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
	cont_sig <=	(others=>'0') when reset   = '1' else
			(others=>'0') when iguales = '1' else
			suma;

	-- Cambio de estado
	estadc_sig <=	avisando	when reset = '1' else
			avisando	when estadc = avisando and iguales = '0' else
			enviando	when estadc = avisando or (estadc = enviando and iguales = '0') else
			parado;


	-- Forzando el reloj del teclado (�qu� poner cuando no se quiere forzar?)
	with estadc select
		PS2CLK <=	'0' when avisando,
				'Z' when others;

	-- Comunicaci�n de datos con el teclado (se quiere dejar libre cuando no se usa)
	with estadc_sig select
		PS2DATA <=	secuencia(TAMS-1)	when enviando,
				'Z'		when others;

end architecture AA;
