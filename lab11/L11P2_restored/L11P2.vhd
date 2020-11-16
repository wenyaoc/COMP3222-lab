LIBRARY ieee ;
USE ieee.std_logic_1164.all ;
USE ieee.std_logic_unsigned.all ;

ENTITY L11P2 IS
	PORT(	Clock, Resetn	: IN STD_LOGIC ;
			s					: IN STD_LOGIC ;
			Data 				: IN STD_LOGIC_VECTOR(7 DOWNTO 0) ;
			Addr 				: OUT STD_LOGIC_VECTOR(4 DOWNTO 0) ;
			Found				: OUT STD_LOGIC ;
			Done 				: OUT STD_LOGIC ) ;
END L11P2 ;

ARCHITECTURE Behavior OF L11P2 IS
	COMPONENT memory_block IS -- model used latches address and data internally, hence 2-cycle delay
		PORT(	address	: IN STD_LOGIC_VECTOR (4 DOWNTO 0);
				clock		: IN STD_LOGIC;
				data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
				wren		: IN STD_LOGIC;
				q			: OUT STD_LOGIC_VECTOR (7 DOWNTO 0));
	END COMPONENT;
	COMPONENT regne IS
		GENERIC(N : INTEGER := 8);
		PORT(	D 			: IN 		STD_LOGIC_VECTOR(N-1 DOWNTO 0);
				E		 	: IN 		STD_LOGIC;
				Resetn	: IN		STD_LOGIC;
				Clock 	: IN 		STD_LOGIC;
				Q 			: OUT 	STD_LOGIC_VECTOR(N-1 DOWNTO 0));
	END COMPONENT;
	COMPONENT shiftr IS
		GENERIC(N : INTEGER := 5);
		PORT(	E	: IN 	STD_LOGIC;
				Resetn: IN	STD_LOGIC;
				Clock : IN 	STD_LOGIC;
				D 	: IN STD_LOGIC_VECTOR(N-1 DOWNTO 0);
				Q 	: OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0));
	END COMPONENT;
	
	-- any other components
	
	TYPE State_type IS (S1, S2, S3, S4, S5, S6, S7); -- your states
	SIGNAL y: State_type ;
	
	SIGNAL Q: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL Min, Max, sum, Qaddr: STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL MINinit, MAXinit, MINaddr, MAXaddr, Nextaddr: STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL MAXin, MINin, EA, Msel: STD_LOGIC;
	SIGNAL QltD, QgtD, MaxltMin: STD_LOGIC;
	
BEGIN

	-- your code
	MINinit <= "00000";
	MAXinit <= "11111";
	
	FSM_transitions: PROCESS (Resetn, Clock)
	BEGIN 
		IF Resetn = '0' THEN y <= S1;
		ELSIF (Clock'EVENT AND Clock = '1') THEN 
			CASE y IS 
				WHEN S1 =>
					IF s = '0' THEN y <= S1;
					ELSE
						IF MaxltMin = '0' THEN y <= S2;
						ELSE y <= S7;
						END IF;
					END IF;
				WHEN S2 => y <= S3;
				WHEN S3 => y <= S4;
				WHEN S4 => 
					IF QltD = '1' THEN
						y <= S5;
					ELSIF QgtD = '1' THEN 
						y <= S6;
					ELSE y <= S7; 
					END IF;
				WHEN S5 =>
					IF MaxltMin = '0' THEN y <= S2;
					ELSE y <= S7;
					END IF;
				WHEN S6 =>
					IF MaxltMin = '0' THEN y <= S2;
					ELSE y <= S7;
					END IF;
				WHEN S7 => 
					IF s = '0' THEN y <= S1;
					ELSE y <= S7;
					END IF;
			END CASE;
		END IF;
	END PROCESS;
				
	FSM_outputs: PROCESS(y, s)
	BEGIN 
		MINin <= '0'; MAXin <= '0'; EA <= '0';
		Msel <= '0'; Found <= '0'; Done <= '0';
		CASE y IS 
			WHEN S1 =>
				MINin <= '1';
				MAXin <= '1';
				Msel <= '1';
			WHEN S2 =>
				EA <= '1';
			WHEN S3 => NULL;
			WHEN S4 => NULL;
			WHEN S5 => MINin <= '1';
			WHEN S6 => MAXin <= '1';
			WHEN S7 =>
				IF MaxltMin = '0' THEN Found <= '1';
				END IF;
				Done <= '1';
		END CASE;
	END PROCESS;
	
	-- datapath
	MaxltMin <= '1' WHEN (Max < Min) ELSE '0';
	MINaddr <= MINinit WHEN (Msel = '1') ELSE Nextaddr;
	MAXaddr <= MAXinit WHEN (Msel = '1') ELSE Nextaddr;
	min_reg: regne GENERIC MAP(N => 5)
				PORT MAP (MINaddr, MINin, Resetn, Clock, Min);
	max_reg: regne GENERIC MAP(N => 5)
				PORT MAP (MAXaddr, MAXin, Resetn, Clock, Max);
	--sum_reg: regne GENERIC MAP(N => 5)
	--			PORT MAP ((Min + Max), '1', Resetn, Clock, Sum);
	sum <= Min + Max;
	shift_reg: shiftr GENERIC MAP(N => 5)
				PORT MAP (EA, Resetn, Clock, sum, Qaddr);
	
	mem_blk: memory_block
		PORT MAP (	address => Qaddr,
						clock => Clock, 
						data => "00000000", -- not writing
						wren => '0', -- not writing
						q => Q--your_returned_data 
					);

	QgtD <= '1' WHEN Q > Data ELSE '0';
	QltD <= '1' WHEN Q < Data ELSE '0';
	Nextaddr <= (Qaddr + '1') WHEN (QgtD = '1') ELSE (Qaddr - '1');
	
	Addr <= Qaddr;
END Behavior;


LIBRARY ieee ;
USE ieee.std_logic_1164.all ;

-- n-bit register with synchronous reset and enable
ENTITY regne IS
	GENERIC ( N : INTEGER := 8 ) ;
	PORT(	D 		: IN 	STD_LOGIC_VECTOR(N-1 DOWNTO 0);
			E		: IN 	STD_LOGIC;
			Resetn: IN	STD_LOGIC;
			Clock : IN 	STD_LOGIC ;
			Q 		: OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0));
END regne ;

ARCHITECTURE Behavior OF regne IS
BEGIN
	PROCESS
	BEGIN
		WAIT UNTIL (Clock'EVENT AND Clock = '1') ;
		IF (Resetn = '0') THEN
			Q <= (OTHERS => '0');
		ELSIF (E = '1') THEN
			Q <= D;
		END IF ;
	END PROCESS ;
END Behavior;


LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY shiftr IS -- left-to-right shift register with async reset
	GENERIC (N: INTEGER := 5);
	PORT (E, Resetn, Clock: IN STD_LOGIC;
			D: IN STD_LOGIC_VECTOR(N-1 DOWNTO 0);
			Q: BUFFER STD_LOGIC_VECTOR(N-1 DOWNTO 0));
END shiftr;

ARCHITECTURE Behavior OF shiftr IS
BEGIN
	PROCESS (Resetn, Clock, E)
	BEGIN
		IF Resetn = '0' THEN
			Q <= (OTHERS => '0');
		ELSE 
			IF E = '1' THEN 
				IF Clock'EVENT AND Clock = '1' THEN
					Genbits: FOR i IN 0 TO N-2 LOOP 
						Q(i) <= D(i+1);
					END LOOP;
					Q(N-1) <= '0';
				END IF;
			END IF;
		END IF;
	END PROCESS;
END Behavior;