library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Clockwork is
	generic(
		constant Max50 : integer range 0 to 50_000_000 := 50_000_000;	-----------------------------------
		constant Max25 : integer range 0 to 25_000_000 := 25_000_000	-----------------------------------
	);
	port(
		signal Clk_50			: in std_logic;							--! 50 MHz Taktsignal
		
		signal Reset			: in std_logic;	-----------------------------------------------------------------
		signal Load				: in std_logic;	-----------------------------------------------------------------
		signal En				: in std_logic;	-----------------------------------------------------------------
		signal Clear 			: in std_logic;   -----------------------------------------------------------------
	
		signal D_sec_units	: in std_logic_vector(3 downto 0);	--! Dateneingang Uhr Sekunden Einer
		signal D_sec_tens		: in std_logic_vector(3 downto 0);	--! Dateneingang Uhr Sekunden Zehner
		signal D_min_units	: in std_logic_vector(3 downto 0);	--! Dateneingang Uhr Minuten Einer
		signal D_min_tens		: in std_logic_vector(3 downto 0);	--! Dateneingang Uhr Minuten Zehner
		signal D_hour_units	: in std_logic_vector(3 downto 0);	--! Dateneingang Uhr Stunden Einer
		signal D_hour_tens	: in std_logic_vector(3 downto 0);	--! Dateneingang Uhr Stunden Zehner
		
		signal En_alarm_in			: in std_logic;							--! Aktivierung Alarm
		
		signal D_alarm_sec_units	: in std_logic_vector (3 downto 0);	--! Dateneingang Alarm Sekunden Einer
		signal D_alarm_sec_tens		: in std_logic_vector (3 downto 0);	--! Dateneingang Alarm Sekunden Zehner
		signal D_alarm_min_units	: in std_logic_vector (3 downto 0);	--! Dateneingang Alarm Minuten Einer
		signal D_alarm_min_tens		: in std_logic_vector (3 downto 0);	--! Dateneingang Alarm Minuten Zehner
		signal D_alarm_hour_units	: in std_logic_vector (3 downto 0);	--! Dateneingang Alarm Stunden Einer
		signal D_alarm_hour_tens	: in std_logic_vector (3 downto 0);	--! Dateneingang Alarm Stunden Zehner
		
		signal En_alarm_out			: out std_logic;							--! Alarmsignal
		
		
		signal Q_sec_units	: buffer std_logic_vector(3 downto 0);	--! Datenausgang Uhr Sekunden Einer
		signal Q_sec_tens		: buffer std_logic_vector(3 downto 0);	--! Datenausgang Uhr Sekunden Zehner
		signal Q_min_units	: buffer std_logic_vector(3 downto 0);	--! Datenausgang Uhr Minuten Einer
		signal Q_min_tens		: buffer std_logic_vector(3 downto 0);	--! Datenausgang Uhr Minuten Zehner
		signal Q_hour_units	: buffer std_logic_vector(3 downto 0);	--! Datenausgang Uhr Stunden Einer
		signal Q_hour_tens	: buffer std_logic_vector(3 downto 0);	--! Datenausgang Uhr Stunden Zehner
		
		signal Clk_sec			: out std_logic;-----------------------------------------------------------
		signal square_wav		: out std_logic;-----------------------------------------------------------
		
		signal LED_out			: out std_logic							--! Ansteurung der LED, entspricht Rechtecksignal
	);
end entity Clockwork;

