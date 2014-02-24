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
		octava, octava_baja : out std_logic_vector(2 downto 0);
		sharp : out std_logic;
		onota : out TNota;
		
		-- Señales de reproducción y grabación (permanecen
		-- activas durante exactamente un ciclo)
		btn_play	: out std_logic;
		btn_rec	: out std_logic;
		btn_stop	: out std_logic;
		btn_bsig : out std_logic;
		btn_bant	: out std_logic
	);
end reconocedor;

architecture Behavioral of reconocedor is
	-- Estado para diferenciar pulsación de suelta (acción y efecto de soltar)
	type Estado is (manosarriba, teclapulsada, soltando);
	
	-- Estado
	signal estadoa : Estado;

	-- Registro de desplazamiento con la última transmisión entrante en reposo
	-- TODO: cambiar a 10 downto 1 pues el primer bit nunca se lee
	signal mensaje : std_logic_vector (10 downto 0);
	
	-- Número de bits leídos en una misma transmisión
	signal bitsleidos : std_logic_vector(10 downto 0);
	
	-- Última tecla leída
	signal tecla : std_logic_vector(7 downto 0);
	
	-- Octava actual
	signal octava_act, octava_sig, octava_baja_signal	: std_logic_vector(2 downto 0);

	-- Retraso de la señal de teclado
	constant ps2Retraso : Positive := 16;

	-- Señal estable del reloj del teclado
	signal PS2CLK_E : std_logic;
	
	-- Biestable que recuerda el último valor conocido del reloj del teclado
	signal ps2clk_ant : std_logic;

	-- Biestable para desactivar las señales binarias pasado un ciclo
	signal senbin, senbin_sig : std_logic;
