--! @file	Clockwork.vhd
--! @brief	Uhrwerk (Uhrzeit- und Einstellmodus). Einstellungen über Inkrementalgebers
--! @author	Sebastian Schmaus

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Clockwork is
	generic(
		constant Max50 : integer range 0 to 50_000_000 := 50_000_000;		--! Maximaler Zählwert für die Generierung des Impulssignals aus dem 50 MHz-Takt
		constant Max25 : integer range 0 to 25_000_000 := 25_000_000		--! Maximaler Zählwert für die Generierung des Rechtecksignals (Duty Cycle 50 %) aus dem 50 MHz-Takt
	);
	port(
		signal Clk_50				: in std_logic;		--! 50 MHz-Taktsignal des DE0-Boards
		
		signal Reset				: in std_logic;		--! Asynchroner Reset der Zähler (Uhrzeit), des Sekundentakts und des Inkrementaldecoders
		signal Clear				: in std_logic;		--! Synchroner Reset der Zähler (Uhrzeit)
		
		signal Clk_sec				: out std_logic;		--! Impulssignal mit einem Impuls pro Sekunde bei Max50 = 50_000_000
		signal square_wav			: out std_logic;		--! Rechtecksignal (Duty Cycle 50 %) mit Periodendauer = 1 s bei Max25 = 25_000_000
		
		signal Show_nSet			: in std_logic;		--! Steuersignal: '1': Uhrzeitmodus, '0': Einstellmodus, Signal aus der State Machine des Top-Levels -> Time_Display von Hannes
		signal Set_Clock_nAlarm	: in std_logic;		--! Steuersignal: '1': Uhrzeit einstellen, '0': Alarmzeit einstellen, Signal aus der State Machine des Top-Levels -> Set_Time von Hannes
		signal Set_Hour_nMin		: in std_logic;		--! Steuersignal: '1': Stunden einstellen, '0': Minuten einstellen, Signal aus der State Machine des Top-Levels -> Set_Std von Hannes
	
		signal En_alarm_in		: in std_logic;		--! Aktivierung des Alarms
		signal En_alarm_out		: out std_logic;		--! Alarmausgangssignal
		
		signal Q_sec_units		: out std_logic_vector(3 downto 0);		--! Datenausgang der Uhr: Sekunden (Einer)
		signal Q_sec_tens			: out std_logic_vector(3 downto 0);		--! Datenausgang der Uhr: Sekunden (Zehner)
		signal Q_min_units		: out std_logic_vector(3 downto 0);		--! Datenausgang der Uhr: Minuten (Einer)
		signal Q_min_tens			: out std_logic_vector(3 downto 0);		--! Datenausgang der Uhr: Minuten (Zehner)
		signal Q_hour_units		: out std_logic_vector(3 downto 0);		--! Datenausgang der Uhr: Stunden (Einer)
		signal Q_hour_tens		: out std_logic_vector(3 downto 0);		--! Datenausgang der Uhr: Stunden (Zehner)
		
		signal Q_al_min_units	: out std_logic_vector(3 downto 0);		--! Datenausgang des Alarms: Minuten (Einer)
		signal Q_al_min_tens		: out std_logic_vector(3 downto 0);		--! Datenausgang des Alarms: Minuten (Zehner)
		signal Q_al_hour_units	: out std_logic_vector(3 downto 0);		--! Datenausgang des Alarms: Stunden (Einer)
		signal Q_al_hour_tens	: out std_logic_vector(3 downto 0);		--! Datenausgang des Alarms: Stunden (Zehner)
		
		signal LED_out				: out std_logic;		--! Ansteurung der LED entsprechend dem Rechtecksignal im Uhrzeitmodus
		
		signal A_enc				: in std_logic;		--! Spur A des Inkrementalgebers
		signal B_enc				: in std_logic			--! Spur B des Inkrementalgebers
	);
end entity Clockwork;

