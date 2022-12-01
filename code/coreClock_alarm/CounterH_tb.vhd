library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CounterH_tb is
end entity CounterH_tb;

architecture sim of CounterH_tb is
	signal Reset_tb, Clk_tb, Clear_tb, Load_tb, En_tb, Up_nDown_tb, Cas_tb : std_logic;
	signal D0_tb, D1_tb, Q0_tb, Q1_tb : std_logic_vector(3 downto 0);
begin
	
	dut : entity work.CounterH(behave)
		generic map(
			TCO => 10 ns,
			TD => 7 ns
		)
		port map(
			Reset		=> Reset_tb,
			Clk		=> Clk_tb,
			Clear		=> Clear_tb,
			Load		=> Load_tb,
			En			=> En_tb,
			Up_nDown	=> Up_nDown_tb,
			D0			=> D0_tb,
			Q0			=> Q0_tb,
			Cas		=> Cas_tb,
			D1			=> D1_tb,
			Q1			=> Q1_tb
		);
	
	tester : entity work.CounterH_tester(sim)
		port map(
			Reset		=> Reset_tb,
			Clk		=> Clk_tb,
			Clear		=> Clear_tb,
			Load		=> Load_tb,
			En			=> En_tb,
			Up_nDown	=> Up_nDown_tb,
			D0			=> D0_tb,
			Q0			=> Q0_tb,
			Cas		=> Cas_tb,
			D1			=> D1_tb,
			Q1			=> Q1_tb
		);

end architecture sim;