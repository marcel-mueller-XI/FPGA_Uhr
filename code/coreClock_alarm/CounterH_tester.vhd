library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CounterH_tester is
	port(
		Reset 	: out std_logic; -- Asynchroner Reset
		Clk 		: out std_logic; -- Takt, rising edge
		Clear 	: out std_logic; -- Q auf 0
		Load 		: out std_logic; -- Übernehmen der Daten an D in den Zähler Q
		En 		: out std_logic; -- Zählfreigabe
		Up_nDown : out std_logic; -- Zählrichtung
		
		D0 		: out std_logic_vector(3 downto 0); 	-- Dateneingang
		D1			: out std_logic_vector(3 downto 0);
		Q0 		: in std_logic_vector(3 downto 0);		-- Zähler Datenausgang
		Q1			: in std_logic_vector(3 downto 0);
		Cas 		: in std_logic		-- Kaskadierungsausgang	
	);
end entity CounterH_tester;

architecture sim of CounterH_tester is
	signal Clk_int : std_logic := '0';
begin
	Clk_int	<= not Clk_int after 10 ns;
	Clk 		<= Clk_int;
	
	Reset		<= '1', '0' after 200 ns;
	Clear		<= '0';
	Load		<= '0';
	En			<= '1';
	Up_nDown	<= '1';
	
	D0 		<= (others => '0');
	D1 		<= (others => '0');
end architecture sim;