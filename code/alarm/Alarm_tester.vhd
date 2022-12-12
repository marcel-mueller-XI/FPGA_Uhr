------------------------------------------------------
-- Aufgabe 7: 	Uhr										 	 --
-- Datei:	   Alarm_tester.vhd					 		 --
-- Autor:   	Jonas Sachwitz & Marco Stütz      	 --
-- Datum:   	29.11.2022                        	 --
------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY Alarm_tester IS
	PORT(
	
		Uhr_h_10er		: 	OUT		std_logic_vector (3 DOWNTO 0);
		Uhr_h_1er		: 	OUT		std_logic_vector (3 DOWNTO 0);
		Uhr_m_10er		: 	OUT		std_logic_vector (3 DOWNTO 0);
		Uhr_m_1er		: 	OUT		std_logic_vector (3 DOWNTO 0);
		Alarm_h_10er	: 	OUT		std_logic_vector (3 DOWNTO 0);
		Alarm_h_1er		: 	OUT		std_logic_vector (3 DOWNTO 0);
		Alarm_m_10er	: 	OUT		std_logic_vector (3 DOWNTO 0);
		Alarm_m_1er		: 	OUT		std_logic_vector (3 DOWNTO 0);
		Clk				: 	OUT		std_logic; -- 50 MHz
		Aktiv				:	OUT		std_logic; -- 
		Reset         : out     std_logic;  --! Asynchronous Reset
		
		Alarm_out		: 	IN   std_logic;
		Sound				:	IN	std_logic;
		Timer          :  IN integer
  );
END Alarm_tester;


ARCHITECTURE sim OF Alarm_tester IS
	signal clki : std_logic := '0';
BEGIN
	clki <= not clki after 10 ns;
	Clk <= Clki;
				
	tester: process
	begin
		Reset <= '1';
		wait for 1 ms;
		Reset <= '0';
		Uhr_h_10er 	<= "1010";
		Uhr_h_1er 	<= "0000";
		Uhr_m_10er 	<= "0001";
		Uhr_m_1er 	<= "0000";
		Alarm_h_10er 	<= "1010";
		Alarm_h_1er 	<= "0000";
		Alarm_m_10er 	<= "0001";
		Alarm_m_1er 	<= "0101";
		Aktiv <= '1';
		wait for 5 ms;
		Uhr_m_1er 	<= "0100";
		wait for 1 ms;
		Uhr_m_1er 	<= "0101";	--> Alarm
		wait for 20000 ms;
		Aktiv <= '0';
	end process tester;
	


END sim;