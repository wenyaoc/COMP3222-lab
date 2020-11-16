LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY L2P4 IS
	PORT(	SW	:IN STD_LOGIC_VECTOR(9 DOWNTO 0);
			LEDG	:OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
			HEX0	:OUT STD_LOGIC_VECTOR(0 TO 6);
			HEX1	:OUT STD_LOGIC_VECTOR(0 TO 6);
			HEX2	:OUT STD_LOGIC_VECTOR(0 TO 6);
			HEX3	:OUT STD_LOGIC_VECTOR(0 TO 6));
END L2P4;

ARCHITECTURE structure OF L2P4 IS
	COMPONENT full_add IS
		PORT (a, b, ci	: IN std_logic;
				co, s	: OUT std_logic);
	END COMPONENT;
	COMPONENT bcd_to_hex IS
		PORT (B	: IN std_logic_vector(3 DOWNTO 0);
				H	: OUT std_logic_vector(0 TO 6));
	END COMPONENT;
	COMPONENT mux_2to1 IS
		PORT (d0, d1, s	: IN std_logic;
				f				: OUT std_logic);
	END COMPONENT;
	SIGNAL a, b, s : std_logic_vector(3 DOWNTO 0);	-- adder inputs and outputs
	SIGNAL CA : std_logic_vector(3 DOWNTO 0);			-- circuit A outputs
	SIGNAL M : std_logic_vector(3 DOWNTO 0);			-- mux outputs
	SIGNAL N : std_logic_vector(3 DOWNTO 0);			-- circuit B outputs
	SIGNAL cin, cout, z : std_logic;
	SIGNAL c	: std_logic_vector(1 TO 3);				-- carries
BEGIN
	a <= SW(7 DOWNTO 4);
	b <= SW(3 DOWNTO 0);
	cin <= SW(8);
	LEDG(4 DOWNTO 0) <= cout & s;
	LEDG(7) <= ((a(3) AND a(2)) OR (a(3) AND a(1))) OR ((b(3) AND b(2)) OR (b(3) AND b(1)));-- your Boolean logic expression

	--ripple-carry adder
	fa0: full_add PORT MAP (a(0), b(0), cin, c(1), s(0));-- your full_add instantiations
	fa1: full_add PORT MAP (a(1), b(1), c(1), c(2), s(1));
	fa2: full_add PORT MAP (a(2), b(2), c(2), c(3), s(2));
	fa3: full_add PORT MAP (a(3), b(3), c(3), cout, s(3));
	
	--circuit A
	CA(0) <= s(0);-- your Boolean logic expressions
	CA(1) <= NOT s(1);
	CA(2) <= (NOT s(1) AND NOT s(2)) OR (s(1) AND s(2));
	CA(3) <= S(1) AND NOT s(3);
	
	--comparator
	z <= (s(1) AND s(3)) OR (s(2) AND s(3)) OR cout; -- your Boolean logic expression
	
	--circuit B
	N <= "0000" WHEN z = '0' ELSE "0001";

	--muxes
	m0: mux_2to1 PORT MAP (s(0), CA(0), z, M(0));-- your mux_2to1 instantiations
	m1: mux_2to1 PORT MAP (s(1), CA(1), z, M(1));
	m2: mux_2to1 PORT MAP (s(2), CA(2), z, M(2));
	m3: mux_2to1 PORT MAP (s(3), CA(3), z, M(3));
	
	--7-segment decoders
	h0: bcd_to_hex PORT MAP (M(3 DOWNTO 0), HEX0(0 TO 6));-- your bcd_to_hex instantiations
	h1: bcd_to_hex PORT MAP (N(3 DOWNTO 0), HEX1(0 TO 6));
	h2: bcd_to_hex PORT MAP (b(3 DOWNTO 0), HEX2(0 TO 6));
	h3: bcd_to_hex PORT MAP (a(3 DOWNTO 0), HEX3(0 TO 6));
END structure;	

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY mux_2to1 IS
	PORT	(d0, d1, s	:IN STD_LOGIC;
			 f	:OUT STD_LOGIC);
END mux_2to1;

ARCHITECTURE logicfunc OF mux_2to1 IS
BEGIN
	f <= (NOT s AND d0) OR (s AND d1);-- your 2-to-1 mux code
END logicfunc;

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY full_add IS
	PORT	(a, b, ci	:IN STD_LOGIC;
			 co, s	:OUT STD_LOGIC);
END full_add;

ARCHITECTURE structure OF full_add IS
	COMPONENT mux_2to1 IS
		PORT (d0, d1, s	: IN std_logic;
				f				: OUT std_logic);
	END COMPONENT;
	SIGNAL ms : std_logic;
BEGIN
	-- your full adder code
	cout: mux_2to1 PORT MAP (b, ci, a XOR b, co);
	
	s <= ci XOR (a XOR b);
	
END structure;

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY bcd_to_hex IS
	PORT	(B	:IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			 H	:OUT STD_LOGIC_VECTOR(0 TO 6));
END bcd_to_hex;

ARCHITECTURE logicfunc OF bcd_to_hex IS
BEGIN
	H(0) <= (B(2) AND(NOT B(1)) AND (NOT B(0))) OR ((NOT B(3)) AND (NOT B(2)) AND (NOT B(1)) AND B(0));
	H(1) <= (B(2) AND(NOT B(1)) AND B(0)) OR (B(2) AND B(1) AND (NOT B(0)));
	H(2) <= (NOT B(2)) AND B(1) AND (NOT B(0));
	H(3) <= (B(2) AND(NOT B(1)) AND (NOT B(0))) OR (B(2) AND B(1) AND B(0)) OR ((NOT B(3)) AND (NOT B(2)) AND (NOT(B(1))) AND B(0));
	H(4) <= B(0) OR ((NOT B(1)) AND B(2));
	H(5) <= (B(1) AND B(0)) OR ((NOT B(3)) AND (NOT B(2)) AND B(0)) OR ((NOT B(2)) AND B(1));
	H(6) <= ((NOT B(3)) AND (NOT B(2)) AND (NOT B(1))) OR (B(2) AND B(1) AND B(0));
END logicfunc;