LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY L4P11 IS
	PORT(	E, Clk, Clearn: IN std_logic;
			Q : BUFFER std_logic_vector(7 DOWNTO 0));
END L4P11;

ARCHITECTURE structural OF L4P11 IS
	COMPONENT T_ff IS
		PORT(	T, Clk, Clearn :IN	std_logic;
				Q : BUFFER std_logic);
	END COMPONENT;
	-- your signal definitions
	SIGNAL T : STD_LOGIC_VECTOR(7 DOWNTO 0);
BEGIN
	-- your VHDL code
	T(0) <= E;
	t1: T_ff PORT MAP (E, Clk, Clearn, Q(0));
	G1: For i IN 1 TO 7 GENERATE
		T(i) <= T(i-1) AND Q(i-1);
		t_2to8: T_ff PORT MAP (T(i), Clk, Clearn, Q(i));
	END GENERATE;	
END structural;

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY T_ff IS
	PORT(	T, Clk, Clearn :IN	std_logic;
			Q : BUFFER std_logic);
END T_ff;

ARCHITECTURE behavioural OF T_ff IS
BEGIN
	-- your VHDL code
	PROCESS (Clearn, Clk, Q)
	BEGIN
		IF Clearn = '0' THEN
			Q <= '0';
		ELSIF Clk'EVENT AND Clk = '1' THEN
			Q <= Q XOR T;
		END IF;
	END PROCESS;
END behavioural;