begin
	
	-- Estabiliza la señal del reloj del teclado
	stb_clk : entity work.estabilizador generic map (
		DELAY => ps2Retraso
	) port map (
		reloj		=> reloj,
		reset		=> reset,
		input		=> PS2CLK,
		output	=> PS2CLK_E
	);

	process (reloj, reset, estadoa, PS2CLK, PS2DATA, bitsleidos, mensaje)
	begin
	
		if reset = '1' then
			estadoa <= manosarriba;
			tecla <= (others => '0');
			octava_act	<= "001";
			ps2clk_ant <= '0';
			
		elsif reloj'event and reloj = '1' then
			-- Almacena el valor del reloj del teclado
			-- (visible en el ciclo siguiente)
			ps2clk_ant <= PS2CLK_E;
			
			if bitsleidos = 0 then
				senbin <= '0';
			end if;
	
			-- Atendiendo al teclado
			if PS2CLK_E /= ps2clk_ant and PS2CLK_E = '0' then

				-- Introduce en serie el mensaje en el registro
				mensaje <= PS2DATA & mensaje(10 downto 1);
			
				-- Contador: bits leídos en cada secuencia
				if bitsleidos = 0 then
					bitsleidos <= "00000000001";
				else
					bitsleidos <= bitsleidos(9 downto 0) & '0';
				end if;

			-- Lectura del mensaje completa

			-- Obs: está fuera del reloj del teclado porque cuando se escribe
			-- el último carácter leído, no es visible en registro hasta el ciclo
			-- siguiente de la FPGA

			elsif bitsleidos(bitsleidos'length-1) = '1' then
				-- Si es un "make code"
				if mensaje(8 downto 1) /= x"F0" then
					case estadoa is
						when manosarriba =>
							estadoa <= teclapulsada;
							tecla <= mensaje(8 downto 1);

						when teclapulsada =>
							-- Si pulsa una tecla sin soltar
							-- la otra queda vigente la última
							estadoa <= teclapulsada;
							tecla <= mensaje(8 downto 1);

						when others => -- subiendo
							-- Sólo se considera sin pulsar si
							-- se libera la tecla vigente
							if mensaje(8 downto 1) = tecla then
								estadoa <= manosarriba;
								tecla <= (others => '0'); -- por afabilidad
							else
								estadoa <= teclapulsada;
							end if;
					end case;		

				-- Si es un "break code"
				else
					estadoa <= soltando;
					senbin <= '1';
				
				end if;
				
				-- Modifica el valor de la octava actual
				octava_act	<= octava_sig;

				-- Ya la anterior lectura es historia
				bitsleidos <= (others => '0');
			end if;
		end if;
	end process;
	
	-- Nota pulsada
	onota <=  silencio		when tecla = x"00" else
			  do			when tecla = x"1A" or tecla = x"1B" else
			  re			when tecla = x"22" or tecla = x"23" else
			  mi			when tecla = x"21" else
			  fa			when tecla = x"2A" or tecla = x"34" else
			  sol			when tecla = x"32" or tecla = x"33" else
			  la			when tecla = x"31" or tecla = x"3B" else
			  si			when tecla = x"3A" else
			  do			when tecla = x"41" or tecla = x"4B" or tecla = x"15" or tecla = x"1E" else
			  re			when tecla = x"49" or tecla = x"4C" or tecla = x"1D" or tecla = x"26" else
			  mi			when tecla = x"4A" or tecla = x"24" else -- son la misma tecla
			  fa			when tecla = x"2D" or tecla = x"2E" else
			  sol			when tecla = x"2C" or tecla = x"36" else
			  la			when tecla = x"35" or tecla = x"3D" else
			  si			when tecla = x"3C" else
			  do			when tecla = x"43" or tecla = x"46" else
			  re			when tecla = x"44" or tecla = x"45" else
			  mi			when tecla = x"4D" else
			  fa			when tecla = x"54" or tecla = x"55" else
			  sol			when tecla = x"5B" else
			  silencio;
	
	-- Sostenido  
	sharp <= 	'1' when tecla = x"1B" or tecla = x"23" or tecla = x"34" or
							tecla = x"33" or tecla = x"3B" or tecla = x"4B" or
							tecla = x"1E" or tecla = x"4C" or tecla = x"26" or
							tecla = x"2E" or tecla = x"36" or tecla = x"3D" or
                     tecla = x"46" or tecla = x"45" or tecla = x"55"
                     else
				'0';
	
	-- Octava	 
	octava_baja_signal <= "001"			when tecla = x"41" or tecla = x"4B" or tecla = x"15" or tecla = x"1E" or
											tecla = x"49" or tecla = x"4C" or tecla = x"1D" or tecla = x"26" or
											tecla = x"4A" or tecla = x"24" or tecla = x"2D" or tecla = x"2E" or
											tecla = x"2C" or tecla = x"36" or tecla = x"35" or tecla = x"3D" or
											tecla = x"3C" else
									
								"010"			when tecla = x"43" or tecla = x"46" or
											tecla = x"44" or tecla = x"45" or tecla = x"4D" or
											tecla = x"54" or tecla = x"55" or tecla = x"5B" else
								"000";
				 
	octava <= octava_act + octava_baja_signal;
	octava_baja <= octava_baja_signal;
				
	-- Botones de reproducción, grabación y detención
	with tecla select
		btn_play <= '1' and senbin	when x"6B",
						'0'				when others;
						
	with tecla select
		btn_rec <=	'1' and senbin	when x"73",
						'0'				when others;
	
	with tecla select
		btn_stop <=	'1' and senbin	when x"74",
						'0'				when others;
						
	with tecla select
		btn_bsig	<=	'1' and senbin	when x"7A",
						'0'				when others;
	
	with tecla select
		btn_bant <=	'1' and senbin	when x"7D",
						'0'				when others;

	-- Botones de cambio de octava (falta senbin)
	octava_sig <=	octava_act + 1 when tecla = x"75" and octava_act /= "101" else
						octava_act - 1 when tecla = x"72" and octava_act /= "000" else
						octava_act;
						
end Behavioral;
