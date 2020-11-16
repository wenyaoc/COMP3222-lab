LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY L3P2 IS
	PORT(	Clk, D :IN	std_logic;
			Q : OUT std_logic);
END L3P2;

ARCHITECTURE structural OF L3P2 IS
	SIGNAL R, R_g, S_g, Qa, Qb : std_logic;
	ATTRIBUTE keep : boolean;
	ATTRIBUTE keep of R, R_g, S_g, Qa, Qb : SIGNAL IS true;
BEGIN

	-- your VHDL logic expressions for R, R_g, S-g, Qa, Qb and Q
	R <= NOT D;
	R_g <= NOT(R AND Clk);
	S_g <= NOT(D AND Clk);
	Qa <= NOT(S_g AND Qb);
	Qb <= NOT(R_g AND Qa);
	Q <= Qa;
	
END structural;