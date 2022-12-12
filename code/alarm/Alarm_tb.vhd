------------------------------------------------------
-- Aufgabe 7: 	Uhr										 	 --
-- Datei:	   Alarm_tester.vhd					 		 --
-- Autor:   	Jonas Sachwitz & Marco Stütz      	 --
-- Datum:   	29.11.2022                        	 --
------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY Alarm_tb IS

END Alarm_tb;


ARCHITECTURE sim OF Alarm_tb IS
	Signal 	Uhr_h_10er_int		: 	std_logic_vector (3 DOWNTO 0);
	Signal	Uhr_h_1er_int		: 	std_logic_vector (3 DOWNTO 0);
	Signal	Uhr_m_10er_int		: 	std_logic_vector (3 DOWNTO 0);
	Signal	Uhr_m_1er_int		: 	std_logic_vector (3 DOWNTO 0);
	Signal	Alarm_h_10er_int	: 	std_logic_vector (3 DOWNTO 0);
	Signal	Alarm_h_1er_int		: 	std_logic_vector (3 DOWNTO 0);
	Signal	Alarm_m_10er_int	: 	std_logic_vector (3 DOWNTO 0);
	Signal	Alarm_m_1er_int	: 	std_logic_vector (3 DOWNTO 0);
	Signal	Clk_int				: 	std_logic; -- 50 MHz
	Signal	Aktiv_int				:	std_logic; -- 
		
	Signal	Alarm_out_int		: 	std_logic;
	Signal	Sound_int		   :	std_logic;
	Signal   Reset_int         :  std_logic;
	Signal   Timer_int         :  integer;
BEGIN
	dut : entity work.Alarm
	-- wiring
	port map(
		Uhr_h_10er => Uhr_h_10er_int,
		Uhr_h_1er  => Uhr_h_1er_int,
		Uhr_m_10er  => Uhr_m_10er_int,
		Uhr_m_1er  => Uhr_m_1er_int,
		Alarm_h_10er  => Alarm_h_10er_int,
		Alarm_h_1er	 => Alarm_h_1er_int,
		Alarm_m_10er  => Alarm_m_10er_int,
		Alarm_m_1er	 => Alarm_m_1er_int,
		Clk  => Clk_int,
		Aktiv => Aktiv_int,
		--Reset => Reset_int,
		
		Alarm_out => Alarm_out_int,
		Sound => Sound_int,
		Timer => Timer_int
	);
	
	-- instance tester
	tester : entity work.Alarm_tester(sim)
	-- wiring
	port map(
		Uhr_h_10er => Uhr_h_10er_int,
		Uhr_h_1er  => Uhr_h_1er_int,
		Uhr_m_10er  => Uhr_m_10er_int,
		Uhr_m_1er  => Uhr_m_1er_int,
		Alarm_h_10er  => Alarm_h_10er_int,
		Alarm_h_1er	 => Alarm_h_1er_int,
		Alarm_m_10er  => Alarm_m_10er_int,
		Alarm_m_1er	 => Alarm_m_1er_int,
		Clk  => Clk_int,
		Aktiv => Aktiv_int,
		Reset => Reset_int,
		
		Alarm_out => Alarm_out_int,
		Sound => Sound_int,
		Timer => Timer_int
	);


END sim;