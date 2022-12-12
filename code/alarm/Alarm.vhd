------------------------------------------------------
-- Aufgabe 7: 	Uhr										 	 --
-- Datei:	   Alarm.vhd					 			 	 --
-- Autor:   	Jonas Sachwitz & Marco Stütz      	 --
-- Datum:   	29.11.2022                        	 --
------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
--USE ieee.numeric_std.all;   -- unsigned / signed

ENTITY Alarm IS
	PORT(
		--Uhr_h_10er		: 	IN		std_logic_vector (3 DOWNTO 0);
		--Uhr_h_1er		: 	IN		std_logic_vector (3 DOWNTO 0);
		--Uhr_m_10er		: 	IN		std_logic_vector (3 DOWNTO 0);
		--Uhr_m_1er		: 	IN		std_logic_vector (3 DOWNTO 0);
		--Alarm_h_10er	: 	IN		std_logic_vector (3 DOWNTO 0);
		--Alarm_h_1er		: 	IN		std_logic_vector (3 DOWNTO 0);
		--Alarm_m_10er	: 	IN		std_logic_vector (3 DOWNTO 0);
		--Alarm_m_1er		: 	IN		std_logic_vector (3 DOWNTO 0);
		Clk				: 	IN		std_logic; -- 50 MHz
		Aktiv				:	IN		std_logic; -- 
		Reset          :  IN 	std_logic;
		
		Alarm_out		: 	OUT   std_logic;
		Sound				:	OUT	std_logic
		
		-- test
		--Timer          : OUT    integer
		--test
  );
END Alarm;


ARCHITECTURE behave OF Alarm IS
   TYPE STATE_TYPE IS ( s_break_1, s_break_2, s_break_3, s_break_4, s_break_5, s_break_6, s_break_7, s_break_8, s_break_9, s_break_10,s_break_11,
							   s_a1, s_a2, s_a3, s_a4, s_a5, s_a6, s_a7, s_c8, s_f9, s_g10, s_a11);
	
	SIGNAL
	current_state : STATE_TYPE;
	-- Register fÃ¼r den internen Zustand --> clocked_proc
	SIGNAL
	next_state : STATE_TYPE;
	-- kombinatorisch gebildet --> nextstate_proc


	signal 	Alarm_int 	: 	std_logic;
	signal 	Alarm_mem 	: 	std_logic;
	signal	Sound_int	:	std_logic;
	signal	Clk_a			:	std_logic := '0';
	signal	Clk_c			:	std_logic := '0';
	signal	Clk_g			:	std_logic := '0';
	signal	Clk_f			:	std_logic := '0';
	signal	count_a		:	integer := 0;
	signal	count_c		:	integer := 0;
	signal	count_g		:	integer := 0;
	signal	count_f		:	integer := 0;
	signal	tone_a		: 	std_logic;
	signal	tone_c		: 	std_logic;
	signal	tone_g		: 	std_logic;
	signal	tone_f		: 	std_logic;
	signal   t           :  integer; --timer for sates
	signal	reset_int  :  std_logic;
	
	constant eighth_note : integer := 6250000; --timer for eighth note;
	constant quater_note : integer := 12500000; --timer for quater note;
	constant dotted_quater_note : integer := 18750000; --timer for quater note;
	constant half_note : integer := 25000000; --timer for quater note;
	constant timer_break : integer := 500000; --timer for breaK

