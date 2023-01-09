library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity IncEncoder_alarm is
	port(
		signal En_Encoder : in std_logic;
		signal A 			: in std_logic;
		signal B 			: in std_logic;
		signal Clk 			: in std_logic;
		signal Reset		: in std_logic;
		signal En 			: out std_logic;
		signal Up_nDown 	: out std_logic
	);
end entity IncEncoder_alarm;

architecture behave of IncEncoder_alarm is
	-- 4 gleiche Zustände, hier 6 für Unterscheidung Hoch-/Runterzählen
	-- Zustände (0, A_nB, A_B, nA_B, nA_B, A_nB)
	type states is (s0, s1, s2, s3, s4, s5);
	
	signal current_state : states;		-- aktueller Zustand
	signal next_state 	: states;		-- nächster Zustand
	signal En_int 			: std_logic;	-- interne Signale für die synchrone Übernahme der Werte
	signal Up_nDown_int 	: std_logic;
	signal A1, A2			: std_logic;	-- Synchronisation des asynchronen Eingangssignals A mit zwei DFF
	signal B1, B2			: std_logic;	-- Synchronisation des asynchronen Eingangssignals B mit zwei DFF
	signal Reset1, Reset2: std_logic;
begin
	-- Synchronisation asynchroner Eingangssignale -> Jürgen Reichardt Digitaltechnik 15.3 S. 321
	sync_proc : process(Clk, Reset)
	begin
		if Reset = '1' then
			A1 <= '0';	-- 1. DFF
			A2 <= '0';	-- 2. DFF
			B1 <= '0';	-- 1. DFF
			B2 <= '0';	-- 2. DFF
		elsif rising_edge(Clk) then
			A1 <= A;		-----------------------------------------------------------Verwenden im restlichen Programm
			A2 <= A1;
			B1 <= B;
			B2 <= B1;
		end if;
	end process sync_proc;
	
	-- Synchronisation des asynchronen Resets ???? ------------------------------Verwenden im restlichen Programm
	reset_sync_proc : process(Clk, Reset)
	begin
		if Reset = '1' then
			Reset1 <= '0';
			Reset2 <= Reset1;
		elsif rising_edge(Clk) then
			Reset1 <= '1';
			Reset2 <= not Reset1;
		end if;
	end process reset_sync_proc;
	
	clocked_proc : process(Clk, Reset2)	-- Synchroner Prozess, Speicherung des inneren Zustands
	begin											-- und Registered/Clocked Ausgangssignale
	
		--if Reset = '1' then					-- Default nach Reset
		if Reset2 = '1' then					-- Reset2 ??? Funktioniert die Synchronisierung des asynchronen Resets?
			current_state <= s0;
			En <= '0';							-- keine Zählfreigabe
			Up_nDown <= '0';					-- '0' oder '1' möglich, da En = '0'
			
		elsif rising_edge(Clk) then		-- Synchrone Übernahme bei steigender Taktflanke
			current_state <= next_state;
			En <= En_int;
			Up_nDown <= Up_nDown_int;
		end if;
	end process clocked_proc;
	
	-- Kombinatorischer Prozess zur Generierung des nächsten inneren Zustands -> siehe VhdlAutomaten, EDA-Wiki
	-- + Kombinatorischer Prozess zur Generierung des Ausgangszustands bzw. dem neuen Zustand für Registered Signale
	nextstate_proc : process(A2, B2, current_state, En_Encoder)
	begin
		
		En_int <= '0';						-- Default Assignments wegen D-Latch Problematik
		Up_nDown_int <= '0';
		next_state <= s0;
		if (En_Encoder = '1') then
			case current_state is
				when s0 =>
					if A2 = '1' then			-- Start Pfad: Hochzählen, von 0 (s0) nach A_nB (s1)
						next_state <= s1;
					elsif B2 = '1' then		-- Start Pfad: Runterzählen, von 0 (s0) nach nA_B (s4)
						next_state <= s4;
					else
						next_state <= s0;		-- sonst Verbleib
					end if;
					
				when s1 =>
					if A2 = '0' then			-- Hochzählen:		von A_nB (s1) zurück nach 0 (s0), z.B. durch Tasterprellen
						next_state <= s0;
					elsif B2 = '1' then		-- Hochzählen:		von A_nB (s1) nach A_B (s2) -> erst A dann B (steigende Flanke)
						next_state <= s2;
						En_int <= '1';			
						Up_nDown_int <= '1';
					else
						next_state <= s1;		-- sonst Verbleib
					end if;
					
				when s2 =>
					if A2 = '0' then			-- Hochzählen:		von A_B (s2) nach nA_B (s3)
						next_state <= s3;
					elsif B2 = '0' then		-- Runterzählen:	von A_B (s2) nach A_nB (s5)
						next_state <= s5;
					else
						next_state <= s2;		-- sonst Verbleib
					end if;
					
				when s3 =>
					if A2 = '1' then			-- Hochzählen:		von nA_B (s3) zurück nach A_B (s2)
						next_state <= s2;
					elsif B2 = '0' then		-- Hochzählen:		von nA_B (s3) nach 0 (s0) -> erst A dann B (fallende Flanke)
						next_state <= s0;
						En_int <= '1';
						Up_nDown_int <= '1';
					else
						next_state <= s3;		-- sonst Verbleib
					end if;
				
				when s4 =>
					if B2 = '0' then			-- Runterzählen:	von nA_B (s4) zurück nach 0 (s0), z.B. Tasterprellen
						next_state <= s0;
					elsif A2 = '1' then		-- Runterzählen:	von nA_B (s4) nach A_B (s2) -> erst B dann A (steigende Flanke)
						next_state <= s2;
						En_int <= '1';
						Up_nDown_int <= '0';
					else
						next_state <= s4;		-- sonst Verbleib
					end if;
					
				when s5 =>
					if B2 = '1' then			-- Runterzählen:	von A_nB (s5) zurück nach A_B (s2)
						next_state <= s2;
					elsif A2 = '0' then		-- Runterzählen:	von A_nB (s5) nach 0 (s0) -> erst B dann A (fallende Flanke)
						next_state <= s0;
						En_int <= '1';
						Up_nDown_int <= '0';
					else
						next_state <= s5;		-- sonst Verbleib
					end if;
				
				when others =>
					next_state <= s0;
					
			end case;
		end if;
	end process nextstate_proc;
				
end architecture behave;