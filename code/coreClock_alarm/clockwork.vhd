library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clockwork is
	generic(
		constant Max50 : integer range 0 to 50_000_000 := 50_000_000;	-- Für Sekundensignal mit f = 1 Hz
		constant Max25 : integer range 0 to 25_000_000 := 25_000_000	-- Für Rechtecksignal mit f = 1 Hz
	);
	port(
		signal Reset	: in std_logic;
		signal Clk_50	: in std_logic;									-- 50 MHz Eingangssignal
		signal Clk_sec : out std_logic;									-- Impulssignal, Impuls jede Sekunde
		signal square_wav : out std_logic;								-- Rechtecksignal, Periode = 1 Sekunde
		
		signal D_sec_units	: in std_logic_vector(3 downto 0);	-- Data IN Sekunden	Einer
		signal D_sec_tens		: in std_logic_vector(3 downto 0);	-- Data IN Sekunden	Zehner
		signal D_min_units	: in std_logic_vector(3 downto 0);	-- Data IN Minuten	Einer
		signal D_min_tens		: in std_logic_vector(3 downto 0);	-- Data IN Minuten	Zehner
		signal D_hour_units	: in std_logic_vector(3 downto 0);	-- Data IN Stunden	Einer
		signal D_hour_tens	: in std_logic_vector(3 downto 0);	-- Data IN Stunden	Zehner
		
		signal En : in std_logic; 											-- Enable für Uhr-Start
		signal Clear : in std_logic;										-- Clear
		
		signal Q_sec_units	: out std_logic_vector(3 downto 0);	-- Data OUT Sekunden	Einer
		signal Q_sec_tens		: out std_logic_vector(3 downto 0);	-- Data OUT Sekunden	Zehner
		signal Q_min_units	: out std_logic_vector(3 downto 0);	-- Data OUT Minuten	Einer
		signal Q_min_tens		: out std_logic_vector(3 downto 0);	-- Data OUT Minuten	Zehner
		signal Q_hour_units	: out std_logic_vector(3 downto 0);	-- Data OUT Stunden	Einer
		signal Q_hour_tens	: out std_logic_vector(3 downto 0);	-- Data OUT Stunden	Zehner
		
		signal Load_sec : in std_logic;
		signal Load_min : in std_logic;
		signal Load_hour: in std_logic;
		
		signal LED_out : out std_logic;					-- entspricht Rechtecksignal, abhängig von Eingängen
		
		signal En_alarm_in			: in std_logic;	-- Aktivierung des Alarms
		signal En_alarm_out			: out std_logic;	-- Ausgangssignal des Alarms
		signal D_alarm_sec_units	: in std_logic_vector (3 downto 0);	-- Alarm Data IN Sekunden	Einer
		signal D_alarm_sec_tens		: in std_logic_vector (3 downto 0);	-- Alarm Data IN Sekunden	Zehner
		signal D_alarm_min_units	: in std_logic_vector (3 downto 0);	-- Alarm Data IN Minuten	Einer
		signal D_alarm_min_tens		: in std_logic_vector (3 downto 0);	-- Alarm Data IN Minuten	Zehner
		signal D_alarm_hour_units	: in std_logic_vector (3 downto 0);	-- Alarm Data IN Stunden	Einer
		signal D_alarm_hour_tens	: in std_logic_vector (3 downto 0)	-- Alarm Data IN Stunden	Zehner
		
	);
end entity clockwork;

architecture behave of clockwork is
	signal square_wav_int : std_logic; 		-- für LED-Ausgangssignal oder für interne Verwendung
	signal Clk_sec_int : std_logic := '0';	-- Impulssignal für interne Verwendung
	
	signal Cas_sec_sec : std_logic;	-- sec (units)		-> sec (tens)
	signal Cas_sec_min : std_logic;	-- sec (tens)		-> min (units)
	signal Cas_min_min : std_logic;	-- min (units)		-> min (tens)
	signal Cas_min_h : std_logic;		-- min (tens)		-> hour (units)
	signal Cas_h_h : std_logic;		-- hour (units)	-> hour (tens)
	
	signal Q_sec_units_int	: std_logic_vector(3 downto 0);
	signal Q_sec_tens_int	: std_logic_vector(3 downto 0);
	signal Q_min_units_int	: std_logic_vector(3 downto 0);
	signal Q_min_tens_int	: std_logic_vector(3 downto 0);
	signal Q_hour_units_int	: std_logic_vector(3 downto 0);
	signal Q_hour_tens_int	: std_logic_vector(3 downto 0);
	
