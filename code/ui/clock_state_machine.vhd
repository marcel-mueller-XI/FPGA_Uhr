LIBRARY ieee;
USE ieee.std_logic_1164.all;

entity UserInterface is	--! Mealy FSM
port (
	Next_State_Mode_Button		: in std_logic;	--! Steps trough the States after press and release
	clk								: in std_logic;	--! Clock 
	rst								: in std_logic		--! Reset signal
	
);
end UserInterface;
---------------------------------------------------------------------------------------------------------
ARCHITECTURE behave of UserInterface IS

	TYPE STATE_MODE_TYPE IS 	(Display_Min_Sec, Dispaly_Std_Min, 
										Time_Setting_Std_Ones, Time_Setting_Std_Tens, 
										Time_Setting_Min_Ones, Time_Setting_Min_Tens,
										Alarm_Setting_Std_Ones, Alarm_Setting_Std_Tens,
										Alarm_Setting_Min_Ones, Alarm_Setting_Min_Tens);
	SIGNAL	current_state, next_state, initial_state	:	STATE_MODE_TYPE;
	
	SIGNAL	State_1, State_2,	-- Display_Min_Sec, Dispaly_Std_Min
				State_3, State_4, -- Time_Setting_Std_Ones, Time_Setting_Std_Tens
				State_5, State_6, -- Time_Setting_Min_Ones, Time_Setting_Min_Tens
				State_7, State_8, -- Alarm_Setting_Std_Ones, Alarm_Setting_Std_Tens
				State_9, State_10 : std_logic;  -- Alarm_Setting_Min_Ones, Alarm_Setting_Min_Tens

	SIGNAL	temp_button_pressed  :	std_logic; --! to use the button to step trough
---------------------------------------------------------------------------------------------------------										
BEGIN
---------------------------------------------------------------------------------------------------------
state_register : PROCESS (clk, rst) --! Process used to step trough the current state
BEGIN
	--initial_state <= Display_Min_Sec;
	IF (rst='1') THEN
		current_state <= initial_state;
	ELSIF (clk'event AND clk= '1' AND Next_State_Mode_Button= '1' AND temp_button_pressed = '0') THEN 
		temp_button_pressed <= '1';		
	ELSIF (clk'event AND clk= '1' AND Next_State_Mode_Button= '0' AND temp_button_pressed = '1') THEN
		current_state <= next_state;
		temp_button_pressed <= '0';
	END IF;
END PROCESS;
---------------------------------------------------------------------------------------------------------
next_state_output_logic : PROCESS (current_state, State_1, State_2, State_3, State_4, 
											  State_5, State_6, State_7, State_8, State_9, State_10)
BEGIN

CASE current_state is
WHEN Display_Min_Sec =>
	State_10 <= '0';
	State_1 <= '1';					
										
WHEN Dispaly_Std_Min =>										
	State_1 <= '0';
	State_2 <= '1';		
		
WHEN Time_Setting_Std_Ones =>
	State_2 <= '0';
	State_3 <= '1';
	
WHEN Time_Setting_Std_Tens =>
	State_3 <= '0';
	State_4 <= '1';
	
WHEN Time_Setting_Min_Ones =>
	State_4 <= '0';
	State_5 <= '1';
	
WHEN Time_Setting_Min_Tens =>
	State_5 <= '0';
	State_6 <= '1';
	
WHEN Alarm_Setting_Std_Ones =>
	State_6 <= '0';
	State_7 <= '1';

WHEN Alarm_Setting_Std_Tens =>
	State_7 <= '0';
	State_8 <= '1';

WHEN Alarm_Setting_Min_Ones =>
	State_8 <= '0';
	State_9 <= '1';
	
WHEN Alarm_Setting_Min_Tens =>
	State_9 <= '0';
	State_10 <= '1';

END CASE;
END PROCESS next_state_output_logic;
---------------------------------------------------------------------------------------------------------										
END ARCHITECTURE behave;