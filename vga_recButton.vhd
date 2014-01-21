library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

use work.tipos.all;

entity vga_recButton is
	port
	(
		hcnt: in std_logic_vector(8 downto 0);
		vcnt: in std_logic_vector(9 downto 0);
		hcnt_aux: in std_logic_vector(8 downto 0);
		vcnt_aux: in std_logic_vector(9 downto 0);
		pintar: out std_logic;
      currentobject: out vga_object -- el tipo vga_obejct esta definido en tipos.vhd
	);
end vga_recButton;

architecture Behavioral of vga_recButton is

type bola_type is array (25 downto 0) of std_logic_vector(12 downto 0);

signal bola : bola_type :=
("0001111111000"
,"0001111111000"
,"0011111111100"
,"0011111111100"
,"0111111111110"
,"0111111111110"
,"1111111111111"
,"1111111111111"
,"1111111111111"
,"1111111111111"
,"1111111111111"
,"1111111111111"
,"1111111111111"
,"1111111111111"
,"1111111111111"
,"1111111111111"
,"1111111111111"
,"1111111111111"
,"1111111111111"
,"1111111111111"
,"0111111111110"
,"0111111111110"
,"0011111111100"
,"0011111111100"
,"0001111111000"
,"0001111111000");

begin

currentobject <= teclaPulsada;

pintar_rec: process(hcnt, vcnt)
begin
	if hcnt - hcnt_aux > 12 or vcnt - vcnt_aux > 25 then
		pintar <= '0';
	else pintar <= bola(conv_integer(vcnt - vcnt_aux))(conv_integer(hcnt - hcnt_aux));
	end if;

end process;


end Behavioral;

