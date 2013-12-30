library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity ram_vga is
	 generic(N : integer := 150);
    port (clk : in std_logic;
          entrada : in std_logic_vector(31 downto 0);
          addr2 : in std_logic_vector(7 downto 0);
          do : out std_logic_vector(31 downto 0)
	);
end ram_vga;

architecture circuito  of ram_vga is
    type ram_type is array (N - 1 downto 0) of std_logic_vector(31 downto 0);
    signal RAM : ram_type := ((others => (others => '0')));
begin

    escritura : process (clk, RAM)
    begin
		-- escritura sincrona
      if rising_edge(clk) then
				for i in 0 to N - 2 loop
					RAM(i+1) <= RAM(i);
				end loop;
            RAM(0) <= entrada;
		end if;
    end process escritura;

    lectura : process (clk, RAM)
    begin
		--lectura asíncrona
		do <= RAM(conv_integer(addr2))(31 downto 0);
    end process lectura;
end circuito;
