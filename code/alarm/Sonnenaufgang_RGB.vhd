------------------------------------------------------
-- Aufgabe 7: 	Uhr										 	 --
-- Datei:	   Sonnenaufgang_RGB.vhd					 --
-- Autor:   	Jonas Sachwitz & Marco Stütz      	 --
-- Datum:   	06.12.2022                        	 --
------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;   -- unsigned / signed

ENTITY Sonnenaufgang_RGB IS
	PORT(
		Alarm				: 		IN		std_logic;
		Reset				: 		IN		std_logic;
		Clk				: 		IN		std_logic;	-- 50 MHz
		
		-- 0..7 RED			8..15 GREEN			16..23 BLUE
		RGB_OUT			: 		OUT   std_logic_vector(23 DOWNTO 0)
  );
END Sonnenaufgang_RGB;

ARCHITECTURE behave OF Sonnenaufgang_RGB IS
	-- Type for State Mahine
   TYPE STATE_TYPE IS ( s_0, s_Count, s_End);
	-- Type for color values
	TYPE RGB IS RECORD
		R	:	std_logic_vector(7 DOWNTO 0);
		G	:	std_logic_vector(7 DOWNTO 0);
		B	:	std_logic_vector(7 DOWNTO 0);
	END RECORD;
	-- Array for n * RGB values
	TYPE RGB_ARRAY IS ARRAY(31 DOWNTO 0) OF RGB;
	
	-- Signals for state machine
	SIGNAL
	current_state : STATE_TYPE;
	SIGNAL
	next_state : STATE_TYPE;
	-- Other Signals
	SIGNAL RGB_int 		: RGB;
	SIGNAL RGB_ARRAY_int	: RGB_ARRAY;
	SIGNAL c 				: integer;	-- Counter for timing
	SIGNAL count			: integer	:= 0;	-- Counter for Array/Color

BEGIN
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */ 
	-- Internal Signal to Output
	-- RED
	RGB_OUT(0) 		<= RGB_int.R(0);
	RGB_OUT(1) 		<= RGB_int.R(1);
	RGB_OUT(2) 		<= RGB_int.R(2);
	RGB_OUT(3) 		<= RGB_int.R(3);
	RGB_OUT(4) 		<= RGB_int.R(4);
	RGB_OUT(5) 		<= RGB_int.R(5);
	RGB_OUT(6) 		<= RGB_int.R(6);
	RGB_OUT(7) 		<= RGB_int.R(7);
	-- GREEN
	RGB_OUT(8) 		<= RGB_int.G(0);
	RGB_OUT(9) 		<= RGB_int.G(1);
	RGB_OUT(10) 	<= RGB_int.G(2);
	RGB_OUT(11) 	<= RGB_int.G(3);
	RGB_OUT(12) 	<= RGB_int.G(4);
	RGB_OUT(13) 	<= RGB_int.G(5);
	RGB_OUT(14) 	<= RGB_int.G(6);
	RGB_OUT(15) 	<= RGB_int.G(7);
	-- BLUE
	RGB_OUT(16) 	<= RGB_int.B(0);
	RGB_OUT(17) 	<= RGB_int.B(1);
	RGB_OUT(18) 	<= RGB_int.B(2);
	RGB_OUT(19) 	<= RGB_int.B(3);
	RGB_OUT(20) 	<= RGB_int.B(4);
	RGB_OUT(21) 	<= RGB_int.B(5);
	RGB_OUT(22) 	<= RGB_int.B(6);
	RGB_OUT(23) 	<= RGB_int.B(7);
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
	-- Timer for States to change color frequently
	timer_proc : PROCESS( Clk, Reset)
	BEGIN
		IF ((Reset = '1')) THEN
			c <= 0;
			count <= 0;
		ELSIF rising_edge(Clk) THEN
			IF  (c >= 10_000_000) THEN -- after 200 ms
				c <= 0;
				IF ( count >= 31 ) THEN
					count <= 0;
				ELSE
					count <= count + 1;
				END IF;
			ELSIF (current_state = s_Count OR current_state = s_End) THEN
				c <= c + 1;
			END IF;
		END IF;
	END PROCESS timer_proc;
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */ 
	-- State machine
	-- States 
	clocked_proc : PROCESS( Clk, Reset)
	BEGIN
		IF (Reset = '1') THEN
			-- Startzustand nach einem Reset
			current_state <= s_0;
		ELSIF rising_edge(Clk) THEN
			-- Ãbernahme des neuen inneren Zustandes
			current_state <= next_state;
		END IF;
	END PROCESS clocked_proc;
	
   --Next states
	nextstate_proc : PROCESS( current_state, c, Alarm, count)
	BEGIN
		next_state <= current_state;
		CASE current_state IS
			WHEN s_0 =>
				--count <= 0;
				IF ( Alarm = '1' ) THEN
					next_state <= s_Count;
				END IF;
	
			WHEN s_Count =>
				IF ( Alarm = '0') THEN
					next_state <= s_End;
				ELSIF ( c >= 10_000_000 ) THEN	-- after 200 ms
					next_state <= s_Count;
				END IF;
				
			WHEN s_End =>
				IF ( c >= 100_000_000 ) THEN		-- after 2 s
					next_state <= s_0;
				END IF;
				
			WHEN OTHERS =>
				next_state <= s_0;
		END CASE;
	END PROCESS nextstate_proc;
	
	-- Output
	output_proc : PROCESS( current_state, count, RGB_ARRAY_int)
	BEGIN
	-- Default Assignment, wichtig! D-Latch Problematik
		--RGB_int <= RGB_ARRAY_int(0);   <-- Notwendig??
	-- Combined Actions
		CASE current_state IS
			WHEN s_0 => -- Initialschritt
				RGB_int <= RGB_ARRAY_int(0);
			WHEN s_Count => 
				RGB_int <= RGB_ARRAY_int(count);
			WHEN s_End => 
				RGB_int <= RGB_ARRAY_int(31);
			WHEN OTHERS
				=>NULL;
		END CASE;
	END PROCESS output_proc;
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
-- Colors
-- DARK BLUE
RGB_ARRAY_int(0).R <= std_logic_vector(to_unsigned(32,8));
RGB_ARRAY_int(0).G <= std_logic_vector(to_unsigned(32,8));
RGB_ARRAY_int(0).B <= std_logic_vector(to_unsigned(255,8));