architecture behave of Clockwork is

		signal Load_sec			: std_logic := '0';		--! Load-Signal für das Setzen der Sekundenzähler auf Null im Einstellmodus
		
		signal Clear_24			: std_logic := '0';		--! Clear-Signal für das Rücksetzen des Stundenzählers (Überlauf des Stundenzählers, 24h-Format)
		signal Load_24				: std_logic := '0';		--! Load-Signal für das Setzen des Stundenzählers auf den maximalen Wert (Unterlauf des Stundenzählers)
		
		signal Clear_al_24		: std_logic := '0';		--! Clear-Signal für das Rücksetzen des Alarm-Stundenzählers (Überlauf des Stundenzählers, 24h-Format)
		signal Load_al_24			: std_logic := '0';		--! Load-Signal für das Setzen des Alarm-Stundenzählers auf den maximalen Wert (Unterlauf des Stundenzählers)
		
		signal Clk_sec_int		: std_logic := '0';		--! Impulssignal für interne Verwendung
		signal square_wav_int	: std_logic := '0';		--! Rechtecksignal für interne Verwendung
		
		signal Cas_sec_sec		: std_logic;				--! Kaskadierungssignal Sekunde (Einer) auf Sekunde (Zehner)
		signal Cas_sec_min		: std_logic;				--! Kaskadierungssignal Sekunde (Zehner) auf Minute (Einer)
		signal Cas_min_min		: std_logic;				--! Kaskadierungssignal Minute (Einer) auf Minute (Zehner)
		signal Cas_min_hour		: std_logic;				--! Kaskadierungssignal Minute (Zehner) auf Stunde (Einer)
		signal Cas_hour_hour		: std_logic;				--! Kaskadierungssignal Stunde (Einer) auf Stunde (Zehner)
		
		signal Cas_al_min_min	: std_logic;				--! Kaskadierungssignal Alarm Minute (Einer) auf Minuten (Zehner)
		signal Cas_al_hour_hour	: std_logic;				--! Kaskadierungssignal Alarm Stunde (Einer) auf Stunde (Zehner)
		
		signal Q_sec_units_int	: std_logic_vector(3 downto 0);	--! Datenausgang der Uhr für interne Verwendung
		signal Q_sec_tens_int	: std_logic_vector(3 downto 0);	--! Datenausgang der Uhr für interne Verwendung
		signal Q_min_units_int	: std_logic_vector(3 downto 0);	--! Datenausgang der Uhr für interne Verwendung
		signal Q_min_tens_int	: std_logic_vector(3 downto 0);	--! Datenausgang der Uhr für interne Verwendung
		signal Q_hour_units_int	: std_logic_vector(3 downto 0);	--! Datenausgang der Uhr für interne Verwendung
		signal Q_hour_tens_int	: std_logic_vector(3 downto 0);	--! Datenausgang der Uhr für interne Verwendung
		
		signal Q_al_sec_units_int	: std_logic_vector(3 downto 0) := (others => '0');	--! Datenausgang des Alarms für interne Verwendung
		signal Q_al_sec_tens_int	: std_logic_vector(3 downto 0) := (others => '0');	--! Datenausgang des Alarms für interne Verwendung
		signal Q_al_min_units_int	: std_logic_vector(3 downto 0);							--! Datenausgang des Alarms für interne Verwendung
		signal Q_al_min_tens_int	: std_logic_vector(3 downto 0);							--! Datenausgang des Alarms für interne Verwendung
		signal Q_al_hour_units_int	: std_logic_vector(3 downto 0);							--! Datenausgang des Alarms für interne Verwendung
		signal Q_al_hour_tens_int	: std_logic_vector(3 downto 0);							--! Datenausgang des Alarms für interne Verwendung
		
		signal En_enc				: std_logic;	--! Enable-Signal des Inkrementaldecoders, wird je nach Steuersignal auf die Zähler der Uhr oder des Alarms gemultiplext
		signal Up_nDown_enc		: std_logic;	--! Up_nDown-Signal des Inkrementaldecoders, geht direkt auf die Alarm-Zähler und wird je nach Steuersignal auf die Zähler der Uhr gemultiplext
		
		signal En_sec_units	: std_logic;		--! Enable-Signal des Sekunden-Zählers (Einer), im Uhrzeitmodus = Sekundentakt Clk_sec_int
		signal En_sec_tens	: std_logic;		--! Enable-Signal des Sekunden-Zählers (Zehner), im Uhrzeitmodus = Cas_sec_sec
		signal En_min_units	: std_logic;		--! Enable-Signal des Minuten-Zählers (Einer), im Uhrzeitmodus = Cas_sec_min, im Einstellmodus = En_enc
		signal En_min_tens	: std_logic;		--! Enable-Signal des Minuten-Zählers (Zehner) = Cas_min_min
		signal En_hour_units	: std_logic;		--! Enable-Signal des Stunden-Zählers (Einer), im Uhrzeitmodus = Cas_min_hour, im Einstellmodus = En_enc
		signal En_hour_tens	: std_logic;		--! Enable-Signal des Stunden-Zählers (Zehner) = Cas_hour_hour
		
		signal En_al_min_units	: std_logic;	--! Enable-Signal des Alarm-Minuten-Zählers (Einer), '0', im Einstellmodus = En_enc
		signal En_al_min_tens	: std_logic;	--! Enable-Signal des Alarm-Minuten-Zählers (Zehner), '0', im Einstellmodus = Cas_al_min_min
		signal En_al_hour_units	: std_logic;	--! Enable-Signal des Alarm-Stunden-Zählers (Einer), '0', im Einstellmodus = En_enc
		signal En_al_hour_tens	: std_logic;	--! Enable-Signal des Alarm-Stunden-Zählers (Zehner), '0', im Einstellmodus = Cas_al_hour_hour
		
		signal Up_nDown_counter	: std_logic;	--! Up_nDown-Signal der Uhr-Zähler, werden gemultiplext zwischen '1' im Uhrzeitmodus und Up_nDown_enc im Einstellmodus
		
