
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

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
		osos : out std_logic
		
		-- Señal de fin de reproducción
		fin : out std_logic;
	);
			
end reproductor;

architecture Behavioral of reproductor is
	type estado is (esperando, reproduciendo);
	
	signal estadoa, estadosig : estado;
	signal tiempo : std_logic_vector( 7 downto 0);
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
					tiempo <= (others => '0');			
					
				when reproduciendo =>
					if tiempo = 0 then
						dirsig <= dirsig + 1;
						tiempo <= memdata(7 downto 0);
						
					elsif clkdiv_ant /= clkdiv and clkdiv = '1' then
						tiempo <= tiempo - 1;
	
					end if;
			end case;
		end if;
	end process sincrono;


	estadosig <= esperando when play = '0' OR memdata = 0
				else reproduciendo;
	
	with estadoa select
		fin <= '1' when esperando
				'0' when others;
				
				
	onota <= memdata(14 downto 12)
	ooctava <= memdata (11 downto 9);
	osos <= memdata(8);
	
end Behavioral;

