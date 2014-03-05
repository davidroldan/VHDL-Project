----------------------------------------------------------------------------------
-- Company: Equipo 1
-- Engineer:
-- 
-- Design Name: Reproductor
-- Module Name: reproductor
-- Project Name: Proyecto de TOC
-- Target Devices: Xilinx Spartan 3
-- Tool versions: Xilinx ISE 14.1
--
-- Dependencies:
--
-- Description:
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.tipos.all;

entity reproductor is	
	port (
		-- Reloj de la FPGA
		clk : in std_logic;
		-- Reloj
		clkdiv : in std_logic;
		-- Reset
		rst : in std_logic;
		
		-- Señal de control
		play : in std_logic;
			
		-- dirección inicial de lectura
		addr : in std_logic_vector(9 downto 0);
			
		-- Interacción con memoria
		memdir : out std_logic_vector (9 downto 0);
		memdata : in std_logic_vector (15 downto 0);
		
		-- Datos de salida
		onota	: out TNota;
		ooctava : out std_logic_vector(2 downto 0);
		osos : out std_logic;
		
		-- Señal de fin de reproducción
		fin : out std_logic
	);
			
end reproductor;

architecture Behavioral of reproductor is
	type estado is (esperando, leyendo, reproduciendo);
	
	signal estadoa, estadosig : estado;
	signal tiempo : std_logic_vector(7 downto 0);
	signal dirsig : std_logic_vector(9 downto 0);
	signal clkdiv_ant : std_logic;
	
begin
	memdir <= dirsig;
	
	sincrono : process (clk, clkdiv, rst)
	begin
		if rst = '1' then
			estadoa <= esperando;
			tiempo <= (others => '0');
			clkdiv_ant <= '0';
			
		elsif rising_edge(clk) then
			clkdiv_ant <= clkdiv;
			estadoa <= estadosig;
			
			case estadoa is
				when esperando =>
					dirsig <= addr;
					tiempo <= memdata(7 downto 0);

				when leyendo =>
					tiempo <= memdata(7 downto 0);
					
				when reproduciendo =>
					if tiempo = 0 then
						dirsig <= dirsig + 1;
						
					elsif clkdiv_ant /= clkdiv and clkdiv = '1' then
						tiempo <= tiempo - 1;
	
					end if;
			end case;
		end if;
	end process sincrono;


	estadosig <=	reproduciendo	when estadoa = esperando and play = '1' else
						esperando	when play = '0' or memdata = 0 else
						leyendo		when tiempo = 0 else
						reproduciendo	when estadoa = leyendo else
						estadoa;
	
	-- Señal de fin que dura un 
	fin <=	'1' when memdata = 0 else
				'0';


	onota <= memdata(14 downto 12);
	ooctava <= memdata (11 downto 9);
	osos <= memdata(8);

end Behavioral;
