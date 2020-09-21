LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY L1P3 IS
	PORT(	SW	:IN STD_LOGIC_VECTOR(9 DOWNTO 0);
			LEDG	:OUT STD_LOGIC_VECTOR(9 DOWNTO 0));
END L1P3;

ARCHITECTURE behaviour OF L1P3 IS
	SIGNAL U, V, W, M, N	:STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL s :STD_LOGIC_VECTOR(1 DOWNTO 0);
BEGIN
	LEDG(9 DOWNTO 2) <= "00000000";
	LEDG(1 DOWNTO 0) <= M;
	
	U <= SW(5 DOWNTO 4);
	V <= SW(3 DOWNTO 2);
	W <= SW(1 DOWNTO 0);
	s <= SW(9 DOWNTO 8);
	
	N(0) <= U(0) when (s(0)='0') else V(0);
	N(1) <= U(1) when (s(0)='0') else V(1);
	M(0) <= N(0) when (s(1)='0') else W(0);
	M(1) <= N(1) when (s(1)='0') else W(1);
END behaviour;
