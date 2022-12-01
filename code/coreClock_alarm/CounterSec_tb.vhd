library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CounterSec_tb is
end entity CounterSec_tb;

architecture sim of CounterSec_tb is
	signal Reset_tb, Clk_50_tb, Clk_sec_tb, square_wav_tb : std_logic;
begin

	dut : entity work.CounterSec(behave)
		generic map(
			Max50 => 50,	-- 50_000_000 für Impulse jede Sekunde
			Max25 => 25		-- 25_000_000 für Rechtecksignal mit Periode = 1 Sekunde
		)
		port map(
			Reset			=> Reset_tb,
			Clk_50		=> Clk_50_tb,
			Clk_sec		=> Clk_sec_tb,
			square_wav	=> square_wav_tb
		);
	
	tester : entity work.CounterSec_tester(sim)
		port map(
			Reset			=> Reset_tb,
			Clk_50		=> Clk_50_tb,
			Clk_sec		=> Clk_sec_tb,
			square_wav	=> square_wav_tb
		);
end architecture sim;