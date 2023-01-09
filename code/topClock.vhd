-- topClock

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity topClock is
port (			--Board an den Rand anschlieÃƒÅ¸en
	-- IN
	Reset				: in std_logic;
	Clk_50			: in std_logic;	-- 50 MHz Eingangssignal
	A					: in std_logic;	-- Eingangssignal A
	B					: in std_logic;	-- Eingangssignal B
	Encoder_Button	: in std_logic;	-- Eingangssignal Encoder_but
	Encoder_Activ	: in std_logic;	-- Enables Encoder with Switch
	En_alarm_in		: in std_logic;	-- Switch that enables Alarm
	Clear_Alarm		: in std_logic;	-- Resets just alarm
	
	-- Out
	LED_out			: out std_logic;
	Alarm_out		: OUT std_logic;
	Sound				: OUT std_logic;
	
	-- Display 
	SegQ_0 	: out std_logic_vector(6 downto 0);
	SegQ_1 	: out std_logic_vector(6 downto 0);
	SegQ_2 	: out std_logic_vector(6 downto 0);
	SegQ_3 	: out std_logic_vector(6 downto 0);
	
	-- Debug
	trigger	: in std_logic
);
end entity topClock;



architecture behave of topClock is
	signal Reset_int				: std_logic;
	signal Clear_Alarm_int		: std_logic;
	signal Encoder_Button_int	: std_logic;
	
	signal Clk_sec 	  	: std_logic;						-- Impulssignal, Impuls jede Sekunde
	signal square_wav 	: std_logic;						-- Rechtecksignal, Periode = 1 Sekunde
	

	signal D_sec_units	: std_logic_vector(3 downto 0);	-- Data IN Sekunden	Einer
	signal D_sec_tens	: std_logic_vector(3 downto 0);	-- Data IN Sekunden	Zehner
	signal D_min_units	: std_logic_vector(3 downto 0);	-- Data IN Minuten	Einer
	signal D_min_tens	: std_logic_vector(3 downto 0);	-- Data IN Minuten	Zehner
	signal D_hour_units	: std_logic_vector(3 downto 0);	-- Data IN Stunden	Einer
	signal D_hour_tens	: std_logic_vector(3 downto 0);	-- Data IN Stunden	Zehner
	
	signal En	 		: std_logic; 							-- Enable fÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¼r Uhr-Start
	signal Clear 		: std_logic;							-- Clear
	
	signal Q_sec_units	: std_logic_vector(3 downto 0);	-- Data OUT Sekunden	Einer
	signal Q_sec_tens	: std_logic_vector(3 downto 0);	-- Data OUT Sekunden	Zehner
	signal Q_min_units	: std_logic_vector(3 downto 0);	-- Data OUT Minuten	Einer
	signal Q_min_tens	: std_logic_vector(3 downto 0);	-- Data OUT Minuten	Zehner
	signal Q_hour_units	: std_logic_vector(3 downto 0);	-- Data OUT Stunden	Einer
	signal Q_hour_tens	: std_logic_vector(3 downto 0);	-- Data OUT Stunden	Zehner
	
	signal Load_sec 	: std_logic;
	signal Load_min 	: std_logic;
	signal Load_hour	: std_logic;
	
	
	-- signal En_alarm_in			: std_logic;	-- Aktivierung des Alarms
	signal En_alarm_out			: std_logic;	-- Ausgangssignal des Alarms
	signal D_alarm_sec_units	: std_logic_vector (3 downto 0);	-- Alarm Data IN Sekunden	Einer
	signal D_alarm_sec_tens		: std_logic_vector (3 downto 0);	-- Alarm Data IN Sekunden	Zehner
	signal D_alarm_min_units	: std_logic_vector (3 downto 0);	-- Alarm Data IN Minuten	Einer
	signal D_alarm_min_tens		: std_logic_vector (3 downto 0);	-- Alarm Data IN Minuten	Zehner
	signal D_alarm_hour_units	: std_logic_vector (3 downto 0);	-- Alarm Data IN Stunden	Einer
	signal D_alarm_hour_tens	: std_logic_vector (3 downto 0);	-- Alarm Data IN Stunden	Zehner
	
	
	signal Q_Alarm_min_units 	: std_logic_vector(3 downto 0);	-- Alarm Encoder Datenausgang
	signal Q_Alarm_min_tens 	: std_logic_vector(3 downto 0);
	signal Q_Alarm_hour_units 	: std_logic_vector(3 downto 0);
	signal Q_Alarm_hour_tens 	: std_logic_vector(3 downto 0);
	

	-- UI:

	signal CONTROL_Display_Min_Sec		: std_logic;
	signal CONTROL_Dispaly_Std_Min		: std_logic;
	signal CONTROL_Time_Setting_Std		: std_logic;
	signal CONTROL_Time_Setting_Min		: std_logic;
	signal CONTROL_Alarm_Setting_Std		: std_logic;
	signal CONTROL_Alarm_Setting_Min		: std_logic;
	signal CONTROL_Set_Time					: std_logic;
	signal CONTROL_Time_Display			: std_logic;
	signal CONTROL_NOT_Time_Display		: std_logic;
	signal CONTROL_Set_Std					: std_logic;
	
	
	--Display
	signal En_seg_int 					: std_logic;
	signal D_Display0						: std_logic_vector(3 downto 0);
	signal D_Display1						: std_logic_vector(3 downto 0);
	signal D_Display2						: std_logic_vector(3 downto 0);
	signal D_Display3						: std_logic_vector(3 downto 0);
	-- signal SegQ_0_int 					: out std_logic_vector(6 downto 0);
	-- signal SegQ_1_int 					: out std_logic_vector(6 downto 0);
	-- signal SegQ_2_int 					: out std_logic_vector(6 downto 0);
	-- signal SegQ_3_int 					: out std_logic_vector(6 downto 0);
