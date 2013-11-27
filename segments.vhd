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
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

ENTITY segments IS
PORT(
          aa,bb,cc,dd   : IN std_logic;
          salida     : OUT std_logic_vector(6 downto 0));
END segments;

ARCHITECTURE comportamental OF segments IS
SIGNAL pepe : std_logic_VECTOR(3 DOWNTO 0);
SIGNAL SAL  : std_logic_VECTOR(6 DOWNTO 0);
BEGIN
    PROCESS
        BEGIN
            pepe <= aa & bb & cc & dd;
            CASE pepe IS
                 WHEN "0000" => SAL <="0111111";
                 WHEN "0001" => SAL <="0000110";
                 WHEN "0010" => SAL <="1011011";
                 WHEN "0011" => SAL <="1001111";
                 WHEN "0100" => SAL <="1100110";
                 WHEN "0101" => SAL <="1101101";
                 WHEN "0110" => SAL <="1111101";
                 WHEN "0111" => SAL <="0000111";
                 WHEN "1000" => SAL <="1111111";
                 WHEN "1001" => SAL <="1101111";
                 WHEN "1010" => SAL <="1110111";
                 WHEN "1011" => SAL <="1111100";
                 WHEN "1100" => SAL <="0111001";
                 WHEN "1101" => SAL <="1011110";
                 WHEN "1110" => SAL <="1111001";
                 WHEN "1111" => SAL <="1110001";
                 WHEN OTHERS => SAL <="0000000";
             END CASE;
    END PROCESS;
salida <= SAL;
END comportamental; 