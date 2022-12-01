library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CounterSec is
	generic(
		constant Max50 : integer range 0 to 50_000_000 := 50_000_000;	-- Für Sekundensignal mit f = 1 Hz
		constant Max25 : integer range 0 to 25_000_000 := 25_000_000	-- Für Rechtecksignal mit f = 1 Hz
	);
	port(
		signal Reset	: in std_logic;
		signal Clk_50	: in std_logic;
		signal Clk_sec : out std_logic;
		signal square_wav : out std_logic
	);
end entity CounterSec;

architecture behave of CounterSec is
	signal count50 : integer range 0 to 50_000_000 := 0;
	signal count25 : integer range 0 to 25_000_000 := 0;
	signal square_wav_int : std_logic := '0';
begin
	square_wav <= not square_wav_int;		-- Rechtecksignal-Schnittstelle für andere

	-- Generierung des Sekundensignals (Impulse) aus dem 50 MHz Taktsignal des Boards
	gen_sec : process(Clk_50, Reset)
	begin
	
		if Reset = '1' then
			count50 <= 0;
			Clk_sec <= '0';
		elsif rising_edge(Clk_50) then
			count50 <= count50 + 1;
			Clk_sec <= '0';
			if count50 >= (Max50 - 1) then
				Clk_sec <= '1';
				count50 <= 0;
			end if;
		end if;
	
	end process gen_sec;
	
	-- Generierung des Rechtecksignals aus dem 50 MHz Taktsignal des Boards
	gen_sec_rect : process(Clk_50, Reset)
	begin
		
		if Reset = '1' then
			count25 <= 0;
			square_wav_int <= '0';
			
		elsif rising_edge(Clk_50) then
			count25 <= count25 + 1;
			
			if count25 >= (Max25 - 1) then
				square_wav_int <= not square_wav_int;
				count25 <= 0;
			end if;
		end if;
	end process gen_sec_rect;

end architecture behave;