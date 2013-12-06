----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:29:24 10/16/2013 
-- Design Name: 
-- Module Name:    segments - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity segments is
	port (
		entrada	: in std_logic_vector(3 downto 0);
		salida	: out std_logic_vector(6 downto 0)
	);
end segments;


architecture comportamental of segments is
begin
	with entrada select
		salida <= 	"0111111"	when "0000",
				"0000110"	when "0001",
				"1011011"	when "0010",
				"1001111"	when "0011",
				"1100110"	when "0100",
				"1101101"	when "0101",
				"1111101"	when "0110",
				"0000111"	when "0111",
				"1111111"	when "1000",
				"1101111"	when "1001",
				"1110111"	when "1010",
				"1111100"	when "1011",
				"0111001"	when "1100",
				"1011110" 	when "1101",
				"1111001"	when "1110",
				"1110001"	when "1111",
				"0000000"	when others;
end comportamental;
