library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CounterH is
	generic(
		TCO : time := 10 ns;		-- Verzögerungszeit durch ein DFF (Clock to Output)
		TD	 : time :=  7 ns		-- Kombinatorische Verzögerung (Delay) durch LUT/Wire
	);
	port(
		Reset 	: in std_logic; -- Asynchroner Reset
		Clk 		: in std_logic; -- Takt, rising edge
		Clear 	: in std_logic; -- Q auf 0
		Load 		: in std_logic; -- Übernehmen der Daten an D in den Zähler Q
		En 		: in std_logic; -- Zählfreigabe
		Up_nDown : in std_logic; -- Zählrichtung
		D0 		: in std_logic_vector(3 downto 0); 	-- Dateneingang
		D1			: in std_logic_vector(3 downto 0); 	-- Dateneingang
		Q0 		: out std_logic_vector(3 downto 0); -- Zähler Datenausgang
		Q1			: out std_logic_vector(3 downto 0); -- Zähler Datenausgang
		Cas 		: out std_logic -- Kaskadierungsausgang
	);
end entity CounterH;

architecture behave of CounterH is
	signal Q0_int			: std_logic_vector(3 downto 0);
	signal Q0_TCO 			: std_logic_vector(3 downto 0); -- Vermeidung von Q0 als Buffer
	signal Cas0_int		: std_logic;
	signal Q0_int_max		: std_logic_vector(3 downto 0);
	constant Q0_int_min	: std_logic_vector(3 downto 0) := (others => '0');
	
	
	signal Q1_int			: std_logic_vector(3 downto 0);
	signal Q1_TCO			: std_logic_vector(3 downto 0); -- Vermeidung von Q1 als Buffer
	signal Cas1_int		: std_logic := '0';
	constant Q1_int_max	: std_logic_vector(3 downto 0) := x"2";
	constant Q1_int_min	: std_logic_vector(3 downto 0) := (others => '0');
begin
	-- Einer-Stellen der Stunden
	Q0 <= Q0_TCO;
	Q0_TCO <= std_logic_vector(Q0_int) after TCO;
	--Cas <= Cas_int after TD;
	
	-- Paralleler Prozess um Kaskadiersignalverzögerung um einen Takt zu vermeiden
	Cas0_int <= '1' after TD when (En = '1' and (((Q0_TCO = Q0_int_max) and (Up_nDown = '1')) or ((Q0_TCO = Q0_int_min) and (Up_nDown = '0')))) else
				   '0' after TD;
	
	clocked : process(Clk, Reset)
	begin
	
		if Reset = '1' then					-- Asynchroner Teil
			Q0_int <= (others => '0');
		
		elsif rising_edge(Clk) then		-- Synchroner Teil (Clk)
	
			if Clear = '1' then				-- Synchroner Reset
				Q0_int <= (others => '0');
			elsif Load = '1' then			-- Dateneingang D laden
				if D0 > Q0_int_max then
					Q0_int <= Q0_int_max;
				else
					Q0_int <= D0;
				end if;
				
			elsif En = '1' then
				if Up_nDown = '1' then		-- Hochzählen
					if Q0_int < Q0_int_max then
						Q0_int <= std_logic_vector(unsigned(Q0_int) + 1);
					else
						Q0_int <= Q0_int_min;
					end if;
				elsif Up_nDown = '0' then 	-- Runterzählen
					if Q0_int > Q0_int_min then
						Q0_int <= std_logic_vector(unsigned(Q0_int) - 1);
					else
						Q0_int <= Q0_int_max;
					end if;
				end if;
			end if;
		end if;
		
	end process clocked;
	
	-- Zehner-Stellen der Stunden
	Q1 <= Q1_TCO;
	Q1_TCO <= std_logic_vector(Q1_int) after TCO;
	
	Cas1_int <= '1' when (Cas0_int = '1' and (((Q1_TCO = Q1_int_max) and (Up_nDown = '1')) or ((Q1_TCO = Q1_int_min) and (Up_nDown = '0')))) else
					'0';
					
	Cas <= Cas1_int after TD;
	
	clocked1 : process(Clk, Reset)
	begin
	
		if Reset = '1' then
			Q1_int <= (others => '0');
			
		elsif rising_edge(Clk) then
			if Clear = '1' then
				Q1_int <= (others => '0');
			elsif Load = '1' then
				if D1 > Q1_int_max then
					Q1_int <= Q1_int_max;
				else
					Q1_int <= D1;
				end if;
				
			elsif Cas0_int = '1' then
				if Up_nDown = '1' then		-- Hochzählen
					if Q1_int < Q1_int_max then
						Q1_int <= std_logic_vector(unsigned(Q1_int) + 1);
					else
						Q1_int <= Q1_int_min;
					end if;
				elsif Up_nDown = '0' then 	-- Runterzählen
					if Q1_int > Q1_int_min then
						Q1_int <= std_logic_vector(unsigned(Q1_int) - 1);
					else
						Q1_int <= Q1_int_max;
					end if;
				end if;
			end if;
		end if;
		
	end process clocked1;
	
	-- Max. Zählwert abhängig von Zählerwert
	Q0_int_max <= x"3" when Q1_int >= x"2" else
					  x"9";

end architecture behave;