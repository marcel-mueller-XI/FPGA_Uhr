--! @file	Counter.vhd
--! @brief	Synchroner 4-Bit Zähler
--! @author	Sebastian Schmaus

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Counter is
	generic(
		TCO		: time := 10 ns;									--! Verzögerungszeit (Clock to Output) eines D-FF, Default = 10 ns zur Verdeutlichung in der Simulation
		TD			: time :=  7 ns;									--! Verzögerungszeit (Delay) der Kombinatorik durch LUT/Wire, Default = 7 ns zur Verdeutlichung in der Simulation
		Max		: std_logic_vector(3 downto 0) := x"9"		--! Maximalwert des Counters vor einem Überlauf auf die nächste Stelle
	);
	port(
		Reset 	: in std_logic;									--! Asynchroner Reset
		Clk 		: in std_logic;									--! Taktsignal (rising edge)
		Clear 	: in std_logic;									--! Datenausgang Q synchron auf 0 zurücksetzen
		Load 		: in std_logic;									--! Dateneingang D synchron in den Zähler übernehmen
		En 		: in std_logic;									--! Zählfreigabe
		Up_nDown : in std_logic;									--! Zählrichtung, '1': Hochzählen, '0': Runterzählen
		D 			: in std_logic_vector(3 downto 0);			--! Dateneingang
		Q 			: out std_logic_vector(3 downto 0); 		--! Datenausgang, Zählwert
		Cas 		: out std_logic									--! Kaskadierungssignal
	);
end entity Counter;

architecture behave of Counter is
	signal Q_int 			: std_logic_vector(3 downto 0);	--! Datenausgang für interne Verwendung
	signal Q_TCO 			: std_logic_vector(3 downto 0);	--! Verzögerter Datenausgang Q um TCO
	signal Cas_int			: std_logic;							--! Kaskadierungssignal für interne Verwendung
	
	constant Q_int_max	: std_logic_vector(3 downto 0) := Max;					--! Maximalwert des Counters vor einem Überlauf
	constant Q_int_min	: std_logic_vector(3 downto 0) := (others => '0');	--! Minimalwert des Counters vor einem Unterlauf
	
begin
	Q <= Q_TCO;
	Q_TCO <= std_logic_vector(Q_int) after TCO;
	
	--! Erzeugung des Kaskadierungssignals aus dem um TCO verzögerten Datenausgang
	Cas_int <= '1' when (En = '1' and (((Q_TCO >= Q_int_max) and (Up_nDown = '1')) or ((Q_TCO = Q_int_min) and (Up_nDown = '0')))) else
				  '0';
	Cas <= Cas_int after TD;
	
	--! Synchronen Zähler
	clocked : process(Clk, Reset)
	begin
	
		--! Asynchroner Teil
		if Reset = '1' then
			Q_int <= (others => '0');
			
		--! Synchroner Teil des Prozesses mit Zählfunktionalität
		elsif rising_edge(Clk) then
		
			if Clear = '1' then				-- Synchrones Rücksetzen
				Q_int <= (others => '0');
				
			elsif Load = '1' then			-- Synchrones Laden
				if D > Q_int_max then
					Q_int <= Q_int_max;
				else
					Q_int <= D;
				end if;
			
			-- Zählfunktionalität
			elsif En = '1' then
				if Up_nDown = '1' then		-- Hochzählen
					if Q_int < Q_int_max then
						Q_int <= std_logic_vector(unsigned(Q_int) + 1);
					else
						Q_int <= Q_int_min;
					end if;
				elsif Up_nDown = '0' then	-- Runterzählen
					if Q_int > Q_int_min then
						Q_int <= std_logic_vector(unsigned(Q_int) - 1);
					else
						Q_int <= Q_int_max;
					end if;
					
				end if;
			end if;
		end if;
	end process clocked;
	
end architecture behave;