architecture behave of Clockwork is
		--signal Reset_int	: std_logic := '0';				-- Asynchroner Reset fÃ¼r interne Verwendung, Einsatz am Start??
		--signal Clear_int	: std_logic := '0';
		
		signal Clear_24			: std_logic := '0';		--! Korrekter Ãœberlauf des StundenzÃ¤hler (24h-Format)
		
		signal Clk_sec_int		: std_logic := '0';		--! Impulssignal fÃ¼r interne Verwendung
		signal square_wav_int	: std_logic := '0';		--! Rechtecksignal fÃ¼r interne Verwendung
		
		signal Cas_sec_sec		: std_logic;				--! Kaskadierungssignal Sekunde (Einer) auf Sekunde (Zehner)
		signal Cas_sec_min		: std_logic;				--! Kaskadierungssignal Sekunde (Zehner) auf Minute (Einer)
		signal Cas_min_min		: std_logic;				--! Kaskadierungssignal Minute (Einer) auf Minute (Zehner)
		signal Cas_min_hour		: std_logic;				--! Kaskadierungssignal Minute (Zehner) auf Stunde (Einer)
		signal Cas_hour_hour		: std_logic;				--! Kaskadierungssignal Stunde (Einer) auf Stunde (Zehner)
		
		signal Q_sec_units_int	: std_logic_vector(3 downto 0);	--! Datenausgang fÃ¼r interne Verwendung
		signal Q_sec_tens_int	: std_logic_vector(3 downto 0);	--! Datenausgang fÃ¼r interne Verwendung
		signal Q_min_units_int	: std_logic_vector(3 downto 0);	--! Datenausgang fÃ¼r interne Verwendung
		signal Q_min_tens_int	: std_logic_vector(3 downto 0);	--! Datenausgang fÃ¼r interne Verwendung
		signal Q_hour_units_int	: std_logic_vector(3 downto 0);	--! Datenausgang fÃ¼r interne Verwendung
		signal Q_hour_tens_int	: std_logic_vector(3 downto 0);	--! Datenausgang fÃ¼r interne Verwendung
		
		signal Load_next	   : std_logic := '0';		-- Loadvorgang ausgefÃ¼hrt
		signal Load_intern	: std_logic := '0';		-- interne Loadvariable, welche an Instanzen weitergegeben wird
		
