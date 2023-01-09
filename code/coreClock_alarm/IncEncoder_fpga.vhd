library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity IncEncoder_fpga is
	port(
		signal A			 	: in std_logic;	-- Eingangssignal A
		signal B			 	: in std_logic;	-- Eingangssignal B
		signal Clk		 	: in std_logic;	-- Clk Eingang
		signal Reset	 	: in std_logic;	-- Reset Encoder
		signal Min_Hour 	: in std_logic; 	-- Minutenzählung = 0/ Stundenzählung = 1
		signal En		 	: in std_logic;	-- Enable Encoder
		signal Clk_Alarm  : in std_logic;	-- bei 1 Clk aktiv, bei 0 Alarm aktiv
		
		signal D_Clk_min_units 	: in std_logic_vector(3 downto 0);		-- Uhr Startwert Dateneingang
		signal D_Clk_min_tens 	: in std_logic_vector(3 downto 0);
		signal D_Clk_hour_units : in std_logic_vector(3 downto 0);
		signal D_Clk_hour_tens 	: in std_logic_vector(3 downto 0);
		
		signal Q_Clk_min_units 	: buffer std_logic_vector(3 downto 0);		-- Uhr Encoder Datenausgang
		signal Q_Clk_min_tens 	: buffer std_logic_vector(3 downto 0);
		signal Q_Clk_hour_units : buffer std_logic_vector(3 downto 0);
		signal Q_Clk_hour_tens 	: buffer std_logic_vector(3 downto 0);

		
		signal D_Alarm_min_units 	: in std_logic_vector(3 downto 0);	-- Alarm Startwert Dateneingang
		signal D_Alarm_min_tens 	: in std_logic_vector(3 downto 0);
		signal D_Alarm_hour_units 	: in std_logic_vector(3 downto 0);
		signal D_Alarm_hour_tens 	: in std_logic_vector(3 downto 0);
		
		signal Q_Alarm_min_units 	: buffer std_logic_vector(3 downto 0);	-- Alarm Encoder Datenausgang
		signal Q_Alarm_min_tens 	: buffer std_logic_vector(3 downto 0);
		signal Q_Alarm_hour_units 	: buffer std_logic_vector(3 downto 0);
		signal Q_Alarm_hour_tens 	: buffer std_logic_vector(3 downto 0)
		
	);
end entity IncEncoder_fpga;

architecture behave of IncEncoder_fpga is
	signal En_int			: std_logic;	-- Zählfreigabe Encoder
	signal En_Alarm		: std_logic;	-- Alarmzähler aktivieren
	signal En_Clk			: std_logic;	-- Uhrzähler aktivieren
	signal Up_nDown_int	: std_logic;	-- Hoch / runterzählen
	signal Load_Alarm 	: std_logic := '0';   -- Alarm Startwert übernehmen
	signal Load_Clk		: std_logic := '0';		-- Uhr Startwert übernehmen
	
begin
	-- Clk Einstellungen aktiv, wenn Enable Signal des Encoder = 1 und Einstellungen für Clk aktiviert sind
	En_Clk <= '1' when En_int = '1' and Clk_Alarm = '1' else
				 '0';
				 
	-- Alarm Einstellungen aktiv, wenn Enable Signal des Encoder = 1 und Einstellungen für Alarm aktiviert sind
	En_Alarm <= '1' when En_int = '1' and Clk_Alarm = '0' else
				 '0';
				 
	-- Alarm Signal laden, wenn Eingangssignale ungleich Ausgleichsignale sind und En auf 1 ist
	Load_Alarm <= '1' when En = '1' and D_Alarm_min_units /= Q_Alarm_min_units and D_Alarm_min_tens /= Q_Alarm_min_tens and D_Alarm_hour_units /= Q_Alarm_hour_units and D_Alarm_hour_tens /= Q_Alarm_hour_tens else
					  '0';

	 -- Clk Signal laden, wenn Eingangssignale ungleich Ausgleichsignale sind und En auf 1 ist
	Load_Clk <= '1' when En = '1' and D_Clk_min_units /= Q_Clk_min_units and D_Clk_min_tens /= Q_Clk_min_tens and D_Clk_hour_units /= Q_Clk_hour_units and D_Clk_hour_tens /= Q_Clk_hour_tens else
					'0';
 	
	encoder : entity work.IncEncoder_alarm
	port map(
		A 				=> A,
		B 				=> B,
		En_Encoder	=> En,
		Clk 			=> Clk,
		Reset 		=> Reset,
		En 			=> En_int,
		Up_nDown 	=> Up_nDown_int
	);
	
	TimConfig : entity work.InEncoder_Counter
	port map(
		Reset					=> Reset,
		Clk					=> Clk,
		Clear					=> '0',
		Load					=> Load_Clk,
		En						=> En_Clk,
		Up_nDown 			=> Up_nDown_int,
		D_min_units			=> D_Clk_min_units,
		D_min_tens			=> D_Clk_min_tens,
		D_hour_units		=> D_Clk_hour_units,
		D_hour_tens			=> D_Clk_hour_tens,
		Q_min_units			=> Q_Clk_min_units,
		Q_min_tens			=> Q_Clk_min_tens,
		Q_hour_units		=> Q_Clk_hour_units,
		Q_hour_tens			=> Q_Clk_hour_tens,	
		Min_Hour				=> Min_Hour,
		Cas					=> open
	);
	
	AlarmConfig : entity work.InEncoder_Counter
	port map(
		Reset					=> Reset,
		Clk					=> Clk,
		Clear					=> '0',
		Load					=> Load_Alarm,
		En						=> En_Alarm,
		Up_nDown 			=> Up_nDown_int,
		D_min_units			=> D_Alarm_min_units,
		D_min_tens			=> D_Alarm_min_tens,
		D_hour_units		=> D_Alarm_hour_units,
		D_hour_tens			=> D_Alarm_hour_tens,
		Q_min_units			=> Q_Alarm_min_units,
		Q_min_tens			=> Q_Alarm_min_tens,
		Q_hour_units		=> Q_Alarm_hour_units,
		Q_hour_tens			=> Q_Alarm_hour_tens,	
		Min_Hour				=> Min_Hour,
		Cas					=> open
	);
	
end architecture behave;
