--! @file	Clockwork_tester.vhd
--! @brief	Uhrwerk Tester, TestBench File
--! @author	Sebastian Schmaus

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Clockwork_tester is
	port(
		signal Clk_50				: out std_logic;
		
		signal Reset				: out std_logic;
		signal Clear				: out std_logic;
		
		signal Clk_sec				: in std_logic;
		signal square_wav			: in std_logic;
		
		signal Show_nSet			: out std_logic;
		signal Set_Clock_nAlarm	: out std_logic;
		signal Set_Hour_nMin		: out std_logic;
		
		signal En_alarm_in		: out std_logic;
		signal En_alarm_out		: in std_logic;
		
		signal Q_sec_units		: in std_logic_vector(3 downto 0);
		signal Q_sec_tens			: in std_logic_vector(3 downto 0);
		signal Q_min_units		: in std_logic_vector(3 downto 0);
		signal Q_min_tens			: in std_logic_vector(3 downto 0);
		signal Q_hour_units		: in std_logic_vector(3 downto 0);
		signal Q_hour_tens		: in std_logic_vector(3 downto 0);
		
		signal Q_al_min_units	: in std_logic_vector(3 downto 0);
		signal Q_al_min_tens		: in std_logic_vector(3 downto 0);
		signal Q_al_hour_units	: in std_logic_vector(3 downto 0);
		signal Q_al_hour_tens	: in std_logic_vector(3 downto 0);
		
		signal LED_out				: in std_logic;
		
		signal A_enc				: out std_logic;
		signal B_enc				: out std_logic
	);

end entity Clockwork_tester;

architecture sim of Clockwork_tester is
	signal Clk_int	: std_logic := '0';
	signal A_B_Clk : std_logic := '0';
begin
	Clk_int	<= not Clk_int after 10 ns;				-- 50 MHz-Takt
	Clk_50	<= Clk_int;
	
	A_B_Clk	<= not A_B_Clk after 400 ns;				-- Spuren des Inkrementalgebers, A geht B voraus
	A_enc		<= A_B_Clk;
	B_enc		<= A_B_Clk after 200 ns;
	
	Show_nSet			<= '0', '1' after 20000 ns;	-- Einstellmodus -> Uhrzeitmodus
	Set_Clock_nAlarm	<= '1', '0' after 10000 ns;
	Set_Hour_nMin		<= '0', '1' after  5000 ns, '0' after 10000 ns, '1' after 15000 ns;
	
	Reset					<= '1', '0' after 10 ns;							-- Initialer Reset, erfolgt beim Start auf der Hardware automatisch
	Clear					<= '0', '1' after  8 ms, '0' after 8.01 ms;	-- Synchroner Clear bei halber Simulationszeit
	En_alarm_in			<= '0', '1' after 20000 ns;
end architecture sim;