begin
	--! Zuweisung der internen DatenausgÃ¤nge auf die AusgÃ¤nge
	square_wav <= square_wav_int;
	Clk_sec <= Clk_sec_int;
	
	Q_sec_units		<= Q_sec_units_int;
	Q_sec_tens		<= Q_sec_tens_int;
	Q_min_units		<= Q_min_units_int;
	Q_min_tens		<= Q_min_tens_int;
	Q_hour_units	<= Q_hour_units_int;
	Q_hour_tens		<= Q_hour_tens_int;
	
	
	
	
	--! Kombinatorik Alarm-Ausgangssignal ------------------------------------Uhrzeit-modus miteinflieÃŸen lassen
	En_alarm_out <= '1' when En_alarm_in = '1' and Q_hour_tens_int = D_alarm_hour_tens and Q_hour_units_int = D_alarm_hour_units and Q_min_tens_int = D_alarm_min_tens and Q_min_units_int = D_alarm_min_units and Q_sec_tens_int = D_alarm_sec_tens and Q_sec_units_int = D_alarm_sec_units else
						 '0';
	
	
	
	
	--! Kombinatorik LED-Ausgangssignal ------------------------------------Uhrzeit-modus miteinflieÃŸen lassen
	LED_out <= '1' when Reset = '0' and En = '1' and square_wav_int = '1' else
				  '0';
	
	-- Process fÃ¼r Loadeingang, Taktsynchron
	-- Load wird einmal dauerhaft gesetzt, hierfÃ¼r wird eine interne Variable so lange gesetzt, bis die Werte Ã¼bernommen wurden
	LoadProcess : process (Clk_50)
	Begin
		if (rising_edge(Clk_50)) then	
			if (Load = '1') then			-- Wenn Laden gesetzt ist
												-- Solange die einzulesenden Werte gleich den auszugebenden Werte sind und Load_next nicht gesetzt ist (prÃ¼ft ab, ob Load bereits gesetzt wurde)
				if (D_sec_units /= Q_sec_units and D_sec_tens /= Q_sec_tens  and D_min_units /= Q_min_units  and D_min_tens /= Q_min_tens and D_hour_units /= Q_hour_units and D_hour_tens /= Q_hour_tens and Load_next = '0' ) then
					Load_intern <= '1';	-- Loadvariable, welche an die Instanzen Ã¼bergeben wird
					Load_next <= '1';		-- Loadvorgang wurde ausgefÃ¼hrt, abspeichern
				else
					Load_intern <= '0';	-- Loadvorgang stoppen
				end if;
			elsif (Load = '0') then		-- Wenn Laden nicht aktiv ist
				Load_next <= '0';			-- Interner Loadvorgang resetten auf Ausgangszustand
			end if;
		end if;
	end process;
	
	
	--! Instanziierung des CounterSec
	gen_seconds : entity work.CounterSec
		generic map(
			Max50			=> Max50,
			Max25			=> Max25
		)
		port map(
			Reset			=> Reset,-----------------
			Clk_50		=> Clk_50,
			Clk_sec		=> Clk_sec_int,
			square_wav	=> square_wav_int
		);
	
	--! Instanziierung des Counters fÃ¼r die Sekunden (Einer)
	counter_sec_units : entity work.Counter(behave)
		generic map(
			TCO	=> 10 ns,
			TD		=>  7 ns,
			Max	=> x"9"
		)
		port map(
			Reset			=> Reset,-----------------
			Clk			=> Clk_sec_int,
			Clear			=> Clear,-----------------
			Load			=>	Load_intern,
			En				=> En,
			Up_nDown		=> '1',
			D				=> D_sec_units,
			Q				=> Q_sec_units_int,
			Cas			=> Cas_sec_sec
		);
	
	--! Instanziierung des Counters fÃ¼r die Sekunden (Zehner)
	counter_sec_tens : entity work.Counter(behave)
		generic map(
			TCO	=> 10 ns,
			TD		=>  7 ns,
			Max	=> x"5"
		)
		port map(
			Reset			=> Reset,-----------------
			Clk			=> Clk_sec_int,
			Clear			=> Clear,-----------------
			Load			=>	Load_intern,
			En				=> Cas_sec_sec,
			Up_nDown		=> '1',
			D				=> D_sec_tens,
			Q				=> Q_sec_tens_int,
			Cas			=> Cas_sec_min
		);
	
	--! Instanziierung des Counters fÃ¼r die Minuten (Einer)
	counter_min_units : entity work.Counter(behave)
		generic map(
			TCO	=> 10 ns,
			TD		=>  7 ns,
			Max	=> x"9"
		)
		port map(
			Reset			=> Reset,-----------------
			Clk			=> Clk_sec_int,
			Clear			=> Clear,-----------------
			Load			=>	Load_intern,
			En				=> Cas_sec_min,
			Up_nDown		=> '1',
			D				=> D_min_units,
			Q				=> Q_min_units_int,
			Cas			=> Cas_min_min
		);
	
	--! Instanziierung des Counters fÃ¼r die Minuten (Zehner)
	counter_min_tens : entity work.Counter(behave)
		generic map(
			TCO	=> 10 ns,
			TD		=>  7 ns,
			Max	=> x"5"
		)
		port map(
			Reset			=> Reset,-----------------
			Clk			=> Clk_sec_int,
			Clear			=> Clear,-----------------
			Load			=>	Load_intern,
			En				=> Cas_min_min,
			Up_nDown		=> '1',
			D				=> D_min_tens,
			Q				=> Q_min_tens_int,
			Cas			=> Cas_min_hour
		);
		
	--! Kombinatorik fÃ¼r den korrekten Ãœberlauf des StundenzÃ¤hlers im 24h-Format
	Clear_24 <= '1' when (Q_hour_tens_int = x"2" and Q_hour_units_int = x"3" and Cas_min_hour = '1') or Clear = '1' else
					'0';
	
	--! Instanziierung des Counters fÃ¼r die Stunden (Einer)
	counter_hour_units : entity work.Counter(behave)
		generic map(
			TCO	=> 10 ns,
			TD		=>  7 ns,
			Max	=> x"9"
		)
		port map(
			Reset			=> Reset,-----------------
			Clk			=> Clk_sec_int,
			Clear			=> Clear_24,
			Load			=>	Load_intern,
			En				=> Cas_min_hour,
			Up_nDown		=> '1',
			D				=> D_hour_units,
			Q				=> Q_hour_units_int,
			Cas			=> Cas_hour_hour
		);
	
	--! Instanziierung des Counters fÃ¼r die Stunden (Zehner)
	counter_hour_tens : entity work.Counter(behave)
		generic map(
			TCO	=> 10 ns,
			TD		=>  7 ns,
			Max	=> x"2"
		)
		port map(
			Reset			=> Reset,-----------------
			Clk			=> Clk_sec_int,
			Clear			=> Clear_24,
			Load			=>	Load_intern,
			En				=> Cas_hour_hour,
			Up_nDown		=> '1',
			D				=> D_hour_tens,
			Q				=> Q_hour_tens_int,
			Cas			=> open
		);
	
end architecture behave;