begin

	En_seg_int <= '1';
	CONTROL_NOT_TIME_DISPLAY <= not CONTROL_Time_Display;
	
	Reset_int <= not Reset;			-- pushbutton should be high active
	Clear_Alarm_int <= not Clear_Alarm;	--high active
	Encoder_Button_int <= not Encoder_Button;	--high active
	
	

-----------------------------------------------
-- coreClock
coreClock : entity work.clockwork
--generic map (
--	Max25 => ,
--	Max50 => 
--)
port map (
	Clk_50		=> Clk_50,
	
	Reset		=> Reset_int,
	Clear 		=> Clear,
	
	Clk_sec 	=> Clk_sec,
	square_wav 	=> square_wav,
	
	Show_nSet			=>	CONTROL_Time_Display,
	Set_Clock_nAlarm 	=> CONTROL_Set_Time,
	Set_Hour_nMin 		=> CONTROL_Set_Std,
	
	En_alarm_in				=> En_alarm_in,				-- DataIn von Alarm stellen, einfacher Switch um Alarm zu aktivieren
	En_alarm_out 			=> En_alarm_out,
	
	Q_sec_units	=> Q_sec_units,				-- Display
	Q_sec_tens	=> Q_sec_tens,
	Q_min_units	=> Q_min_units,
	Q_min_tens	=> Q_min_tens,
	Q_hour_units => Q_hour_units,
	Q_hour_tens	=> Q_hour_tens,
	
	Q_al_min_units		=> D_alarm_min_units,
	Q_al_min_tens		=> D_alarm_min_tens,
	Q_al_hour_units	=> D_alarm_hour_units,
	Q_al_hour_tens		=> D_alarm_hour_tens,
	
	LED_out 	=> LED_out,	-- entspricht Rechtecksignal, abhÃ¤ngig von EingÃƒÂ¤ngen

	A_enc	=> A,
	B_enc	=> B
);


-----------------------------------------------
-- alarm:
alarm : entity work.Alarm
port map(
	Clk				=> Clk_50, -- 50 MHz
	Aktiv				=> En_alarm_out,
	Reset				=> Clear_Alarm_int,
	
	Alarm_out		=> Alarm_out,
	Sound				=> Sound
);

