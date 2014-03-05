---------------------------------------------------------------------------------
-- Company: Equipo 1
-- Engineer:
-- 
-- Design Name: Tabla de semiperiodos de nota en la séptima octava
-- Module Name: tablanotas
-- Project Name: Proyecto de TOC
-- Target Devices: Xilinx Spartan 3
-- Tool versions: Xilinx ISE 14.1
--
-- Dependencies:
--
-- Description: (para multiplicar en lugar de dividir) (de los apuntes de J.M.
--		Mendías)
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.ALL;

-- Tipos locales
use work.tipos.all;

entity tablanotas is 
	port (
		nota		: in TNota;
		semiper	: out std_logic_vector(11 downto 0)
	);
end entity tablanotas;

architecture rom_tablanotas of tablanotas is
	-- Señal de tipo entero escribir menos
	signal tmp : Integer range 0 to 2986;
begin

	-- Asigna el semiperiodo en función de la nota
	with nota select
		tmp	<=	2986	when do,
					2660	when re,
					2370	when mi,
					2237	when fa,
					1993	when sol,
					1776	when la,
					1582	when si,
					0	when others;
					
	semiper <= conv_std_logic_vector(tmp, 12);
end architecture rom_tablanotas;