begin
	Q_sec_units		<= Q_sec_units_int;
	Q_sec_tens		<= Q_sec_tens_int;
	Q_min_units		<= Q_min_units_int;
	Q_min_tens		<= Q_min_tens_int;
	Q_hour_units	<= Q_hour_units_int;
	Q_hour_tens		<= Q_hour_tens_int;

	square_wav <= square_wav_int;		-- Rechtecksignal-Schnittstelle für andere Gruppen
	Clk_sec <= Clk_sec_int;				-- Sekundentakt-Schnittstelle für andere
	
	-- LED-Ausgangssignal
	LED_out <= '1' when Reset = '0' and En = '1' and square_wav_int = '1' else
				  '0';
	
	-- Alarm-Ausgangssignal
	En_alarm_out <= '1' when En_alarm_in = '1' and Q_hour_tens_int = D_alarm_hour_tens and Q_hour_units_int = D_alarm_hour_units and Q_min_tens_int = D_alarm_min_tens and Q_min_units_int = D_alarm_min_units and Q_sec_tens_int = D_alarm_sec_tens and Q_sec_units_int = D_alarm_sec_units else
						 '0';
	
	-- Instanziierung Sekundentakt
	generated_sec : entity work.CounterSec(behave)
		generic map(
			Max50 => Max50,
			Max25 => Max25
		)
		port map(
			Reset => Reset,
			Clk_50 => Clk_50,
			Clk_sec => Clk_sec_int,
			square_wav => square_wav_int
		);
			
	-- Instanziierung Counter
	
	-- Sekunden: Einer-Stelle
	counter_sec_units : entity work.Counter(behave)
		generic map(
			TCO	=> 10 ns,
			TD		=>  7 ns,
			Max	=> x"9"
		)
		port map(
			Reset 	=> Reset,
			Clk		=> Clk_sec_int,
			Clear		=> Clear,
			Load		=> Load_sec,
			En			=> En,
			Up_nDown	=> '1',
			D			=> D_sec_units,
			Q			=> Q_sec_units_int,
			Cas		=> Cas_sec_sec
		);
	
	-- Sekunden: Zehner-Stelle
	counter_sec_tens	: entity work.Counter(behave)
		generic map(
			TCO	=> 10 ns,
			TD		=>  7 ns,
			Max	=> x"5"
		)
		port map(
			Reset		=> Reset,
			Clk		=> Clk_sec_int,
			Clear		=> Clear,
			Load		=> Load_sec,
			En			=> Cas_sec_sec,
			Up_nDown	=> '1',
			D			=> D_sec_tens,
			Q			=> Q_sec_tens_int,
			Cas		=> Cas_sec_min
		);
	
	-- Minuten: Einer-Stelle
	counter_min_units : entity work.Counter(behave)
		generic map(
			TCO		=> 10 ns,
			TD			=>  7 ns,
			Max		=> x"9"
		)
		port map(
			Reset		=> Reset,
			Clk		=> Clk_sec_int,
			Clear		=> Clear,
			Load		=> Load_min,
			En			=> Cas_sec_min,
			Up_nDown	=> '1',
			D			=> D_min_units,
			Q			=> Q_min_units_int,
			Cas		=> Cas_min_min
		);
	
	-- Minuten: Zehner-Stelle
	counter_min_tens : entity work.Counter(behave)
		generic map(
			TCO		=> 10 ns,
			TD			=>  7 ns,
			Max		=> x"5"
		)
		port map(
			Reset		=> Reset,
			Clk		=> Clk_sec_int,
			Clear		=> Clear,
			Load		=> Load_min,
			En			=> Cas_min_min,
			Up_nDown	=> '1',
			D			=> D_min_tens,
			Q			=> Q_min_tens_int,
			Cas		=> Cas_min_h
		);
		
		-- Instanziierung des speziellen Stundenzähler (Einer- und Zehnerstelle)
		counter_hour : entity work.CounterH
			generic map(
				TCO		=> 10 ns,
				TD			=>  7 ns
			)
			port map(
				Reset		=> Reset,
				Clk		=> Clk_sec_int,
				Clear		=> Clear,
				Load		=> Load_hour,
				En			=> Cas_min_h,
				Up_nDown	=> '1',
				D0			=> D_hour_units,
				D1			=> D_hour_tens,
				Q0			=> Q_hour_units_int,
				Q1			=> Q_hour_tens_int,
				Cas		=> open
			);
		
		--alarm_process : process(Clk_sec_int, Q_hour_tens_int, Q_hour_units_int, Q_min_tens_int, Q_min_units_int, Q_sec_tens_int, Q_sec_units_int) is
		--begin
			--En_Alarm_out <= '0';
			--if En_Alarm_in = '1' then	-- wenn Alarm aktiviert ist
			
				--if (Q_hour_tens_int = D_alarm_hour_tens and Q_hour_units_int = D_alarm_hour_units and Q_min_tens_int = D_alarm_min_tens and Q_min_units_int = D_alarm_min_units and Q_sec_tens_int = D_alarm_sec_tens and Q_sec_units_int = D_alarm_sec_units) then		-- Stunden und Minuten vergleichen
					--En_Alarm_out <= '1';	-- wenn gleich -> Alarm
				--end if;
			--end if;
		--end process alarm_process;
end architecture behave;