-----------------------------------------------
-- UI:
ui : entity work.clock_state_machine
port map(
	-- IN
	Next_State_Mode_Button	=> Encoder_Button_int,	--! Button to step trough the states
	clk							=> Clk_50,					--! Clock Signal
	Reset_to_initial_state 	=> Reset_int,				--! Reset Button/Switch to set the State to initial_state
	--Inc_Activ					=> Encoder_Activ,			--! Checking Signal if the Incremental is used or idle
	
	--OUT
	--! gives out an 1 or 0 Signal for the mode that is active 
	Display_Min_Sec 	=> CONTROL_Display_Min_Sec, 	--! Display_Min_Sec_int,
	Dispaly_Std_Min 	=> CONTROL_Dispaly_Std_Min,		--! Dispaly_Std_Min_int
	Time_Setting_Std 	=> CONTROL_Time_Setting_Std, 	--! Time_Setting_Std,
	Time_Setting_Min 	=> CONTROL_Time_Setting_Min, 	--! Time_Setting_Min,
	Alarm_Setting_Std => CONTROL_Alarm_Setting_Std, 	--! Alarm_Setting_Std,
	Alarm_Setting_Min => CONTROL_Alarm_Setting_Min,	--! Alarm_Setting_Min
	
	Set_Time 			=> CONTROL_Set_Time,			--! Set_Alarm if '1' -> set Alarm, if '0' -> set Time
	Time_Display 		=> CONTROL_Time_Display, 		--! Time gets displayed (for internal logic) if '1'
	Set_Std 				=> CONTROL_Set_Std,				--! If (set_Std) '1' -> Set Std, false -> Set Min 
	Q_min_units			=> Q_min_units
);


-----------------------------------------------
-- Display:

D_Display0 <= Q_hour_tens when CONTROL_Dispaly_Std_Min = '1' AND CONTROL_Time_Display = '1' else
				  Q_min_tens when CONTROL_Display_Min_Sec = '1' AND CONTROL_Time_Display = '1' else
				  Q_Alarm_hour_tens when square_wav = '1' else
				  "0000";

seg0 : entity work.HEX7SEG
generic map(HighActive => false )
port map (
	D => D_Display0,
	En => En_seg_int,
	-- out
	Q => SegQ_0
);

D_Display1 <= Q_hour_units when CONTROL_Dispaly_Std_Min = '1' AND CONTROL_Time_Display = '1' else
				  Q_min_units when CONTROL_Display_Min_Sec = '1' AND CONTROL_Time_Display = '1' else
				  Q_Alarm_hour_units when square_wav = '1' else
				  "0000";

seg1 : entity work.HEX7SEG
generic map(HighActive => false )
port map (
	D => D_Display1,
	En => En_seg_int,
	-- out
	Q => SegQ_1
);

D_Display2 <= Q_min_tens when CONTROL_Dispaly_Std_Min = '1' AND CONTROL_Time_Display = '1' else
				  Q_hour_tens when CONTROL_Display_Min_Sec = '1' AND CONTROL_Time_Display = '1' else
				  Q_Alarm_min_tens when square_wav = '1' else
				  "0000";

seg2 : entity work.HEX7SEG
generic map(HighActive => false )
port map (
	D => D_Display2,
	En => En_seg_int,
	-- out
	Q => SegQ_2
);

D_Display3 <= Q_min_units when CONTROL_Dispaly_Std_Min = '1' AND CONTROL_Time_Display = '1' else
				  Q_sec_units when CONTROL_Display_Min_Sec = '1' AND CONTROL_Time_Display = '1' else
				  Q_Alarm_min_units when square_wav = '1' else
				  "0000";

seg4 : entity work.HEX7SEG
generic map(HighActive => false )
port map (
	D => D_Display3,
	En => En_seg_int,
	-- out
	Q => SegQ_3
);


end architecture behave;