LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity clock_state_machine is	--! Mealy FSM
port (
	SIGNAL Next_State_Mode_Button		: IN std_logic;	--! Button to step trough the states
	SIGNAL clk								: IN std_logic;	--! Clock Signal
	SIGNAL Reset_to_initial_state 	: IN std_logic;	--! Reset Button/Switch to set the State to initial_state
	--! gives out an 1 or 0 Signal for the mode that is active 
	SIGNAL	Display_Min_Sec, Dispaly_Std_Min,	--! Display_Min_Sec_int, Dispaly_Std_Min_int
				Time_Setting_Std, 						--! Time_Setting_Std,
				Time_Setting_Min, 						--! Time_Setting_Min,
				Alarm_Setting_Std, 						--! Alarm_Setting_Std,
				Alarm_Setting_Min	: OUT std_logic; 	--! Alarm_Setting_Min
	
	SIGNAL	Set_Time,									--! Set_Time if '1' -> set Time, if '0' -> set Alarm
				Time_Display, 								--! Time gets displayed (for internal logic) if '1'
				Set_Std				: OUT std_logic;  --! If (set_Std) '1' -> Set Std, false -> Set Min 
	
	
	SIGNAL 	Q_min_units			: IN std_logic_vector(3 downto 0)
);
end clock_state_machine;
---------------------------------------------------------------------------------------------------------
ARCHITECTURE behave of clock_state_machine IS

	TYPE STATE_MODE_TYPE IS 	(Display_Min_Sec_int, Dispaly_Std_Min_int, 
										Time_Setting_Std_int,
										Time_Setting_Min_int,
										Alarm_Setting_Std_int,
										Alarm_Setting_Min_int);
	
	SIGNAL	current_state	:	STATE_MODE_TYPE;
	
	CONSTANT initial_state : STATE_MODE_TYPE := Display_Min_Sec_int; --! to be able to change the initial_state to a different one
	
	SIGNAL Clk_sec_int : std_logic := '0';	--! Impulssignal für interne Verwendung

	SIGNAL	D_Min_Sec_int, D_Std_Min_int,	--! Display_Min_Sec_int, Dispaly_Std_Min_int
				T_Setting_Std_int,				--! Time_Setting_Std_Ones_int, Time_Setting_Std_Tens_int
				T_Setting_Min_int, 				--! Time_Setting_Min_Ones_int, Time_Setting_Min_Tens_int
				A_Setting_Std_int, 				--! Alarm_Setting_Std_Ones_int, Alarm_Setting_Std_Tens_int
				A_Setting_Min_int : std_logic; --! Alarm_Setting_Min_Ones_int, Alarm_Setting_Min_Tens_int

	SIGNAL 	temp_counter, temp_reset		: integer; 	--! to reset to initial_state after 
																
	CONSTANT	temp_wait_time 					: integer := 30_000_000;	--! how many times it runs torugh the falling clock
		
	SIGNAL	temp_button_pressed  :	integer := 0; --! to use the button to step trough
	
	SIGNAL 	Q_min_units_int		:	std_logic_vector(3 downto 0);
---------------------------------------------------------------------------------------------------------										
BEGIN
	-- Clk_sec_int <= Clk_sec;				-- Sekundentakt-Schnittstelle von anderen

	Display_Min_Sec <= D_Min_Sec_int;
	Dispaly_Std_Min <= D_Std_Min_int;
	
	Time_Setting_Std <= T_Setting_Std_int;
	Time_Setting_Min <= T_Setting_Min_int;
	
	Alarm_Setting_Std <= A_Setting_Std_int;			
	Alarm_Setting_Min <= A_Setting_Min_int;	

---------------------------------------------------------------------------------------------------------
state_register : PROCESS (clk, Reset_to_initial_state, Next_State_Mode_Button, Q_min_units) --! Process used to step trough the current state

variable next_state	:	STATE_MODE_TYPE;

