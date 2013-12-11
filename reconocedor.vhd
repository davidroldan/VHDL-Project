----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:50:01 10/15/2013 
-- Design Name: 
-- Module Name:    reconocedor - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

use work.tipos.all;

entity reconocedor is
	port(
		PS2DATA, PS2CLK : in std_logic;
		reset, reloj	: in std_logic;
		octava : out std_logic_vector(2 downto 0);
		sharp : out std_logic;
		onota : out Nota;

		r, t: out std_logic_vector (6 downto 0)
	);
end reconocedor;

architecture Behavioral of reconocedor is
	-- Conversor a 7 segmentos
	component segments is
		port (
			entrada	: in std_logic_vector(3 downto 0);
			salida	: out std_logic_vector(6 downto 0)
		);
	end component segments;

	-- Estado para diferenciar pulsación de suelta (acción y efecto de soltar)
	type Estado is (callado, sonando);
	
	-- Estado
	signal estadoa : Estado;

	-- Registro de desplazamiento con la última transmisión entrante en reposo
	signal mensaje : std_logic_vector (10 downto 0);
	
	-- Número de bits leídos en una misma transmisión
	signal bitsleidos : std_logic_vector(9 downto 0);
	
	-- Última tecla leída
	signal tecla : std_logic_vector(7 downto 0);
	
	-- Contador del tiempe desde la última nota leída
	signal caducidad : std_logic_vector(23 downto 0);

	-- Retraso de la señal de teclado
	constant ps2Retraso : Positive := 16;

	-- Señal estable del reloj del teclado
	signal PS2CLK_E : std_logic;
	
	-- Biestable que recuerda el último valor conocido del reloj del teclado
	signal ps2clk_ant : std_logic;

begin
	
	-- Estabiliza la señal del reloj del teclado
	stb_clk : entity work.estabilizador generic map (
		DELAY => ps2Retraso
	) port map (
		reloj		=> reloj,
		reset		=> reset,
		input		=> PS2CLK,
		output		=> PS2CLK_E
	);

	process (reloj, reset, estadoa, caducidad, PS2CLK, PS2DATA, bitsleidos, mensaje)
	begin
	
		if reset = '1' then
			estadoa <= callado;
			caducidad <= (others => '0');
			ps2clk_ant <= '1';
			
		elsif reloj'event and reloj = '1' then
			-- Almacena el valor del reloj del teclado
			-- (visible en el ciclo siguiente)
			ps2clk_ant <= PS2CLK_E;
			
			-- Independiente del teclado
			if estadoa = callado then
				caducidad <= (others => '0');

			elsif caducidad + 1 = 0 then
				estadoa <= callado;

			else
				caducidad <= caducidad + 1;
			end if;
	
			-- Atendiendo al teclado
			if PS2CLK_E /= ps2clk_ant and PS2CLK_E = '0' then

				-- Introduce en serie el mensaje en el registro
				mensaje <= PS2DATA & mensaje(10 downto 1);
				
				-- Se ha pulsado una tecla: la caducidad se renueva
				caducidad <= (others => '0');

				-- Lectura del mensaje completa
				if bitsleidos = 0 then
					if mensaje(8 downto 1) /= x"F0" then
						estadoa <= sonando;
						tecla <= mensaje(8 downto 1);

					end if;
				end if;
			
				-- Contador: bits leídos en cada secuencia
				if bitsleidos = 0 then
					bitsleidos <= "0000000001";
				else
					bitsleidos <= bitsleidos(8 downto 0) & '0';
				end if;
			end if;
		end if;
	end process;
	
	-- Nota pulsada
	onota <= silencio	when estadoa = callado else
			  do			when tecla = x"1C" or tecla = x"1D" else
			  re			when tecla = x"1B" or tecla = x"24" else
			  mi			when tecla = x"23" else
			  fa			when tecla = x"2B" or tecla = x"2C" else
			  sol			when tecla = x"34" or tecla = x"35" else
			  la			when tecla = x"33" or tecla = x"3C" else
			  si			when tecla = x"3B" else
			  do			when tecla = x"42" or tecla = x"44" else
			  silencio;
	
	-- Sostenido  
	sharp <= '1' when tecla = x"1D" or tecla = x"24" or tecla = x"2C" or
							tecla = x"35" or tecla = x"3C" or tecla = x"44" else
				 '0';
	
	-- Octava	 
	octava <= "010" when tecla = x"42" or tecla = x"44" else
				 "001";

	u : segments port map (tecla(7 downto 4), r);
	v : segments port map (tecla(3 downto 0), t);
end Behavioral;
