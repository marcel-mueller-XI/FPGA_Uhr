--! @file	IncEncoder.vhd
--! @brief	Decoder für die Inkrementalgeber der Pong-Erweiterungsplatine
--! @author	Sebastian Schmaus

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity IncEncoder is
	port(
		signal A 			: in std_logic;		--! Spur A des Inkrementalgebers
		signal B 			: in std_logic;		--! Spur B des Inkrementalgebers
		signal Clk 			: in std_logic;		--! Taktsignal
		signal Reset		: in std_logic;		--! Asynchroner Reset
		signal En 			: out std_logic;		--! Freigabesignal
		signal Up_nDown 	: out std_logic		--! Drehrichtung: '1': Hochzählen, '0': Runterzählen
	);
end entity IncEncoder;

architecture behave of IncEncoder is
	--! State Machine mit 4 gleichen Zuständen -> hier 6 für die Unterscheidung zwischen Hoch-/Runterzählen
	--! Zustände (0, A_nB, A_B, nA_B, nA_B, A_nB)
	type states is (s0, s1, s2, s3, s4, s5);
	
	signal current_state 	: states;			--! aktueller Zustand
	signal next_state 		: states;			--! nächster Zustand
	signal En_int 				: std_logic;		--! internes Enable-Signal
	signal Up_nDown_int 		: std_logic;		--! internes Up_nDown-Signal
	signal A1, A2				: std_logic;		--! interne Signale zur Synchronisation des asynchronen Eingangssignals A über zwei DFF
	signal B1, B2				: std_logic;		--! interne Signale zur Synchronisation des asynchronen Eingangssignals B über zwei DFF
	signal Reset1, Reset2	: std_logic;		--! interne Signale zur Synchronisation des asynchronen Resets
	
begin

	--! Synchronisationsprozess für die asynchronen Eingangssignale -> siehe Jürgen Reichardt Digitaltechnik 15.3 S.321
	sync_proc : process(Clk, Reset2)
	begin
		if Reset2 = '1' then
			A1 <= '0';
			A2 <= '0';
			B1 <= '0';
			B2 <= '0';
		elsif rising_edge(Clk) then
			A1 <= A;
			A2 <= A1;
			B1 <= B;
			B2 <= B1;
		end if;
	end process sync_proc;
	
	--! Synchronisationsprozess für den asynchronen Reset
	reset_sync_proc : process(Clk, Reset)
	begin
		if Reset = '1' then
			Reset1 <= '0';
			Reset2 <= '0';
		elsif rising_edge(Clk) then
			Reset1 <= '1';
			Reset2 <= not Reset1;
		end if;
	end process reset_sync_proc;
	
	--! Synchroner Prozess zur Speicherung des inneren Zustands und der Registered/Clocked Ausgangssignale
	clocked_proc : process(Clk, Reset2)
	begin
	
		--! Asynchroner Teil
		if Reset2 = '1' then
			current_state	<= s0;
			En					<= '0';
			Up_nDown			<= '0';
			
		--! Synchroner Teil
		elsif rising_edge(Clk) then			-- Synchrone Übernahme bei steigender Taktflanke
			current_state	<= next_state;
			En					<= En_int;
			Up_nDown			<= Up_nDown_int;
		end if;
	end process clocked_proc;
	
	--! Kombinatorischer Prozess zur Generierung des nächsten inneren Zustands -> siehe VhdlAutomaten, EDA-Wiki
	--! und Kombinatorischer Prozess zur Generierung des Ausgangszustands bzw. dem neuen Zustand für Registered Signale
	nextstate_proc : process(A2, B2, current_state)
	begin
		
		--! Defaul-Werte wegen der D-Latch-Problematik
		En_int			<= '0';
		Up_nDown_int	<= '0';
		
		case current_state is
			when s0 =>						--! Zustand s0
				if A2 = '1' then			--! Hochzählen: Übergang von 0 (s0) nach A_nB (s1)
					next_state <= s1;
				elsif B2 = '1' then		--! Runterzählen: Übergang von 0 (s0) nach nA_B (s4)
					next_state <= s4;
				else
					next_state <= s0;		--! keine Weiterschaltbedingung: Verbleib
				end if;
				
			when s1 =>						--! Zustand s1
				if A2 = '0' then			--! Hochzählen: Übergang von A_nB (s1) zurück nach 0 (s0), z.B. durch Tasterprellen
					next_state <= s0;
				elsif B2 = '1' then		--! Hochzählen: Übergang von A_nB (s1) nach A_B (s2), erst steigende Flanke von A dann von B
					next_state <= s2;
					En_int <= '1';			
					Up_nDown_int <= '1';
				else
					next_state <= s1;		--! keine Weiterschaltbedingung: Verbleib
				end if;
				
			when s2 =>						--! Zustand s2
				if A2 = '0' then			--! Hochzählen:	Übergang von A_B (s2) nach nA_B (s3)
					next_state <= s3;
				elsif B2 = '0' then		--! Runterzählen: Übergang von A_B (s2) nach A_nB (s5)
					next_state <= s5;
				else
					next_state <= s2;		--! keine Weiterschaltbedingung: Verbleib
				end if;
				
			when s3 =>						--! Zustand s3
				if A2 = '1' then			--! Hochzählen: Übergang von nA_B (s3) zurück nach A_B (s2)
					next_state <= s2;
				elsif B2 = '0' then		--! Hochzählen: Übergang von nA_B (s3) nach 0 (s0), erst fallende Flanke von A dann von B
					next_state <= s0;
					En_int <= '1';
					Up_nDown_int <= '1';
				else
					next_state <= s3;		--! keine Weiterschaltbedingung: Verbleib
				end if;
			
			when s4 =>						--! Zustand s4
				if B2 = '0' then			--! Runterzählen:	Übergang von nA_B (s4) zurück nach 0 (s0), z.B. durch Tasterprellen
					next_state <= s0;
				elsif A2 = '1' then		--! Runterzählen:	Übergang von nA_B (s4) nach A_B (s2), erst steigende Flanke von B dann von A
					next_state <= s2;
					En_int <= '1';
					Up_nDown_int <= '0';
				else
					next_state <= s4;		--! keine Weiterschaltbedingung: Verbleib
				end if;
				
			when s5 =>						--! Zustand s5
				if B2 = '1' then			--! Runterzählen:	Übergang von A_nB (s5) zurück nach A_B (s2)
					next_state <= s2;
				elsif A2 = '0' then		--! Runterzählen:	Übergang von A_nB (s5) nach 0 (s0), erst fallende Flanke von B dann von A
					next_state <= s0;
					En_int <= '1';
					Up_nDown_int <= '0';
				else
					next_state <= s5;		--! keine Weiterschaltbedingung: Verbleib
				end if;
			
			when others =>
				next_state <= s0;
				
		end case;
	end process nextstate_proc;
				
end architecture behave;