begin
	--! Ausgabe der Ausgangssignale
	square_wav			<= square_wav_int;
	Clk_sec				<= Clk_sec_int;
	-- Datenausgänge der Uhr
	Q_sec_units			<= Q_sec_units_int;
	Q_sec_tens			<= Q_sec_tens_int;
	Q_min_units			<= Q_min_units_int;
	Q_min_tens			<= Q_min_tens_int;
	Q_hour_units		<= Q_hour_units_int;
	Q_hour_tens			<= Q_hour_tens_int;
	-- Datenausgänge des Alarms
	Q_al_min_units		<= Q_al_min_units_int;
	Q_al_min_tens		<= Q_al_min_tens_int;
	Q_al_hour_units	<= Q_al_hour_units_int;
	Q_al_hour_tens		<= Q_al_hour_tens_int;
	
	--! Instanziierung von CounterSec zur Generierung des Impuls- und Rechtecksignals
	gen_seconds : entity work.CounterSec
		generic map(
			Max50			=> Max50,
			Max25			=> Max25
		)
		port map(
			Reset			=> Reset,
			Clk_50		=> Clk_50,
			Clk_sec		=> Clk_sec_int,
			square_wav	=> square_wav_int
		);
	
	--! Instanziierungen von Counter für die Uhr- und Alarmzeit
	--! Uhrzeit: Sekunden (Einer)
	counter_sec_units : entity work.Counter(behave)
		generic map(
			TCO	=> 0 ns,
			TD		=> 0 ns,
			Max	=> x"9"
		)
		port map(
			Reset			=> Reset,
			Clk			=> Clk_50,
			Clear			=> Clear,
			Load			=>	Load_sec,
			En				=> En_sec_units,
			Up_nDown		=> Up_nDown_counter,
			D				=> x"0",
			Q				=> Q_sec_units_int,
			Cas			=> Cas_sec_sec
		);
	
	--! Uhrzeit: Sekunden (Zehner)
	counter_sec_tens : entity work.Counter(behave)
		generic map(
			TCO	=> 0 ns,
			TD		=> 0 ns,
			Max	=> x"5"
		)
		port map(
			Reset			=> Reset,
			Clk			=> Clk_50,
			Clear			=> Clear,
			Load			=>	Load_sec,
			En				=> En_sec_tens,
			Up_nDown		=> Up_nDown_counter,
			D				=> x"0",
			Q				=> Q_sec_tens_int,
			Cas			=> Cas_sec_min
		);
	
	--! Uhrzeit: Minuten (Einer)
	counter_min_units : entity work.Counter(behave)
		generic map(
			TCO	=> 0 ns,
			TD		=> 0 ns,
			Max	=> x"9"
		)
		port map(
			Reset			=> Reset,
			Clk			=> Clk_50,
			Clear			=> Clear,
			Load			=>	'0',
			En				=> En_min_units,
			Up_nDown		=> Up_nDown_counter,
			D				=> x"0",
			Q				=> Q_min_units_int,
			Cas			=> Cas_min_min
		);
	
	--! Uhrzeit: Minuten (Zehner)
	counter_min_tens : entity work.Counter(behave)
		generic map(
			TCO	=> 0 ns,
			TD		=> 0 ns,
			Max	=> x"5"
		)
		port map(
			Reset			=> Reset,
			Clk			=> Clk_50,
			Clear			=> Clear,
			Load			=>	'0',
			En				=> En_min_tens,
			Up_nDown		=> Up_nDown_counter,
			D				=> x"0",
			Q				=> Q_min_tens_int,
			Cas			=> Cas_min_hour
		);
		
	--! Uhrzeit: Stunden (Einer)
	counter_hour_units : entity work.Counter(behave)
		generic map(
			TCO	=> 0 ns,
			TD		=> 0 ns,
			Max	=> x"9"
		)
		port map(
			Reset			=> Reset,
			Clk			=> Clk_50,
			Clear			=> Clear_24,
			Load			=>	Load_24,
			En				=> En_hour_units,
			Up_nDown		=> Up_nDown_counter,
			D				=> x"3",
			Q				=> Q_hour_units_int,
			Cas			=> Cas_hour_hour
		);
	
	--! Uhrzeit: Stunden (Zehner)
	counter_hour_tens : entity work.Counter(behave)
		generic map(
			TCO	=> 0 ns,
			TD		=> 0 ns,
			Max	=> x"2"
		)
		port map(
			Reset			=> Reset,
			Clk			=> Clk_50,
			Clear			=> Clear_24,
			Load			=>	Load_24,
			En				=> En_hour_tens,
			Up_nDown		=> Up_nDown_counter,
			D				=> x"2",
			Q				=> Q_hour_tens_int,
			Cas			=> open
		);
		
	--! Kombinatorik (Clear_24) für den korrekten Überlauf des Stundenzählers im 24h-Format
	Clear_24 <= '1' when (Q_hour_tens_int = x"2" and Q_hour_units_int = x"3" and Cas_min_hour = '1') or (Q_hour_tens_int = x"2" and Q_hour_units_int > x"3") or Clear = '1' else
					'0';
	
	--! Kombinatorik (Load_24) für den korrekten Unterlauf des Stundenzählers im 24h-Format
	Load_24 <= '1' when Show_nSet = '0' and Set_Clock_nAlarm = '1' and Set_Hour_nMin = '1' and Up_nDown_counter = '0' and En_hour_units = '1' and Q_hour_tens_int = x"0" and Q_hour_units_int = x"0" else
				  '0';
		
	--! Alarmzeit: Minuten (Einer)
	counter_al_min_units : entity work.Counter(behave)
		generic map(
			TCO	=> 0 ns,
			TD		=> 0 ns,
			Max	=> x"9"
		)
		port map(
			Reset			=> Reset,
			Clk			=> Clk_50,
			Clear			=> Clear,
			Load			=> '0',
			En				=> En_al_min_units,
			Up_nDown		=> Up_nDown_enc,
			D				=> x"0",
			Q				=> Q_al_min_units_int,
			Cas			=> Cas_al_min_min
		);
	
	--! Alarmzeit: Minuten (Zehner)
	counter_al_min_tens : entity work.Counter(behave)
		generic map(
			TCO	=> 0 ns,
			TD		=> 0 ns,
			Max	=> x"5"
		)
		port map(
			Reset			=> Reset,
			Clk			=> Clk_50,
			Clear			=> Clear,
			Load			=> '0',
			En				=> En_al_min_tens,
			Up_nDown		=> Up_nDown_enc,
			D				=> x"0",
			Q				=> Q_al_min_tens_int,
			Cas			=> open
		);
	
	--! Alarmzeit: Stunden (Einer)
	counter_al_hour_units : entity work.Counter(behave)
		generic map(
			TCO	=> 0 ns,
			TD		=> 0 ns,
			Max	=> x"9"
		)
		port map(
			Reset			=> Reset,
			Clk			=> Clk_50,
			Clear			=> Clear_al_24,
			Load			=> Load_al_24,
			En				=> En_al_hour_units,
			Up_nDown		=> Up_nDown_enc,
			D				=> x"3",
			Q				=> Q_al_hour_units_int,
			Cas			=> Cas_al_hour_hour
		);
	
	--! Alarmzeit: Stunden (Zehner)
	counter_al_hour_tens : entity work.Counter(behave)
		generic map(
			TCO	=> 0 ns,
			TD		=> 0 ns,
			Max	=> x"2"
		)
		port map(
			Reset			=> Reset,
			Clk			=> Clk_50,
			Clear			=> Clear_al_24,
			Load			=> Load_al_24,
			En				=> En_al_hour_tens,
			Up_nDown		=> Up_nDown_enc,
			D				=> x"2",
			Q				=> Q_al_hour_tens_int,
			Cas			=> open
		);
		
	--! Kombinatorik (Clear_al_24) für den korrekten Überlauf des Alarmstundenzählers im 24h-Format
	Clear_al_24 <= '1' when Q_al_hour_tens_int = x"2" and Q_al_hour_units_int > x"3" else
						'0';
	
	--! Kombinatorik (Load_al_24) für den korrekten Unterlauf des Alarmstundenzählers im 24h-Format
	Load_al_24 <= '1' when Show_nSet = '0' and Set_Clock_nAlarm = '0' and Set_Hour_nMin = '1' and Up_nDown_enc = '0' and En_al_hour_units = '1' and Q_al_hour_tens_int = x"0" and Q_al_hour_units_int = x"0" else
					  '0';
	
	--! Instanziierung des Inkrementaldecoders
	inc_encoder : entity work.IncEncoder
		port map(
			A				=> A_enc,
			B				=> B_enc,
			Clk			=> Clk_50,
			Reset			=> Reset,
			En				=> En_enc,
			Up_nDown		=> Up_nDown_enc
		);
	
	--! Kombinatorik (En_alarm_out)
	--En_alarm_out <= '1' when En_alarm_in = '1' and Q_hour_tens_int = Q_al_hour_tens_int and Q_hour_units_int = Q_al_hour_units_int and Q_min_tens_int = Q_al_min_tens_int and Q_min_units_int = Q_al_min_units_int and Q_sec_tens_int = Q_al_sec_tens_int and Q_sec_units_int = Q_al_sec_units_int else
						 --'0';
	
	--! Kombinatorik (LED_out)
	--LED_out <= '1' when Reset = '0' and Show_nSet = '1' and square_wav_int = '1' else -- Fragen nach En??
				  --'0';
	
	--! Prozess für die synchrone Ausgabe des LED- und Alarmausgangssignals. Synchronisation über ein Flipflop um Spikes im LED-Ausgangssignal zu vermeiden
	out_proc : process(Clk_50, Reset, Show_nSet, square_wav_int, En_alarm_in, Q_hour_tens_int, Q_al_hour_tens_int, Q_hour_units_int, Q_al_hour_units_int,
							 Q_min_tens_int, Q_al_min_tens_int, Q_min_units_int, Q_al_min_units_int, Q_sec_tens_int, Q_al_sec_tens_int, Q_sec_units_int, Q_al_sec_units_int)
	begin
		
		if Reset = '1' then
			LED_out <= '0';
			
		elsif rising_edge(Clk_50) then
		
			if Show_nSet = '1' and square_wav_int = '1' then
				LED_out <= '1';
			else
				LED_out <= '0';
			end if;
			
			if En_alarm_in = '1' and Q_hour_tens_int = Q_al_hour_tens_int and Q_hour_units_int = Q_al_hour_units_int and Q_min_tens_int = Q_al_min_tens_int
										and Q_min_units_int = Q_al_min_units_int and Q_sec_tens_int = Q_al_sec_tens_int and Q_sec_units_int = Q_al_sec_units_int then
				En_alarm_out <= '1';
			else
				En_alarm_out <= '0';
			end if;
			
		end if;
	end process out_proc;
	
	--! Kombinatorischer Prozess für den Uhrzeit- und Einstellmodus abhängig von den Steuersignalen
	--! Alternativ mit Concurrent-Statements möglich, sodass der ganze Prozess nicht jedes Mal durchlaufen werden muss
	modes_proc : process(Show_nSet, Set_Clock_nAlarm, Set_Hour_nMin, Clk_sec_int, Cas_sec_sec, Cas_sec_min, Cas_min_min,
					Cas_min_hour, Cas_hour_hour, Up_nDown_enc, En_enc, Cas_al_min_min, Cas_al_hour_hour)
	
	begin
		--! Default-Werte um D-Latch-Problematik zu vermeiden
		En_sec_units		<= '0';
		En_sec_tens			<= '0';
		En_min_units		<= '0';
		En_min_tens			<= '0';
		En_hour_units		<= '0';
		En_hour_tens		<= '0';
		
		En_al_min_units		<= '0';
		En_al_min_tens			<= '0';
		En_al_hour_units		<= '0';
		En_al_hour_tens		<= '0';
		
		Up_nDown_counter		<= '0';
		
		Q_al_sec_units_int	<= (others => '0');
		Q_al_sec_tens_int		<= (others => '0');
		
		Load_sec <= '0';
		
		
		--! Uhrzeitmodus
		if Show_nSet = '1' then
		
			Up_nDown_counter <= '1';		-- Hochzählen
			
			En_sec_units <= Clk_sec_int;	-- Sekundentakt
			En_sec_tens <= Cas_sec_sec;	-- Kaskadierung der Zähler
			En_min_units <= Cas_sec_min;
			En_min_tens <= Cas_min_min;
			En_hour_units <= Cas_min_hour;
			En_hour_tens <= Cas_hour_hour;
			
		--! Einstellmodus
		elsif Show_nSet = '0' then
		
			Up_nDown_counter <= Up_nDown_enc;	-- Zählrichtung abhängig vom Inkrementaldecoder
			
			--! Uhrzeit einstellen
			if Set_Clock_nAlarm = '1' then
				
				Load_sec <= '1';						-- Sekundenzähler der Uhr auf Null zurücksetzen
				
				if Set_Hour_nMin = '1' then		-- Stunden einstellen
					En_hour_units <= En_enc;
					En_hour_tens <= Cas_hour_hour;
				else										-- Minuten einstellen
					En_min_units <= En_enc;
					En_min_tens <= Cas_min_min;
				end if;
			
			--! Alarmzeit einstellen
			elsif Set_Clock_nAlarm = '0' then
				
				-- Während der Einstellung der Alarmzeit soll die Uhr normal weiterlaufen, da sonst Zeit verloren geht, bzw. die Einstellung nicht mehr stimmt
				Load_sec <= '0';
				Up_nDown_counter <= '1';
				En_sec_units <= Clk_sec_int;
				En_sec_tens <= Cas_sec_sec;
				En_min_units <= Cas_sec_min;
				En_min_tens <= Cas_min_min;
				En_hour_units <= Cas_min_hour;
				En_hour_tens <= Cas_hour_hour;
				
				if Set_Hour_nMin = '1' then		-- Stunden einstellen
					En_al_hour_units <= En_enc;
					En_al_hour_tens <= Cas_al_hour_hour;
				else										-- Minuten einstellen
					En_al_min_units <= En_enc;
					En_al_min_tens <= Cas_al_min_min;
				end if;
			
			end if;
		end if;
	end process modes_proc;
	
end architecture behave;