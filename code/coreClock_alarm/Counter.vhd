library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Counter is
	generic(
		TCO : time := 10 ns;	 -- Verzögerungszeit durch ein DFF (Clock to Output)
		TD	 : time :=  7 ns;	 -- Kombinatorische Verzögerung (Delay) durch LUT/Wire
		Max : std_logic_vector(3 downto 0) := x"9" -- Maximalwert des Zählers, vor einem Überlauf auf die nächste Stelle
	);
	port(
		Reset 	: in std_logic; -- Asynchroner Reset
		Clk 		: in std_logic; -- Takt, rising edge
		Clear 	: in std_logic; -- Q auf 0
		Load 		: in std_logic; -- Übernehmen der Daten an D in den Zähler Q
		En 		: in std_logic; -- Zählfreigabe
		Up_nDown : in std_logic; -- Zählrichtung
		D 			: in std_logic_vector(3 downto 0); 	-- Dateneingang
		Q 			: out std_logic_vector(3 downto 0); -- Zähler Datenausgang
		Cas 		: out std_logic -- Kaskadierungsausgang
	);
end entity Counter;

architecture behave of Counter is
	
	signal Q_int 	: std_logic_vector(3 downto 0);
	signal Q_TCO 	: std_logic_vector(3 downto 0); -- Vermeidung von Q als Buffer
	signal Cas_int : std_logic;
	
	constant Q_int_max : std_logic_vector(3 downto 0) := Max;
	constant Q_int_min : std_logic_vector(3 downto 0) := (others => '0');
	
begin
	Q <= Q_TCO;
	Q_TCO <= std_logic_vector(Q_int) after TCO;
	Cas <= Cas_int after TD;
	
	-- Paralleler Prozess um Kaskadiersignalverzögerung um einen Takt zu vermeiden
	Cas_int <= '1' when (En = '1' and (((Q_TCO = Q_int_max) and (Up_nDown = '1')) or ((Q_TCO = Q_int_min) and (Up_nDown = '0')))) else
				  '0';
	
	clocked : process(Clk, Reset)
	begin
	
		if Reset = '1' then					-- Asynchroner Teil
			Q_int <= (others => '0');
		
		elsif rising_edge(Clk) then		-- Synchroner Teil (Clk)
	
			if Clear = '1' then				-- Synchroner Reset
				Q_int <= (others => '0');
			elsif Load = '1' then			-- Dateneingang D laden
				if D > Q_int_max then
					Q_int <= Q_int_max;
				else
					Q_int <= D;
				end if;
				
			elsif En = '1' then
				if Up_nDown = '1' then		-- Hochzählen
					if Q_int < Q_int_max then
						Q_int <= std_logic_vector(unsigned(Q_int) + 1);
					else
						Q_int <= Q_int_min;
					end if;
				elsif Up_nDown = '0' then 	-- Runterzählen
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