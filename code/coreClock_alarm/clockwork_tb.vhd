library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clockwork_tb is
end entity clockwork_tb;

architecture sim of clockwork_tb is
	signal Reset_tb, Clk_50_tb, Clk_sec_tb, square_wav_tb, En_tb, Clear_tb, Load_sec_tb, Load_min_tb, Load_hour_tb, LED_out_tb, En_alarm_in_tb, En_alarm_out_tb : std_logic;
	signal D_sec_units_tb, D_sec_tens_tb, D_min_units_tb, D_min_tens_tb, D_hour_units_tb, D_hour_tens_tb, Q_sec_units_tb, Q_sec_tens_tb, Q_min_units_tb, Q_min_tens_tb, Q_hour_units_tb, Q_hour_tens_tb, D_alarm_sec_units_tb, D_alarm_sec_tens_tb, D_alarm_min_units_tb, D_alarm_min_tens_tb, D_alarm_hour_units_tb, D_alarm_hour_tens_tb : std_logic_vector(3 downto 0);
begin

	dut : entity work.clockwork(behave)
		generic map(
			Max50 => 2,
			Max25 => 1
		)
		port map(
			Reset				=> Reset_tb,
			Clk_50			=> Clk_50_tb,
			Clk_sec			=> Clk_sec_tb,
			square_wav		=> square_wav_tb,
			D_sec_units		=> D_sec_units_tb,
			D_sec_tens		=> D_sec_tens_tb,
			D_min_units		=> D_min_units_tb,
			D_min_tens		=> D_min_tens_tb,
			D_hour_units	=> D_hour_units_tb,
			D_hour_tens		=> D_hour_tens_tb,
			En					=> En_tb,
			Clear				=> Clear_tb,
			Q_sec_units		=> Q_sec_units_tb,
			Q_sec_tens		=> Q_sec_tens_tb,
			Q_min_units		=> Q_min_units_tb,
			Q_min_tens		=> Q_min_tens_tb,
			Q_hour_units	=> Q_hour_units_tb,
			Q_hour_tens		=> Q_hour_tens_tb,
			Load_sec			=> Load_sec_tb,
			Load_min			=> Load_min_tb,
			Load_hour		=> Load_hour_tb,
			LED_out			=> LED_out_tb,
			En_alarm_in				=> En_alarm_in_tb,
			En_alarm_out			=> En_alarm_out_tb,
			D_alarm_sec_units		=> D_alarm_sec_units_tb,
			D_alarm_sec_tens		=> D_alarm_sec_tens_tb,
			D_alarm_min_units		=> D_alarm_min_units_tb,
			D_alarm_min_tens		=> D_alarm_min_tens_tb,
			D_alarm_hour_units	=> D_alarm_hour_units_tb,
			D_alarm_hour_tens		=> D_alarm_hour_tens_tb
		);
	
	tester : entity work.clockwork_tester(sim)
		port map(
			Reset				=> Reset_tb,
			Clk_50			=> Clk_50_tb,
			Clk_sec			=> Clk_sec_tb,
			square_wav		=> square_wav_tb,
			D_sec_units		=> D_sec_units_tb,
			D_sec_tens		=> D_sec_tens_tb,
			D_min_units		=> D_min_units_tb,
			D_min_tens		=> D_min_tens_tb,
			D_hour_units	=> D_hour_units_tb,
			D_hour_tens		=> D_hour_tens_tb,
			En					=> En_tb,
			Clear				=> Clear_tb,
			Q_sec_units		=> Q_sec_units_tb,
			Q_sec_tens		=> Q_sec_tens_tb,
			Q_min_units		=> Q_min_units_tb,
			Q_min_tens		=> Q_min_tens_tb,
			Q_hour_units	=> Q_hour_units_tb,
			Q_hour_tens		=> Q_hour_tens_tb,
			Load_sec			=> Load_sec_tb,
			Load_min			=> Load_min_tb,
			Load_hour		=> Load_hour_tb,
			LED_out			=> LED_out_tb,
			En_alarm_in				=> En_alarm_in_tb,
			En_alarm_out			=> En_alarm_out_tb,
			D_alarm_sec_units		=> D_alarm_sec_units_tb,
			D_alarm_sec_tens		=> D_alarm_sec_tens_tb,
			D_alarm_min_units		=> D_alarm_min_units_tb,
			D_alarm_min_tens		=> D_alarm_min_tens_tb,
			D_alarm_hour_units	=> D_alarm_hour_units_tb,
			D_alarm_hour_tens		=> D_alarm_hour_tens_tb
		);

end architecture sim;