--HEX7SEG
library ieee;
use ieee.std_logic_1164.all;

entity HEX7SEG is
	generic (HighActive : boolean := true );
	port (
		D : in STD_LOGIC_VECTOR(3 DOWNTO 0);
		En : in std_logic;
		Q : out STD_LOGIC_VECTOR(6 DOWNTO 0)
	);
end entity HEX7SEG;

architecture behave of HEX7SEG is
	signal Q_int : STD_LOGIC_VECTOR(6 DOWNTO 0);
	signal Q_int2 : STD_LOGIC_VECTOR(6 DOWNTO 0);
begin
	
	Q_int <= "0111111" when D = "0000" else
				"0000110" when D = "0001" else
				"1011011" when D = "0010" else
				"1001111" when D = "0011" else
				"1100110" when D = "0100" else
				"1101101" when D = "0101" else
				"1111101" when D = "0110" else
				"0000111" when D = "0111" else
				"1111111" when D = "1000" else
				"1101111" when D = "1001" else
				"1110111" when D = "1010" else
				"1111100" when D = "1011" else
				"0111001" when D = "1100" else
				"1011110" when D = "1101" else
				"1111001" when D = "1110" else
				"1110001" when D = "1111" else
				"0000000";
				
	with En select
		Q_int2 <= Q_int when '1',
			  "0000000" when others;
	
	Q <= Q_int2 when HighActive = true else
		  not Q_int2 when HighActive = false else
		  "0000000";

end architecture behave;