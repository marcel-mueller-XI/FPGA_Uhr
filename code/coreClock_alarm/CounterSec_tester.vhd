library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CounterSec_tester is
	port(
		signal Reset	: out std_logic;
		signal Clk_50	: out std_logic;
		signal Clk_sec : in std_logic;
		signal square_wav : in std_logic
	);
end entity CounterSec_tester;

architecture sim of CounterSec_tester is
	signal Clk_int : std_logic := '0';
begin
	Clk_int	<= not Clk_int after 10 ns;
	Clk_50	<= Clk_int;
	
	Reset <= '1', '0' after 2000 ms;
end architecture sim;