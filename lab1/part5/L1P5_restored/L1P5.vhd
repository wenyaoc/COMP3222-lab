LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY L1P5 IS
	PORT(	SW	:IN STD_LOGIC_VECTOR(9 DOWNTO 0);
			HEX0	:OUT STD_LOGIC_VECTOR(0 TO 6);
			HEX1	:OUT STD_LOGIC_VECTOR(0 TO 6);
			HEX2	:OUT STD_LOGIC_VECTOR(0 TO 6));
END L1P5;

ARCHITECTURE structure OF L1P5 IS
	COMPONENT mux_2bit_3to1
		PORT( S, U, V, W	:IN STD_LOGIC_VECTOR(1 DOWNTO 0);
				M	:OUT STD_LOGIC_VECTOR(1 DOWNTO 0));
	END COMPONENT;
	COMPONENT char_7seg
		PORT	(C	:IN STD_LOGIC_VECTOR(1 DOWNTO 0);
				Display	:OUT STD_LOGIC_VECTOR(0 TO 6));
	END COMPONENT;
	SIGNAL M	:STD_LOGIC_VECTOR(5 DOWNTO 0); -- will need to be updated
BEGIN
	M0: mux_2bit_3to1 PORT MAP (SW(9 DOWNTO 8), SW(1 DOWNTO 0), SW(5 DOWNTO 4), SW(3 DOWNTO 2), M(1 DOWNTO 0));
	H0: char_7seg PORT MAP(M(1 DOWNTO 0), HEX0);
	M1: mux_2bit_3to1 PORT MAP (SW(9 DOWNTO 8), SW(3 DOWNTO 2), SW(1 DOWNTO 0), SW(5 DOWNTO 4), M(3 DOWNTO 2));
	H1: char_7seg PORT MAP(M(3 DOWNTO 2), HEX1);
	M2: mux_2bit_3to1 PORT MAP (SW(9 DOWNTO 8), SW(5 DOWNTO 4), SW(3 DOWNTO 2), SW(1 DOWNTO 0), M(5 DOWNTO 4));
	H2:  char_7seg PORT MAP(M(5 DOWNTO 4), HEX2);
END structure;	

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY mux_2bit_3to1 IS
	PORT	(S, U, V, W	:IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			M	:OUT STD_LOGIC_VECTOR(1 DOWNTO 0));
END mux_2bit_3to1;

ARCHITECTURE behaviour OF mux_2bit_3to1 IS
	SIGNAL N	:STD_LOGIC_VECTOR(1 DOWNTO 0);
BEGIN
	-- your code	
	N(0) <= (NOT S(0) AND U(0)) OR (S(0) AND V(0));
	N(1) <= (NOT S(0) AND U(1)) OR (S(0) AND V(1));
	M(0) <= (NOT S(1) AND N(0)) OR (S(1) AND W(0));
	M(1) <= (NOT S(1) AND N(1)) OR (S(1) AND W(1));
END behaviour;

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY char_7seg IS
	PORT	(C	:IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			Display	:OUT STD_LOGIC_VECTOR(0 TO 6));
END char_7seg;

ARCHITECTURE behaviour OF char_7seg IS
BEGIN
	-- your code
	Display(0) <= C(1) OR (NOT C(0));
	Display(1) <= C(0);
	Display(2) <= C(0);
	Display(3) <= C(1);
	Display(4) <= C(1);
	Display(5) <= C(1) OR (NOT C(0));
	Display(6) <= C(1);
END behaviour;