BEGIN
	Alarm_out 	<= Alarm_mem;
	-- Alarm_int 	<= '1' WHEN ((Aktiv = '1') AND (Uhr_h_10er = Alarm_h_10er) AND (Uhr_h_1er = Alarm_h_1er) AND (Uhr_m_10er = Alarm_m_10er) AND (Uhr_m_1er = Alarm_m_1er))ELSE
	--					'0';
	-- Alarm_mem	<= '1' WHEN (Aktiv = '1') ELSE
	-- 					'0';	
	-- test:
	--Timer <= t;
	
	reset_int   <= '0' WHEN (Alarm_mem = '1') ELSE  -- reset Timer
						'1';
						
	-- Aktiv Proc 
	aktiv_proc : PROCESS(Aktiv, Reset)
	BEGIN
		IF (Reset = '1') THEN
			-- Startzustand nach einem Reset
			Alarm_mem <= '0';
		ELSIF rising_edge(Aktiv) THEN
			-- Ãbernahme des neuen inneren Zustandes
			Alarm_mem <= '1';
		END IF;
	END PROCESS aktiv_proc;
	
	-- States 
	clocked_proc : PROCESS( Clk, Reset_int)
	BEGIN
		IF (Reset_int = '1') THEN
			-- Startzustand nach einem Reset
			current_state <= s_a1;
		ELSIF rising_edge(Clk) THEN
			-- Ãbernahme des neuen inneren Zustandes
			current_state <= next_state;
		END IF;
	END PROCESS clocked_proc;
	
	--Timer for States
	timer_proc : PROCESS( Clk, Reset_int)
	BEGIN
		IF (Reset_int = '1') THEN
			t <= 0; 
		ELSIF rising_edge(Clk) THEN
			IF current_state /= next_state THEN
				t <= 0;
			ELSE
				t <= t + 1;
			END IF;
		END IF;
	END PROCESS timer_proc;
	
   --Next states
	nextstate_proc : PROCESS( current_state, t )
	BEGIN
		next_state <= current_state;
		CASE current_state IS
			WHEN s_a1 =>
				IF ( t >= quater_note ) THEN
					next_state <= s_break_1;
				END IF;
	
			WHEN s_a2 =>
				IF ( t >= quater_note ) THEN
					next_state <= s_break_2;
				END IF;
			
			WHEN s_a3 =>
				IF ( t >= half_note ) THEN
					next_state <= s_break_3;
				END IF;
			
			WHEN s_a4 =>
				IF ( t >= quater_note ) THEN
					next_state <= s_break_4;
				END IF;
			
			WHEN s_a5 =>
				IF ( t >= quater_note ) THEN
					next_state <= s_break_5;
				END IF;
				
			WHEN s_a6 =>
				IF ( t >= half_note ) THEN
					next_state <= s_break_6;
				END IF;
			
			WHEN s_a7 =>
				IF ( t >= quater_note ) THEN
					next_state <= s_break_7;
				END IF;
				
			WHEN s_c8 =>
				IF ( t >= quater_note ) THEN
					next_state <= s_break_8;
				END IF;
				
			WHEN s_f9 =>
				IF ( t >= dotted_quater_note ) THEN
					next_state <= s_break_9;
				END IF;
				
			WHEN s_g10 =>
				IF ( t >= eighth_note ) THEN
					next_state <= s_break_10;
				END IF;
				
			WHEN s_a11 =>
				IF ( t >= half_note ) THEN
					next_state <= s_break_11;
				END IF;
				
			--break between tone
			WHEN s_break_1 =>  
				IF ( t >= timer_break ) THEN
					next_state <= s_a2;
				END IF;
		
			WHEN s_break_2 =>
				IF ( t >= timer_break ) THEN
					next_state <= s_a3;
				END IF;
			WHEN s_break_3 =>
				IF ( t >= timer_break ) THEN
					next_state <= s_a4;
				END IF;
			WHEN s_break_4 =>
				IF ( t >= timer_break ) THEN
					next_state <= s_a5;
				END IF;
			WHEN s_break_5 =>
				IF ( t >= timer_break ) THEN
					next_state <= s_a6;
				END IF;
			WHEN s_break_6 =>
				IF ( t >= timer_break ) THEN
					next_state <= s_a7;
				END IF;
			WHEN s_break_7 => 
				IF ( t >= timer_break ) THEN
					next_state <= s_c8;
				END IF;
			WHEN s_break_8 =>
				IF ( t >= timer_break ) THEN
					next_state <= s_f9;
				END IF;
			WHEN s_break_9 => 
				IF ( t >= timer_break ) THEN
					next_state <= s_g10;
				END IF;
			WHEN s_break_10 => 
				IF ( t >= timer_break ) THEN
					next_state <= s_a11;
				END IF;
			WHEN s_break_11 =>
				IF ( t >= half_note ) THEN
					next_state <= s_a1;
				END IF;	
				
			WHEN OTHERS =>
				next_state <= s_a1;
		END CASE;
	END PROCESS nextstate_proc;
	
	-- Melody Jingle Bells
	output_proc : PROCESS( current_state, clk_a, clk_c, clk_f, clk_g, alarm_mem)
	BEGIN
	-- Default Assignment, wichtig! D-Latch Problematik
		Sound <= '0';
	-- Combined Actions
		CASE current_state IS
			WHEN s_a1 => -- Initialschritt
				IF (clk_a = '1' and alarm_mem = '1' ) THEN
					Sound <= '1';
				ELSE 
					Sound <='0';
				END IF;
			WHEN s_a2 => 
				IF (clk_a = '1' AND alarm_mem = '1'  ) THEN
					Sound <= '1';
				ELSE 
					Sound <='0';
				END IF;
			WHEN s_a3 => 
				IF (clk_a = '1' AND alarm_mem = '1' ) THEN
					Sound <= '1';
				ELSE 
					Sound <='0';
				END IF;
			WHEN s_a4 => 
				IF (clk_a = '1' AND alarm_mem = '1' ) THEN
					Sound <= '1';
				ELSE 
					Sound <='0';
				END IF;
			WHEN s_a5 => 
				IF (clk_a = '1' AND alarm_mem = '1' ) THEN
					Sound <= '1';
				ELSE 
					Sound <='0';
				END IF;
			WHEN s_a6 => 
				IF (clk_a = '1' AND alarm_mem = '1' ) THEN
					Sound <= '1';
				ELSE 
					Sound <='0';
				END IF;
			WHEN s_a7 => 
				IF (clk_a = '1' AND alarm_mem = '1'  ) THEN
					Sound <= '1';
				ELSE 
					Sound <='0';
				END IF;
			WHEN s_c8 => 
				IF (clk_c = '1' AND alarm_mem = '1' ) THEN
					Sound <= '1';
				ELSE 
					Sound <='0';
				END IF;
			WHEN s_f9 => 
				IF (clk_f = '1' AND alarm_mem = '1' ) THEN
					Sound <= '1';
				ELSE 
					Sound <='0';
				END IF;
			WHEN s_g10 => 
				IF (clk_g = '1' AND alarm_mem = '1' ) THEN
					Sound <= '1';
				ELSE 
					Sound <='0';
				END IF;
			WHEN s_a11 => 
				IF (clk_a = '1' AND alarm_mem = '1' ) THEN
					Sound <= '1';
				ELSE 
					Sound <='0';
				END IF;
			WHEN s_break_1 => 
				Sound <= '0';
			WHEN s_break_2 => 
				Sound <= '0';
			WHEN s_break_3 => 
				Sound <= '0';
			WHEN s_break_4 => 
				Sound <= '0';
			WHEN s_break_5 => 
				Sound <= '0';
			WHEN s_break_6 => 
				Sound <= '0';
			WHEN s_break_7 => 
				Sound <= '0';
			WHEN s_break_8 => 
				Sound <= '0';
			WHEN s_break_9 => 
				Sound <= '0';
			WHEN s_break_10 => 
				Sound <= '0';
			WHEN s_break_11 => 
				Sound <= '0';
			WHEN OTHERS
				=>NULL;
		END CASE;
	END PROCESS output_proc;
	
	-- tone f
	proc_tone_f: process(Clk)
	begin
		if (rising_edge(Clk)) then
			count_f <= count_f + 1;
			if (count_f >= 71021) then	--> 352Hz
				if ( Clk_f = '0') then
					Clk_f <= '1';
				else
					Clk_f <= '0';
				end if;
				count_f <= 0;
			end if;
		end if;	
	end process proc_tone_f;
	
	-- tone g
	proc_tone_g: process(Clk)
	begin
		if (rising_edge(Clk)) then
			count_g <= count_g + 1;
			if (count_g >= 63130) then	--> 396Hz
				if ( Clk_g = '0') then
					Clk_g <= '1';
				else
					Clk_g <= '0';
				end if;
				count_g <= 0;
			end if;
		end if;	
	end process proc_tone_g;
	
	-- tone a
	proc_tone_a: process(Clk)
	begin
		if (rising_edge(Clk)) then
			count_a <= count_a + 1;
			if (count_a >= 56817) then	--> 440Hz
				if ( Clk_a = '0') then
					Clk_a <= '1';
				else
					Clk_a <= '0';
				end if;
				count_a <= 0;
			end if;
		end if;
	end process proc_tone_a;
	
	-- tone c
	proc_tone_c: process(Clk)
	begin
		if (rising_edge(Clk)) then
			count_c <= count_c + 1;
			if (count_c >= 47437) then	--> 527Hz
				if ( Clk_c = '0') then
					Clk_c <= '1';
				else
					Clk_c <= '0';
				end if;
				count_c <= 0;
			end if;
		end if;
	end process proc_tone_c;

END behave;