BEGIN


		
	--! Event handler for next State with reset and button pressed
	IF (Reset_to_initial_state = '1') THEN 
		current_state <= initial_state;	
	ELSIF (rising_edge(clk)) THEN 
		IF (Next_State_Mode_Button = '1' AND temp_button_pressed = 0) THEN
			temp_button_pressed <= 1;
			temp_reset <= 1;
		ELSIF (Next_State_Mode_Button = '0' AND temp_button_pressed = 1) THEN
		   next_state := current_state;
			CASE current_state IS
			WHEN Display_Min_Sec_int =>  
				next_state := Dispaly_Std_Min_int;
			WHEN Dispaly_Std_Min_int =>
				next_state := Time_Setting_Std_int;
			WHEN Time_Setting_Std_int =>
				next_state := Time_Setting_Min_int;
			WHEN Time_Setting_Min_int =>
				next_state := Alarm_Setting_Std_int;
			WHEN Alarm_Setting_Std_int =>
				next_state := Alarm_Setting_Min_int;
			WHEN Alarm_Setting_Min_int =>
				next_state := Display_Min_Sec_int;
			END CASE;	
			current_state <= next_state;
			temp_button_pressed <= 0;
			temp_reset <= 1;	
		END IF;
		IF (temp_reset = 1 OR Q_min_units_int /= Q_min_units) THEN 	--! Event handler for idle time => current_state -> initial_state
			temp_counter <= 0;
		ELSIF (temp_counter < temp_wait_time) THEN
			temp_counter <= temp_counter + 1;
		ELSE
			current_state <= initial_state;
		END IF;
	
	END IF;
	temp_reset <= 0;
	Q_min_units_int <= Q_min_units;
END PROCESS;
---------------------------------------------------------------------------------------------------------
next_state_output_logic : PROCESS (current_state, D_Min_Sec_int, D_Std_Min_int, T_Setting_Std_int, T_Setting_Min_int, A_Setting_Std_int, A_Setting_Min_int)

variable Set_Time_int, Time_Display_int, Set_Std_int : std_logic;

BEGIN

--! Switch Case for finit state machine
D_Min_Sec_int <= '0';
D_Std_Min_int <= '0';
T_Setting_Std_int <= '0';
T_Setting_Min_int <= '0';
A_Setting_Std_int <= '0';
A_Setting_Min_int <= '0';

CASE current_state is
WHEN Display_Min_Sec_int =>
	D_Min_Sec_int <= '1';					
	
WHEN Dispaly_Std_Min_int =>										
	D_Std_Min_int <= '1';
	
WHEN Time_Setting_Std_int =>
	T_Setting_Std_int <= '1';
		
WHEN Time_Setting_Min_int =>
	T_Setting_Min_int <= '1';
		
WHEN Alarm_Setting_Std_int =>
	A_Setting_Std_int <= '1';

WHEN Alarm_Setting_Min_int =>
	A_Setting_Min_int <= '1';	
END CASE;


--! Sets the Alarm to true if it is selected to change the Alarm time 
IF (T_Setting_Std_int = '1' OR T_Setting_Min_int = '1') THEN
	Set_Time_int := '1';
ELSE 
	Set_Time_int := '0';
END IF;

--! If Time_Display_int is true, then the Time is shown on the 7 Segment 
IF (D_Min_Sec_int = '1' OR D_Std_Min_int = '1') THEN
	Time_Display_int := '1';
ELSE 
	Time_Display_int := '0';
END IF;

--! If Set_Std_int is true, then Hours are getting selected to change, else min
IF (T_Setting_Std_int = '1' OR A_Setting_Std_int = '1') THEN
	Set_Std_int := '1';
ELSE 
	Set_Std_int := '0';
END IF;

Set_Time <= Set_Time_int;
Time_Display <= Time_Display_int;
Set_Std <= Set_Std_int;

END PROCESS next_state_output_logic;
---------------------------------------------------------------------------------------------------------										
END ARCHITECTURE behave;