RGB_ARRAY_int(1).R <= std_logic_vector(to_unsigned(32,8));
RGB_ARRAY_int(1).G <= std_logic_vector(to_unsigned(67,8));
RGB_ARRAY_int(1).B <= std_logic_vector(to_unsigned(255,8));

RGB_ARRAY_int(2).R <= std_logic_vector(to_unsigned(32,8));
RGB_ARRAY_int(2).G <= std_logic_vector(to_unsigned(96,8));
RGB_ARRAY_int(2).B <= std_logic_vector(to_unsigned(255,8));

RGB_ARRAY_int(3).R <= std_logic_vector(to_unsigned(32,8));
RGB_ARRAY_int(3).G <= std_logic_vector(to_unsigned(125,8));
RGB_ARRAY_int(3).B <= std_logic_vector(to_unsigned(255,8));

RGB_ARRAY_int(4).R <= std_logic_vector(to_unsigned(32,8));
RGB_ARRAY_int(4).G <= std_logic_vector(to_unsigned(155,8));
RGB_ARRAY_int(4).B <= std_logic_vector(to_unsigned(255,8));

RGB_ARRAY_int(5).R <= std_logic_vector(to_unsigned(32,8));
RGB_ARRAY_int(5).G <= std_logic_vector(to_unsigned(178,8));
RGB_ARRAY_int(5).B <= std_logic_vector(to_unsigned(255,8));

RGB_ARRAY_int(6).R <= std_logic_vector(to_unsigned(32,8));
RGB_ARRAY_int(6).G <= std_logic_vector(to_unsigned(203,8));
RGB_ARRAY_int(6).B <= std_logic_vector(to_unsigned(255,8));

RGB_ARRAY_int(7).R <= std_logic_vector(to_unsigned(32,8));
RGB_ARRAY_int(7).G <= std_logic_vector(to_unsigned(226,8));
RGB_ARRAY_int(7).B <= std_logic_vector(to_unsigned(255,8));
-- BRIGHT BLUE
RGB_ARRAY_int(8).R <= std_logic_vector(to_unsigned(32,8));
RGB_ARRAY_int(8).G <= std_logic_vector(to_unsigned(252,8));
RGB_ARRAY_int(8).B <= std_logic_vector(to_unsigned(255,8));

RGB_ARRAY_int(9).R <= std_logic_vector(to_unsigned(32,8));
RGB_ARRAY_int(9).G <= std_logic_vector(to_unsigned(255,8));
RGB_ARRAY_int(9).B <= std_logic_vector(to_unsigned(223,8));

RGB_ARRAY_int(10).R <= std_logic_vector(to_unsigned(32,8));
RGB_ARRAY_int(10).G <= std_logic_vector(to_unsigned(255,8));
RGB_ARRAY_int(10).B <= std_logic_vector(to_unsigned(191,8));

RGB_ARRAY_int(11).R <= std_logic_vector(to_unsigned(32,8));
RGB_ARRAY_int(11).G <= std_logic_vector(to_unsigned(255,8));
RGB_ARRAY_int(11).B <= std_logic_vector(to_unsigned(159,8));

RGB_ARRAY_int(12).R <= std_logic_vector(to_unsigned(32,8));
RGB_ARRAY_int(12).G <= std_logic_vector(to_unsigned(255,8));
RGB_ARRAY_int(12).B <= std_logic_vector(to_unsigned(127,8));

RGB_ARRAY_int(13).R <= std_logic_vector(to_unsigned(32,8));
RGB_ARRAY_int(13).G <= std_logic_vector(to_unsigned(255,8));
RGB_ARRAY_int(13).B <= std_logic_vector(to_unsigned(95,8));

