---------------------------------------------------------------------------------
-- Company: Equipo 1
-- Engineer:
-- 
-- Design Name: Animación de barras (pantalla)
-- Module Name: vga_barras
-- Project Name: Proyecto de TOC
-- Target Devices: Xilinx Spartan 3
-- Tool versions: Xilinx ISE 14.1
--
-- Dependencies:
--
-- Description:
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

use work.tipos.all;

entity vga_barras is
   generic(N : integer := 150);
	port(
      clk: in std_logic;
		hcnt: in std_logic_vector(8 downto 0);
		vcnt: in std_logic_vector(9 downto 0);
      nota	: in TNota;
		sharp	: in std_logic;
		octave : in std_logic_vector(2 downto 0);
		pintar: out std_logic;
      currentobject: out vga_object -- el tipo vga_obejct esta definido en tipos.vhd
	);
end vga_barras;

architecture Behavioral of vga_barras is

type despl_type is array (N - 1 downto 0) of std_logic_vector(31 downto 0);
signal despl : despl_type := ((others => (others => '0')));

signal entrada, d_out : std_logic_vector(31 downto 0);
signal entrada_aux : std_logic_vector(11 downto 0);
signal addr_aux : std_logic_vector(8 downto 0);
signal addr : std_logic_vector(7 downto 0);

begin

currentobject <= notaMov;

pintar_barras: process(hcnt, vcnt, d_out)
   begin
         pintar <= '0';
			for i in 0 to 2 loop
				if hcnt > 5 + 91*i and hcnt < 14 + 91*i and d_out(31 - 12*i) = '1' then pintar <= '1';
				elsif hcnt > 13 + 91*i and hcnt < 20 + 91*i and d_out(30 - 12*i) = '1' then pintar <= '1';
				elsif hcnt > 20 + 91*i and hcnt < 28 + 91*i and d_out(29 - 12*i) = '1' then pintar <= '1';
				elsif hcnt > 28 + 91*i and hcnt < 35 + 91*i and d_out(28 - 12*i) = '1' then pintar <= '1';
				elsif hcnt > 35 + 91*i and hcnt < 44 + 91*i and d_out(27 - 12*i) = '1' then pintar <= '1';
				elsif hcnt > 44 + 91*i and hcnt < 52 + 91*i and d_out(26 - 12*i) = '1' then pintar <= '1';
				elsif hcnt > 52 + 91*i and hcnt < 59 + 91*i and d_out(25 - 12*i) = '1' then pintar <= '1';
				elsif hcnt > 59 + 91*i and hcnt < 66 + 91*i and d_out(24 - 12*i) = '1' then pintar <= '1';
				end if;
			end loop;
			for i in 0 to 1 loop
				if hcnt > 66 + 91*i and hcnt < 73 + 91*i and d_out(23 - 12*i) = '1' then pintar <= '1';
				elsif hcnt > 73 + 91*i and hcnt < 80 + 91*i and d_out(22 - 12*i) = '1' then pintar <= '1';
				elsif hcnt > 80 + 91*i and hcnt < 87 + 91*i and d_out(21 - 12*i) = '1' then pintar <= '1';
				elsif hcnt > 87 + 91*i and hcnt < 96 + 91*i and d_out(20 - 12*i) = '1' then pintar <= '1';
				end if;
			end loop;
   end process pintar_barras;

entrada_aux <= "100000000000" when nota = do and sharp = '0' else
					"010000000000" when nota = do and sharp = '1' else
					"001000000000" when nota = re and sharp = '0' else
					"000100000000" when nota = re and sharp = '1' else
					"000010000000" when nota = mi and sharp = '0' else
					"000001000000" when nota = fa and sharp = '0' else
					"000000100000" when nota = fa and sharp = '1' else
					"000000010000" when nota = sol and sharp = '0' else
					"000000001000" when nota = sol and sharp = '1' else
					"000000000100" when nota = la and sharp = '0' else
					"000000000010" when nota = la and sharp = '1' else
					"000000000001" when nota = si and sharp = '0' else
					"000000000000";
entrada_despl : process(entrada_aux, octave)
begin
   if octave = "000" then
      entrada <= 	entrada_aux & conv_std_logic_vector(0,20);
   elsif octave = "001" then
      entrada <= conv_std_logic_vector(0,12) & entrada_aux & conv_std_logic_vector(0,8);
   else
      entrada <= conv_std_logic_vector(0,24) & entrada_aux(11 downto 4);
   end if;
end process;
				
addr_aux <= "101110010" - vcnt(8 downto 0);
addr <= addr_aux(8 downto 1);

escritura : process (clk, despl)
    begin
		-- escritura sincrona
      if rising_edge(clk) then
				for i in 0 to N - 2 loop
					despl(i+1) <= despl(i);
				end loop;
            despl(0) <= entrada;
		end if;
    end process escritura;

lectura : process (clk, despl)
    begin
		--lectura asíncrona
		d_out <= despl(conv_integer(addr))(31 downto 0);
    end process lectura;

end Behavioral;

