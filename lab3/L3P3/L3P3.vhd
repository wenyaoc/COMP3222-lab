LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY L3P3 IS
	PORT(	SW :IN STD_LOGIC_VECTOR(9 DOWNTO 0);
			LEDG : OUT STD_LOGIC_VECTOR(9 DOWNTO 0));
END L3P3;

ARCHITECTURE structural OF L3P3 IS
	COMPONENT L3P2
		PORT	(Clk, D :IN	std_logic;
				Q : OUT std_logic);
	END COMPONENT;
	SIGNAL Qm, Cn : std_logic;
BEGIN
	Cn <= NOT sw(1);
	d1: L3P2 PORT MAP (Cn, SW(0), Qm);
	d2: L3P2 PORT MAP (SW(1), Qm, LEDG(0));
	
	
END structural;


