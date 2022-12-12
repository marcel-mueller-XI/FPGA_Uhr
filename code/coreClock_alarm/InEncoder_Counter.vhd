library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;	

entity InEncoder_Counter is
	port(
		Reset 	: in std_logic; -- Asynchroner Reset
		Clk 		: in std_logic; -- Takt, rising edge
		Clear 	: in std_logic; -- Q auf 0
		Load 		: in std_logic; -- Übernehmen der Daten an D in den Zähler Q
		En 		: in std_logic; -- Zählfreigabe
		Up_nDown : in std_logic; -- Zählrichtung
		Min_Hour : in std_logic; -- Minutenzählung = 0/ Stundenzählung = 1
		
		D_min_units 	: in std_logic_vector(3 downto 0);
		D_min_tens 		: in std_logic_vector(3 downto 0);
		D_hour_units 	: in std_logic_vector(3 downto 0);
		D_hour_tens 	: in std_logic_vector(3 downto 0);
		
		Q_min_units 	: out std_logic_vector(3 downto 0);
		Q_min_tens 		: out std_logic_vector(3 downto 0);
		Q_hour_units 	: buffer std_logic_vector(3 downto 0);
		Q_hour_tens 	: buffer std_logic_vector(3 downto 0);
		
		Cas		: out std_logic -- Kaskadierungsausgang
	);
end entity InEncoder_Counter;

architecture behave of InEncoder_Counter is

	signal Cas_Min_int, Cas_Hour_int : std_logic;
	signal En_Min, En_Hour : std_logic;
	signal Clear_Hour : std_logic;
	
begin
		--! Kombinatorik für den korrekten Überlauf des Stundenzählers im 24h-Format
	Clear_Hour <= '1' when (Q_hour_tens = x"2" and Q_hour_units = x"3" and En = '1' and Min_Hour = '1') or Clear = '1' else
				'0';
				
	En_Min <= '1' when Min_Hour = '0' and En = '1' else
				 '0';
				 
	En_Hour <= '1' when Min_Hour = '1' and En = '1' else
				  '0';
					
	counter_min_units : entity work.Counter
		generic map( 
			TCO => 10 ns, 
			TD  =>  7 ns,
			Max => x"9"
		)
		port map(
			Reset 		=> Reset,
			Clk  			=> Clk,
			Clear 		=> Clear,
			Load 			=> Load,
			En 			=> En_Min,
			Up_nDown 	=> Up_nDown,
			D 				=> D_min_units, 
			Q	 			=> Q_min_units,
			Cas			=> Cas_Min_int
		);
	
	counter_min_tens : entity work.Counter
		generic map(
			TCO => 10 ns,						 
			TD  =>  7 ns,
			Max => x"5"
		)
		port map(
			Reset 		=> Reset,
			Clk  			=> Clk,
			Clear 		=> Clear,
			Load 			=> Load,
			En 			=> Cas_Min_int,
			Up_nDown 	=> Up_nDown,
			D 				=> D_min_tens, -- (3 downto 0),
			Q	 			=> Q_min_tens, -- (3 downto 0),
			Cas			=> Cas -- => open (nicht angeschlossen bei Output möglich)
		);
		
	counter_hour_units : entity work.Counter
		generic map(
			TCO => 10 ns,						 
			TD  =>  7 ns,
			Max => x"9"
		)
		port map(
			Reset 		=> Reset,
			Clk  			=> Clk,
			Clear 		=> Clear_Hour,
			Load 			=> Load,
			En 			=> En_Hour,
			Up_nDown 	=> Up_nDown,
			D 				=> D_hour_units, -- (3 downto 0),
			Q	 			=> Q_hour_units, -- (3 downto 0),
			Cas			=> Cas_Hour_int 
		);
		
	counter_hour_tens : entity work.Counter
		generic map(
			TCO => 10 ns,						 
			TD  =>  7 ns,
			Max => x"2"
		)
		port map(
			Reset 		=> Reset,
			Clk  			=> Clk,
			Clear 		=> Clear_Hour,
			Load 			=> Load,
			En 			=> Cas_Hour_int,
			Up_nDown 	=> Up_nDown,
			D 				=> D_hour_tens, -- (3 downto 0),
			Q	 			=> Q_hour_tens, -- (3 downto 0),
			Cas			=> Cas -- => open (nicht angeschlossen bei Output möglich)
		);
end architecture behave;