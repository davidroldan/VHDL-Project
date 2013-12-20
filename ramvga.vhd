library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity ram_vga is
	 generic(N : integer := 50);
    port (clk : in std_logic;
          addr1 : in std_logic_vector(4 downto 0);
          addr2 : in std_logic_vector(4 downto 0);
          we : in std_logic;
          do : out std_logic_vector(4 downto 0)
	);
end ram_vga;

architecture circuito  of ram_vga is
    type ram_type is array (N - 1 downto 0) of std_logic_vector(31 downto 0);
    signal RAM : ram_type:=((others => (others => '0')));
begin

    escritura : process (clk)
    begin
		-- escritura sincrona
      if rising_edge(clk) then
				for i in 0 to N - 2 loop
					RAM(i+1) <= RAM(i);
				end loop;
            --concatenar
--            if addr1 = 0 then
--               RAM(0) <= '1' & conv_std_logic_vector(0, 30);
--            elsif addr1 = 31 then
--               RAM(0) <= conv_std_logic_vector(0, 30) & '1';
--            else
--               RAM(0) <= conv_std_logic_vector(0, conv_integer(addr1)) & '1' & conv_std_logic_vector(0, conv_integer(30 - addr1));
--            end if;
            RAM(0) <= conv_std_logic_vector(0, 27) & addr1;
		end if;
    end process escritura;

    lectura : process (clk)
    begin
		--lectura asíncrona
		do <= RAM(conv_integer(addr2))(4 downto 0);
    end process lectura;
end circuito;


