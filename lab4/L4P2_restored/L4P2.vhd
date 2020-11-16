-- this design can be clocked as 425.89 MHz under 85C slow model
-- fmax for part2 is smaller that part1
-- for part1 has 8 flipflops and the signal will pass through 7 AND gates
-- part2 has 16 flopflops each flipflop is connected by an adder
-- which means that the signal in part2 will pass more gates in the adder comparing with part1
-- so, the minimun period for part2 is longer than part1
-- hence, the Fmax for part2 is smaller
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

ENTITY L4P2 IS
	PORT(	E, Clk, Clearn: IN std_logic;
			Q: BUFFER std_logic_vector(15 DOWNTO 0));
END L4P2;

ARCHITECTURE behavioural OF L4P2 IS
BEGIN

	-- your VHDL code
	PROCESS (Clk, Clearn)
	BEGIN
		IF Clearn = '0' THEN
			Q <= (OTHERS => '0');
		ELSIF (Clk'EVENT AND Clk = '1') THEN
			IF E = '1' THEN
				Q <= Q + 1;
			ELSE
				Q <= Q;
			END IF;
		END IF;
	END PROCESS;

END behavioural;