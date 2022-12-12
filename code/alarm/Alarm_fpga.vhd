------------------------------------------------------
-- Aufgabe 7: 	Uhr										 	 --
-- Datei:	   Alarm_fpga.vhd					 			 --
-- Autor:   	Jonas Sachwitz & Marco Stütz      	 --
-- Datum:   	05.12.2022                        	 --
------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
--USE ieee.numeric_std.all;   -- unsigned / signed

ENTITY Alarm_fpga IS
	PORT(
		Aktiv : IN std_logic;
		Clk   : IN std_logic;
		Piezo: OUT std_logic;
		Alarm_out_LED : OUT std_logic
	);
END ENTITY Alarm_fpga;

architecture behave of Alarm_fpga is
	signal Aktivi        : std_logic;	
	signal Uhr_h_10er		: 	std_logic_vector (3 DOWNTO 0) := "1010";
	signal Uhr_h_1er		: 	std_logic_vector (3 DOWNTO 0) := "0000";
	signal Uhr_m_10er		: 	std_logic_vector (3 DOWNTO 0) := "0001";
	signal Uhr_m_1er		: 	std_logic_vector (3 DOWNTO 0) := "0101";
	signal Alarm_h_10er	: 	std_logic_vector (3 DOWNTO 0) := "1010";
	signal Alarm_h_1er	: 	std_logic_vector (3 DOWNTO 0) := "0000";
	signal Alarm_m_10er	: 	std_logic_vector (3 DOWNTO 0) := "0001";
	signal Alarm_m_1er	: 	std_logic_vector (3 DOWNTO 0) := "0101";
BEGIN
	-- handle signals with real in-/output
	Aktivi <= not Aktiv;
	
	i0 : ENTITY work.Alarm
	port map(
		-- Input
		Uhr_h_10er    => Uhr_h_10er,
		Uhr_h_1er     => Uhr_h_1er,
		Uhr_m_10er    => Uhr_m_10er,
		Uhr_m_1er     => Uhr_m_1er,
		Alarm_h_10er  => Alarm_h_10er,
		Alarm_h_1er	  => Alarm_h_1er,
		Alarm_m_10er  => Alarm_m_10er,
		Alarm_m_1er	  => Alarm_m_1er,
		Clk           => Clk,
		Aktiv         => Aktivi,
		
		--Output
		Alarm_out => Alarm_out_LED,
		Sound => Piezo
	);
	
end architecture behave;
	
	