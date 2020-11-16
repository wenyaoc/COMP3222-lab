LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY L11P1 IS
PORT( SW: IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		KEY: IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		CLOCK_50: IN std_logic;
		LEDG: OUT STD_LOGIC_VECTOR(9 DOWNTO 0));
END L11P1;

ARCHITECTURE Structural OF L11P1 IS
	COMPONENT bitcount IS
		PORT( Clock, Resetn : IN STD_LOGIC;
				s : IN STD_LOGIC;
				Data : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
				B : BUFFER STD_LOGIC_VECTOR(3 DOWNTO 0);
				Done : OUT STD_LOGIC );
	END COMPONENT;
BEGIN
	Count: bitcount PORT MAP (CLOCK_50, KEY(0), SW(8), SW(7 DOWNTO 0), LEDG(3 DOWNTO 0), LEDG(9));
END Structural;
	


LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

ENTITY bitcount IS
PORT( Clock, Resetn : IN STD_LOGIC;
		s : IN STD_LOGIC;
		Data : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		B : BUFFER STD_LOGIC_VECTOR(3 DOWNTO 0);
		Done : OUT STD_LOGIC );
END bitcount;

ARCHITECTURE Behavior OF bitcount IS
	COMPONENT shiftrne IS
		PORT (P : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			LA, EA, ser, Clock : IN STD_LOGIC;
			Q : BUFFER STD_LOGIC_VECTOR(7 DOWNTO 0));
	END COMPONENT;
	TYPE State_type IS ( S1, S2, S3 );
	SIGNAL y : State_type;
	SIGNAL A : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL z, LA, EA, LB, EB, low : STD_LOGIC;

BEGIN
	FSM_transitions: PROCESS(Resetn, Clock)
	BEGIN
		IF Resetn = '0' THEN
			y <= S1 ;
		ELSIF (Clock'EVENT AND Clock = '1') THEN
			CASE y IS
				WHEN S1 =>
					IF s = '0' THEN y <= S1 ;
					ELSE y <= S2 ; 
					END IF;
				WHEN S2 =>
					IF z = '0' THEN y <= S2 ;
					ELSE y <= S3 ; 
					END IF;
				WHEN S3 =>
					IF s = '1' THEN y <= S3 ;
					ELSE y <= S1 ; 
					END IF;
			END CASE;
		END IF;
	END PROCESS;


	FSM_outputs: PROCESS (y, A(0))
	BEGIN
		EA <= '0'; LB <= '0'; EB <= '0'; Done <= '0';
		LA <= '0';
		CASE y IS
			WHEN S1 =>
				LB <= '1';
				LA <= '1';
			WHEN S2 =>
				EA <= '1';
				IF A(0) = '1' THEN EB <= '1';
				END IF;
			WHEN S3 =>
				Done <= '1';
		END CASE;
	END PROCESS;


	-- The datapath circuit is described below
	upcount: PROCESS (Resetn, Clock)
	BEGIN
		IF Resetn = '0' THEN
			B <= "0000";
		ELSIF (Clock'EVENT AND Clock = '1') THEN
			IF LB = '1' THEN
				B <= "0000";
			ELSIF EB = '1' THEN
				B <= B + 1;
			END IF;
		END IF;
	END PROCESS;
	low <= '0';
	ShiftA: shiftrne PORT MAP (Data, LA, EA, low, Clock, A);
	z <= '1' WHEN A = "00000000" ELSE '0';
	END Behavior;

	
LIBRARY ieee ;
USE ieee.std_logic_1164.all ;

ENTITY shiftrne IS
	PORT (P : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			LA, EA, ser, Clock : IN STD_LOGIC;
			Q : BUFFER STD_LOGIC_VECTOR(7 DOWNTO 0));
	END shiftrne;
	
ARCHITECTURE Behavior OF shiftrne IS
BEGIN
	PROCESS
	BEGIN
		WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		IF LA = '1' THEN
			Q <= P ;
		ELSIF EA = '1' THEN
			Genbits: FOR i IN 0 TO 6 LOOP
				Q(i) <= Q(i+1);
			END LOOP ;
			Q(7) <= ser;
		END IF;
	END PROCESS;
END Behavior;