RGB_ARRAY_int(14).R <= std_logic_vector(to_unsigned(32,8));
RGB_ARRAY_int(14).G <= std_logic_vector(to_unsigned(255,8));
RGB_ARRAY_int(14).B <= std_logic_vector(to_unsigned(63,8));
-- GREEN
RGB_ARRAY_int(15).R <= std_logic_vector(to_unsigned(32,8));
RGB_ARRAY_int(15).G <= std_logic_vector(to_unsigned(255,8));
RGB_ARRAY_int(15).B <= std_logic_vector(to_unsigned(32,8));

RGB_ARRAY_int(16).R <= std_logic_vector(to_unsigned(63,8));
RGB_ARRAY_int(16).G <= std_logic_vector(to_unsigned(255,8));
RGB_ARRAY_int(16).B <= std_logic_vector(to_unsigned(32,8));

RGB_ARRAY_int(17).R <= std_logic_vector(to_unsigned(95,8));
RGB_ARRAY_int(17).G <= std_logic_vector(to_unsigned(255,8));
RGB_ARRAY_int(17).B <= std_logic_vector(to_unsigned(32,8));

RGB_ARRAY_int(18).R <= std_logic_vector(to_unsigned(127,8));
RGB_ARRAY_int(18).G <= std_logic_vector(to_unsigned(255,8));
RGB_ARRAY_int(18).B <= std_logic_vector(to_unsigned(32,8));

RGB_ARRAY_int(19).R <= std_logic_vector(to_unsigned(159,8));
RGB_ARRAY_int(19).G <= std_logic_vector(to_unsigned(255,8));
RGB_ARRAY_int(19).B <= std_logic_vector(to_unsigned(32,8));

RGB_ARRAY_int(20).R <= std_logic_vector(to_unsigned(191,8));
RGB_ARRAY_int(20).G <= std_logic_vector(to_unsigned(255,8));
RGB_ARRAY_int(20).B <= std_logic_vector(to_unsigned(32,8));

RGB_ARRAY_int(21).R <= std_logic_vector(to_unsigned(223,8));
RGB_ARRAY_int(21).G <= std_logic_vector(to_unsigned(255,8));
RGB_ARRAY_int(21).B <= std_logic_vector(to_unsigned(32,8));
-- YELLOW
RGB_ARRAY_int(22).R <= std_logic_vector(to_unsigned(255,8));
RGB_ARRAY_int(22).G <= std_logic_vector(to_unsigned(255,8));
RGB_ARRAY_int(22).B <= std_logic_vector(to_unsigned(32,8));

RGB_ARRAY_int(23).R <= std_logic_vector(to_unsigned(255,8));
RGB_ARRAY_int(23).G <= std_logic_vector(to_unsigned(230,8));
RGB_ARRAY_int(23).B <= std_logic_vector(to_unsigned(32,8));

RGB_ARRAY_int(24).R <= std_logic_vector(to_unsigned(255,8));
RGB_ARRAY_int(24).G <= std_logic_vector(to_unsigned(204,8));
RGB_ARRAY_int(24).B <= std_logic_vector(to_unsigned(32,8));
-- ORANGE
RGB_ARRAY_int(25).R <= std_logic_vector(to_unsigned(255,8));
RGB_ARRAY_int(25).G <= std_logic_vector(to_unsigned(181,8));
RGB_ARRAY_int(25).B <= std_logic_vector(to_unsigned(32,8));

RGB_ARRAY_int(26).R <= std_logic_vector(to_unsigned(255,8));
RGB_ARRAY_int(26).G <= std_logic_vector(to_unsigned(155,8));
RGB_ARRAY_int(26).B <= std_logic_vector(to_unsigned(32,8));

RGB_ARRAY_int(27).R <= std_logic_vector(to_unsigned(255,8));
RGB_ARRAY_int(27).G <= std_logic_vector(to_unsigned(131,8));
RGB_ARRAY_int(27).B <= std_logic_vector(to_unsigned(32,8));

RGB_ARRAY_int(28).R <= std_logic_vector(to_unsigned(255,8));
RGB_ARRAY_int(28).G <= std_logic_vector(to_unsigned(106,8));
RGB_ARRAY_int(28).B <= std_logic_vector(to_unsigned(32,8));

RGB_ARRAY_int(29).R <= std_logic_vector(to_unsigned(255,8));
RGB_ARRAY_int(29).G <= std_logic_vector(to_unsigned(82,8));
RGB_ARRAY_int(29).B <= std_logic_vector(to_unsigned(32,8));

RGB_ARRAY_int(30).R <= std_logic_vector(to_unsigned(255,8));
RGB_ARRAY_int(30).G <= std_logic_vector(to_unsigned(56,8));
RGB_ARRAY_int(30).B <= std_logic_vector(to_unsigned(32,8));
-- RED
RGB_ARRAY_int(31).R <= std_logic_vector(to_unsigned(255,8));
RGB_ARRAY_int(31).G <= std_logic_vector(to_unsigned(32,8));
RGB_ARRAY_int(31).B <= std_logic_vector(to_unsigned(32,8));
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */ 
END behave;