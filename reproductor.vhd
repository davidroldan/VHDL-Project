----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:51:20 12/19/2013 
-- Design Name: 
-- Module Name:    reproductor - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity reproductor is	
	port (clk : in std_logic;
			clkdiv : in std_logic;
			rst : in std_logic;
			play : in std_logic;
			addr : in std_logic_vector( 7 downto 0);
			memdir : out std_logic_vector ( 7 downto 0);
			memdata : in std_logic_vector ( 7 downto 0);
			fin : out std_logic;
			onota	: out Nota
			);
			
end reproductor;

architecture Behavioral of reproductor is
	type estado is (esperando, leyendo, reproduciendo);
	
	signal estadoa, estadosig : estado;
	signal tiempo : std_logic_vector( 7 downto 0);


begin
	sincrono : process (clk, clkdiv)
	begin
		if rst = '1' then
			estadoa <= esperando;
			tiempo <= (others => '0');
			
		elsif rising_edge(clk) then
			estadoa <= estadosig;
			case estadoa is
				when esperando =>
				
				when leyendo =>
				
				when reproduciendo =>
					
			end case;
		end if;
	end process secuencial;

	combinacional : process (esdadoa)
	
	begin
		if play = '1' then
			case estadoa is
				when esperando =>
					estadosig <= leyendo;
				when leyendo =>
					estadosig <= reproduciendo;
				when reproduciendo =>
					estadosig <= leyendo;
			end case;
		else
			estadosig <= esperando;
		end if;
		
	end process combinacional;
	
end Behavioral;

