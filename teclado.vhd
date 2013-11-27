----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:05:58 11/18/2013 
-- Design Name: 
-- Module Name:    teclado - Behavioral 
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
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use work.tipos.all;

entity teclado is
	port(
		PS2DATA, PS2CLK : inout std_logic;
		reloj, reset : in std_logic;
		onda	: out std_logic;
		r, t: out std_logic_vector (6 downto 0)
	);
end teclado;

architecture Behavioral of teclado is
	component reconocedor is
		port(
			PS2DATA, PS2CLK : in std_logic;
			reset : std_logic;
			octava : out std_logic_vector(2 downto 0);
			sharp : out std_logic;
			onota : out Nota;
			r, t: out std_logic_vector (6 downto 0)
			
		);
	end component reconocedor;
	
	component gensonido is
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
	end component gensonido;
	component XX is
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
	end component XX;
	
	
	signal cableNota : Nota;
	
	signal cableSharp : std_logic;
	
	signal cableOctava : std_logic_vector(2 downto 0);

begin

	recon : reconocedor port map (
		PS2DATA => PS2DATA,
		PS2CLK => PS2CLK,
		reset => reset,
		octava => cableOctava,
		sharp => cableSharp,
		onota => cableNota,
		r => r,
		t => t
	);

	generador : gensonido port map (
		nota => cableNota,
		sharp => cableSharp,
		octave => cableOctava,
		reloj => reloj,
		reset => reset,
		onda => onda
	);
	
--	uut : XX port map (
--			PS2DATA => PS2DATA,
--			PS2CLK => PS2CLK,
--			reloj => reloj,
--			reset => reset
--	);

end Behavioral;

