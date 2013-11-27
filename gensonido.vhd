--
-- Generador de sonidos
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.tipos.all;

entity gensonido is
	port (
		-- Nota de acuerdo a la codificación escrita
		nota	: in Nota;
		
		-- Aplicación o no del sostenido
		sharp	: in std_logic;
		
		-- Número de octava
		octave	: in std_logic_vector(2 downto 0);
		
		-- Señal de reloj
		reloj		: in std_logic;

		-- Señal de reinicio
		reset		: in std_logic;
		
		-- Señal de salida
		onda	: out std_logic
	);
end entity gensonido;

architecture arch_gensonido of gensonido is
	-- Semiperiodo en la séptima octava
	signal sp_nat, sp_sos, sp : std_logic_vector(11 downto 0);	
	
	-- Semiperiodo con octava ajustada
	signal sp_final : std_logic_vector(17 downto 0);
	
	signal cont, cont_sig	: std_logic_vector(17 downto 0);
	
	signal t_onda : std_logic;
	
	-- Componente de tabla de notas
	component tablanotas is
		port (
			nota	: in std_logic_vector(2 downto 0);
			semiper	: out std_logic_vector(11 downto 0)
		);
	end component tablanotas;
	
	-- Componente de tabla de notas (con sostenido)
	component tablanotassos is
		port (
			nota	: in std_logic_vector(2 downto 0);
			semiper	: out std_logic_vector(11 downto 0)
		);
	end component tablanotassos;
begin

	-- Correspondencia entre notas y semiperiodos de onda
	tablanatural : tablanotas port map (
		nota => nota,
		semiper => sp_nat
	);
	
	-- Correspondencia entre notas y semiperiodos de onda (sostenido)
	tablasostenido : tablanotassos port map (
		nota => nota,
		semiper => sp_sos
	);
	
	-- Multiplexor en función de 'sharp'
	with sharp select
		sp <= sp_sos	when '1',
				sp_nat	when others;

	-- Multiplicador en función del número de octava
	-- ¿Se podrían usar desplazamientos en función de octave?
	with octave select
		sp_final <= sp &		 "000000"			when "000",
						"0" & sp & "00000"	when "001",
						"00" & sp & "0000"	when "010",
						"000"	& sp & "000"	when "011",
						"0000" & sp & "00"	when "100",
						"00000" & sp & "0"	when "101",
						"000000" & sp			when others;
	
	-- Contador que se reinicia con cada semiperiodo
	-- y biestable de la señal 'onda'
	contador : process (reloj, reset) 
	begin
		if reset = '1' then
			t_onda <= '0';
			cont <= (others => '0');

		elsif reloj'event and reloj = '1' then

			if cont_sig = sp_final then
				-- Reinicia el contador
				cont <= (others => '0');

				-- Invierte 'onda' cada semiperiodo
				if sp_final /= 0 then
					t_onda <= not t_onda;
				end if;
			else
				cont <= cont_sig;
			end if;

		end if;
	end process contador;
				
	-- El contador avanza
	cont_sig <= cont + 1;
	
	onda <= t_onda;
	
end architecture arch_gensonido;
