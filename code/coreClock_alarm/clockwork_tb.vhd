--! @file	Clockwork_tb.vhd
--! @brief	Uhrwerk TB, TestBench File
--! @author	Sebastian Schmaus

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Clockwork_tb is
end entity Clockwork_tb;

architecture sim of Clockwork_tb is
	signal Reset_tb, Clk_50_tb, Clk_sec_tb, square_wav_tb, Clear_tb, LED_out_tb, En_alarm_in_tb, En_alarm_out_tb, Show_nSet_tb, Set_Clock_nAlarm_tb, Set_Hour_nMin_tb, A_enc_tb, B_enc_tb	: std_logic;
	signal Q_sec_units_tb, Q_sec_tens_tb, Q_min_units_tb, Q_min_tens_tb, Q_hour_units_tb, Q_hour_tens_tb, Q_al_min_units_tb, Q_al_min_tens_tb, Q_al_hour_units_tb, Q_al_hour_tens_tb			: std_logic_vector(3 downto 0);
begin

	dut : entity work.Clockwork(behave)
		generic map(
			Max50 => 10,		-- kleinere Maximalwerte für verkürzte Simulationsdauer
			Max25 => 5
		)
		port map(
			Reset					=> Reset_tb,
			Clk_50				=> Clk_50_tb,
			Clk_sec				=> Clk_sec_tb,
			square_wav			=> square_wav_tb,
			Clear					=> Clear_tb,
			Q_sec_units			=> Q_sec_units_tb,
			Q_sec_tens			=> Q_sec_tens_tb,
			Q_min_units			=> Q_min_units_tb,
			Q_min_tens			=> Q_min_tens_tb,
			Q_hour_units		=> Q_hour_units_tb,
			Q_hour_tens			=> Q_hour_tens_tb,
			Q_al_min_units		=> Q_al_min_units_tb,
			Q_al_min_tens		=> Q_al_min_tens_tb,
			Q_al_hour_units	=> Q_al_hour_units_tb,
			Q_al_hour_tens		=> Q_al_hour_tens_tb,
			LED_out				=> LED_out_tb,
			En_alarm_in			=> En_alarm_in_tb,
			En_alarm_out		=> En_alarm_out_tb,
			Show_nSet			=> Show_nSet_tb,
			Set_Clock_nAlarm	=> Set_Clock_nAlarm_tb,
			Set_Hour_nMin		=> Set_Hour_nMin_tb,
			A_enc					=> A_enc_tb,
			B_enc					=> B_enc_tb
		);
		
	tester : entity work.Clockwork_tester(sim)
		port map(
			Reset					=> Reset_tb,
			Clk_50				=> Clk_50_tb,
			Clk_sec				=> Clk_sec_tb,
			square_wav			=> square_wav_tb,
			Clear					=> Clear_tb,
			Q_sec_units			=> Q_sec_units_tb,
			Q_sec_tens			=> Q_sec_tens_tb,
			Q_min_units			=> Q_min_units_tb,
			Q_min_tens			=> Q_min_tens_tb,
			Q_hour_units		=> Q_hour_units_tb,
			Q_hour_tens			=> Q_hour_tens_tb,
			Q_al_min_units		=> Q_al_min_units_tb,
			Q_al_min_tens		=> Q_al_min_tens_tb,
			Q_al_hour_units	=> Q_al_hour_units_tb,
			Q_al_hour_tens		=> Q_al_hour_tens_tb,
			LED_out				=> LED_out_tb,
			En_alarm_in			=> En_alarm_in_tb,
			En_alarm_out		=> En_alarm_out_tb,
			Show_nSet			=> Show_nSet_tb,
			Set_Clock_nAlarm	=> Set_Clock_nAlarm_tb,
			Set_Hour_nMin		=> Set_Hour_nMin_tb,
			A_enc					=> A_enc_tb,
			B_enc					=> B_enc_tb
		);

end architecture sim;