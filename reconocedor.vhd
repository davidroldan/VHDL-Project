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
		reset	: in std_logic;
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
	type Estado is (abajo, arriba, subiendo);
	
	-- Estado
	signal estadoa : Estado;

	-- Registro de desplazamiento con la última transmisión entrante en reposo
	signal key : std_logic_vector (10 downto 0);
	
	
	-- Número de bits leídos en una misma transmisión
	signal bitsleidos : std_logic_vector(9 downto 0);
	
	-- Última tecla leída
	signal tecla : std_logic_vector(7 downto 0);

begin
	escucha: process (PS2CLK, PS2DATA)
	begin
		pulso_reloj : if reset = '1' then
				estadoa <= arriba;
			
			elsif PS2CLK'event and PS2CLK = '0' then
			key <= PS2DATA & key(10 downto 1);
			
			-- Bits leídos en cada secuencia
			if bitsleidos = 0 then
				bitsleidos <= "0000000001";
			else
				bitsleidos <= bitsleidos(8 downto 0) & '0';
			end if;
			
			-- Conteo de pulsaciones y almacenamiento de la tecla leída
			if bitsleidos = 0 then
				if x"F0" = key(8 downto 1) then
				estadoa <= subiendo;
				else
					if estadoa = subiendo then
						estadoa <= arriba;
						
					else
						estadoa <= abajo;
						
					end if;
				end if;
			end if;

		end if pulso_reloj;
	end process escucha;
	tecla <= key(8 downto 1);
	onota <= silencio	when estadoa = arriba else
			  do			when tecla = x"1C" or tecla = x"1D" else
			  re			when tecla = x"1B" or tecla = x"24" else
			  mi			when tecla = x"23" else
			  fa			when tecla = x"2B" or tecla = x"2C" else
			  sol			when tecla = x"34" or tecla = x"35" else
			  la			when tecla = x"33" or tecla = x"3C" else
			  si			when tecla = x"3B" else
			  do			when tecla = x"42" or tecla = x"44" else
			  silencio;
			  
	sharp <= '1' when tecla = x"1D" or tecla = x"24" or tecla = x"2C" or
							tecla = x"35" or tecla = x"3C" or tecla = x"44" else
				 '0';
				 
	octava <= "010" when tecla = x"42" or tecla = x"44" else
				 "001";

	u : segments port map (key(4 downto 1), r);
	v : segments port map (key(8 downto 5), t);
end Behavioral;
