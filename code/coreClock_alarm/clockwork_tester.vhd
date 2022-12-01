library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clockwork_tester is
	port(
		signal Reset	: out std_logic;
		signal Clk_50	: out std_logic;
		signal Clk_sec : in std_logic;
		signal square_wav : in std_logic;
		
		signal D_sec_units	: out std_logic_vector(3 downto 0);
		signal D_sec_tens		: out std_logic_vector(3 downto 0);
		signal D_min_units	: out std_logic_vector(3 downto 0);
		signal D_min_tens		: out std_logic_vector(3 downto 0);
		signal D_hour_units	: out std_logic_vector(3 downto 0);
		signal D_hour_tens	: out std_logic_vector(3 downto 0);
		
		signal En : out std_logic;
		signal Clear : out std_logic;
		
		signal Q_sec_units	: in std_logic_vector(3 downto 0);
		signal Q_sec_tens		: in std_logic_vector(3 downto 0);
		signal Q_min_units	: in std_logic_vector(3 downto 0);
		signal Q_min_tens		: in std_logic_vector(3 downto 0);
		signal Q_hour_units	: in std_logic_vector(3 downto 0);
		signal Q_hour_tens	: in std_logic_vector(3 downto 0);
		
		signal Load_sec : out std_logic;
		signal Load_min : out std_logic;
		signal Load_hour: out std_logic;
		
		signal LED_out : in std_logic;
		
		signal En_alarm_in			: out std_logic;	-- Aktivierung des Alarms
		signal En_alarm_out			: in std_logic;	-- Ausgangssignal des Alarms
		signal D_alarm_sec_units	: out std_logic_vector (3 downto 0);	-- Alarm Data IN Sekunden	Einer
		signal D_alarm_sec_tens		: out std_logic_vector (3 downto 0);	-- Alarm Data IN Sekunden	Zehner
		signal D_alarm_min_units	: out std_logic_vector (3 downto 0);	-- Alarm Data IN Minuten	Einer
		signal D_alarm_min_tens		: out std_logic_vector (3 downto 0);	-- Alarm Data IN Minuten	Zehner
		signal D_alarm_hour_units	: out std_logic_vector (3 downto 0);	-- Alarm Data IN Stunden	Einer
		signal D_alarm_hour_tens	: out std_logic_vector (3 downto 0)	-- Alarm Data IN Stunden	Zehner
	);
end entity clockwork_tester;

architecture sim of clockwork_tester is
	signal Clk_int : std_logic := '0';
begin
	Clk_int	<= not Clk_int after 20 ns;
	Clk_50	<= Clk_int;

	D_sec_units		<= x"5";
	D_sec_tens		<= x"5";
	D_min_units		<= x"5";
	D_min_tens		<= x"5";
	D_hour_units	<= x"5";
	D_hour_tens		<= x"1";

	Load_sec			<= '1', '0' after 100 ns;
	Load_min			<= '1', '0' after 100 ns;
	Load_hour		<= '1', '0' after 100 ns;
	En					<= '0', '1' after 40 ns;

	Reset <= '0', '1' after 200 ns, '0' after 300 ns;
	Clear <= '0', '1' after 7 ms;
	
	D_alarm_sec_units		<= x"0", x"9" after 4 ms;
	D_alarm_sec_tens		<= x"0", x"5" after 4 ms;
	D_alarm_min_units		<= x"0", x"1" after 4 ms;
	D_alarm_min_tens		<= x"0", x"3" after 4 ms;
	D_alarm_hour_units	<= x"2", x"0" after 4 ms;
	D_alarm_hour_tens		<= x"1", x"2" after 4 ms;
	En_alarm_in				<= '1', '0' after 4.5 ms;
	
end architecture sim;