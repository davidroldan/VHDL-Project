---------------------------------------------------------------------------------
-- Company: Equipo 1
-- Engineer:
-- 
-- Design Name: Emisor de la UART
-- Module Name: uart_tx
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
use ieee.numeric_std.all;

entity uart_tx is
	generic(
		-- N�mero de bits de datos
		DBIT : integer := 8 ; 
		-- Duraci�n del bit de stop
		-- (ha de ser mayor o igual que 16)	
		SB_TICK: integer := 16 );
		
	port (
		-- Reloj principal y reset.
		reloj, reset: in std_logic;
		-- Bit de datos
		tx_start : in std_logic;
	
		rbaud	: in std_logic ;
		-- Entrada de datos enviado en paralelo
		din : in std_logic_vector ( 7 downto 0) ;
		tx_done_tick : out std_logic;
		tx : out std_logic
	);
end uart_tx;

architecture arch of uart_tx is
	type state_type is (idle, start, data, stop);
	signal state_reg, state_next : state_type;
	signal s_reg , s_next : unsigned (3 downto 0) ;
	signal n_reg , n_next : unsigned (2 downto 0) ;
	signal b_reg , b_next : std_logic_vector (7 downto 0 ) ;
	signal tx_reg , tx_next : std_logic ;
	signal s_tick, rbaud_ant : std_logic;
	
	signal tx_done_tick_reg, tx_done_tick_next : std_logic;
	
begin
process (reloj, reset)
begin
	if reset= '1' then
		state_reg <= idle;
		s_reg <= (others => '0') ;
		n_reg <= (others => '0') ;
		b_reg <= (others => '0') ;
		tx_reg <= '1';
		tx_done_tick_reg <= '0';
		rbaud_ant <= '0';

	elsif (reloj'event and reloj = '1') then
		rbaud_ant <= rbaud;
		state_reg <= state_next;
		s_reg <= s_next;
		n_reg <= n_next;
		b_reg <= b_next;
		tx_reg <= tx_next;
		tx_done_tick_reg <= tx_done_tick_next;
	end if;
end process;



process (state_reg , s_reg ,n_reg ,b_reg, s_tick, tx_reg, tx_start,din)
begin
	state_next <= state_reg;
	s_next <= s_reg;
	n_next <= n_reg;
	b_next <= b_reg;
	tx_next <= tx_reg ;
	
	case state_reg is
		when idle =>
		tx_next <= '1';
		if tx_start = '1' then
			state_next <= start;
			s_next <= ( others => '0') ;
			b_next <= din ;
		end if ;
		
		when start =>
		tx_next <= '0';
		if s_tick = '1' then
			if s_reg = 15 then
				state_next <= data;
				s_next <= (others => '0') ;
				n_next <= (others => '0' ) ;

			else
				s_next <= s_reg + 1 ;
			end if ;
		end if ;
		
		when data =>	
		tx_next <= b_reg(0) ;
		if s_ticK = '1' then
			if s_reg = 15 then
				s_next <= (others => '0' ) ;
				b_next <= '0' & b_reg (7 downto 1) ;
				if n_reg = DBIT - 1 then
					state_next <= stop;
				else
					n_next <= n_reg + 1;
				end if ;
			else
				s_next <= s_reg + 1;
			end if ;
		end if ;
	
		when stop =>
		tx_next <= '1' ;
		if s_tick = '1' then
			if s_reg = (SB_TICK - 1) then
				state_next <= idle;
			else
				s_next <= s_reg + 1;

			end if ;
		end if ;

end case;
end process;

tx_done_tick <= tx_done_tick_reg;

tx_done_tick_next <= '1' when state_reg = stop and s_reg = (SB_TICK - 1) and s_tick = '1' else
							'0';

tx <= tx_reg;
s_tick <= 	'1' when rbaud /= rbaud_ant and rbaud = '1' else
				'0';

end arch;
