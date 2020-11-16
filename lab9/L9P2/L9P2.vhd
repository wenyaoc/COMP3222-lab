--use Quartus II simulator for simulation

LIBRARY ieee; 
USE ieee.std_logic_1164.all;
USE ieee.std_logic_signed.all;

ENTITY L9P2 IS
	PORT( KEY : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
			SW  : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
			LEDG: OUT STD_LOGIC_VECTOR(9 DOWNTO 0));
END L9P2;
	
ARCHITECTURE Structural OF L9P2 IS
	COMPONENT Proc IS
		PORT (DIN : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
				Resetn, PClock, Run : IN STD_LOGIC;
				Done : BUFFER STD_LOGIC;
				BusWires : BUFFER STD_LOGIC_VECTOR(8 DOWNTO 0));
	END COMPONENT;
	COMPONENT ROM_mif IS
		port( MClock : IN STD_LOGIC;
				addr : IN STD_LOGIC_VECTOR(7 downto 0);
				data : OUT STD_LOGIC_VECTOR(8 downto 0));
	END COMPONENT;
	COMPONENT counter IS
		PORT (MClock, Resetn: IN STD_LOGIC;
				Q : BUFFER STD_LOGIC_VECTOR(7 DOWNTO 0));
	END COMPONENT;
	SIGNAL Done: STD_LOGIC;
	SIGNAL Cout: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL DIN, BusWires: STD_LOGIC_VECTOR(8 DOWNTO 0);
BEGIN
	
	Count: counter PORT MAP(KEY(2), KEY(0), Cout);
	rom: ROM_mif PORT MAP(KEY(2), Cout, DIN);
	Proc1: Proc PORT MAP (DIN, KEY(0), KEY(1), SW(9), Done, BusWires);
	
	LEDG(9) <= Done;
	LEDG(8 DOWNTO 0) <= BusWires;
END Structural;	


LIBRARY ieee; 
USE ieee.std_logic_1164.all;
USE ieee.std_logic_signed.all;

ENTITY Proc IS
	PORT (DIN : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
			Resetn, PClock, Run : IN STD_LOGIC;
			Done : BUFFER STD_LOGIC;
			BusWires : BUFFER STD_LOGIC_VECTOR(8 DOWNTO 0));
END Proc;

ARCHITECTURE Mixed OF Proc IS
	-- declare components
	COMPONENT dec3to8 IS 
		PORT (W : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
				En : IN STD_LOGIC;
				Y : OUT STD_LOGIC_VECTOR(0 TO 7));
	END COMPONENT;
	COMPONENT regn IS
		GENERIC (n : INTEGER := 9);
	PORT (R : IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
			Rin, PClock : IN STD_LOGIC;
			Q : BUFFER STD_LOGIC_VECTOR(n-1 DOWNTO 0));
	END COMPONENT;
	-- declare signals
	TYPE State_type IS (T0, T1, T2, T3);
	SIGNAL Tstep_Q, Tstep_D: State_type;
	SIGNAL I, X, Y: STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL Xreg, Yreg, Rin, Rout: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL IR, Sum, R0, R1, R2, R3, R4, R5, R6, R7, A, G: STD_LOGIC_VECTOR(8 DOWNTO 0);
	SIGNAL Sel: STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL Hi, IRin, Ain, Gin, Gout, AddSub, Extern: STD_LOGIC;
	--
BEGIN
	Hi <= '1';
	I <= IR(8 DOWNTO 6);
	decX: dec3to8 PORT MAP (IR(5 DOWNTO 3), Hi, Xreg);
	decY: dec3to8 PORT MAP (IR(2 DOWNTO 0), Hi, Yreg);

	statetable: PROCESS (Tstep_Q, Run, Done)
	BEGIN
		CASE Tstep_Q IS
			WHEN T0 => -- data is loaded into IR in this time step
				IF (Run = '0') THEN
					Tstep_D <= T0;
				ELSE 
					Tstep_D <= T1;
				END IF;
			WHEN T1 =>
				IF (Done = '1') THEN
					Tstep_D <= T0;
				ELSE 
					Tstep_D <= T2;
				END IF;
			WHEN T2 =>
				Tstep_D <= T3;
			WHEN T3 =>
				Tstep_D <= T0;		
		END CASE;
	END PROCESS;

	controlsignals: PROCESS (Tstep_Q, I, Xreg, Yreg)
	BEGIN
		-- specify initial values
		Rin <= "00000000"; Rout <= "00000000";
		Done <= '0'; Gin <= '0'; Gout <= '0'; IRin <= '0'; Ain <= '0';
		AddSub <= '0'; Extern <= '0';
		CASE Tstep_Q IS
			WHEN T0 => -- store DIN in IR as long as Tstep_Q = 0
				IRin <= '1';
			WHEN T1 => -- define signals in time step T1
				CASE I IS
					WHEN "000" => -- move
						Rin <= Xreg;
						Rout <= Yreg;
						Done <= '1';
					WHEN "001" => --load
						Rin <= Xreg;
						Extern <= '1';
						Done <= '1';
					WHEN "010" => --add
						Rout <= Xreg;
						Ain <= '1';
					WHEN "011" => --sub
						Rout <= Xreg;
						Ain <= '1';
					WHEN OTHERS => NULL;
				END CASE;
			WHEN T2 => -- define signals in time step T2
				CASE I IS
					WHEN "010" => --add
						Rout <= Yreg;
						Gin <= '1';
					WHEN "011" => --sub
						Rout <= Xreg;
						Gin <= '1';
						AddSub <= '1';
					WHEN OTHERS => NULL;
				END CASE;
			WHEN T3 => -- define signals in time step T3
				CASE I IS
					WHEN "010" => --add
						Rin <= Xreg;
						Gout <= '1';
						Done <= '1';
					WHEN "011" => --sub
						Rin <= Xreg;
						Gout <= '1';
						Done <= '1';
					WHEN OTHERS => NULL;
				END CASE;
		END CASE;
	END PROCESS;

	fsmflipflops: PROCESS (PClock, Resetn)
	BEGIN
		IF (Resetn = '0') THEN 
			Tstep_Q <= T0;
		ELSIF (PClock'EVENT AND PClock = '1') THEN
			Tstep_Q <= Tstep_D;
		END IF;
	END PROCESS;
	
	reg_0: regn PORT MAP (BusWires, Rin(7), PClock, R0);
	reg_1: regn PORT MAP (BusWires, Rin(6), PClock, R1);
	reg_2: regn PORT MAP (BusWires, Rin(5), PClock, R2);
	reg_3: regn PORT MAP (BusWires, Rin(4), PClock, R3);
	reg_4: regn PORT MAP (BusWires, Rin(3), PClock, R4);
	reg_5: regn PORT MAP (BusWires, Rin(2), PClock, R5);
	reg_6: regn PORT MAP (BusWires, Rin(1), PClock, R6);
	reg_7: regn PORT MAP (BusWires, Rin(0), PClock, R7);
	
	regA: regn PORT MAP (BusWires, Ain, PClock, A);
	regIR: regn PORT MAP (DIN, IRin, PClock, IR);
	WITH AddSub SELECT
		Sum <= A + BusWires WHEN '0',
				 A - BusWires WHEN OTHERS;
	regG: regn PORT MAP (Sum, Gin, PClock, G);
	
	Sel <= Rout & Gout & Extern;
	WITH Sel SELECT
		BusWires <= R0 WHEN "1000000000",
						R1 WHEN "0100000000",
						R2 WHEN "0010000000",
						R3 WHEN "0001000000",
						R4 WHEN "0000100000",
						R5 WHEN "0000010000",
						R6 WHEN "0000001000",
						R7 WHEN "0000000100",
						G  WHEN "0000000010",
						DIN WHEN OTHERS;
	
	
	-- instantiate registers and the adder/subtracter unit
	-- define the bus

END Mixed;

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY dec3to8 IS
	PORT (W : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
			En : IN STD_LOGIC;
			Y : OUT STD_LOGIC_VECTOR(0 TO 7));
END dec3to8;

ARCHITECTURE Behavior OF dec3to8 IS
BEGIN
	PROCESS (W, En)
	BEGIN
		IF (En = '1') THEN
			CASE W IS
				WHEN "000" => Y <= "10000000";
				WHEN "001" => Y <= "01000000";
				WHEN "010" => Y <= "00100000";
				WHEN "011" => Y <= "00010000";
				WHEN "100" => Y <= "00001000";
				WHEN "101" => Y <= "00000100";
				WHEN "110" => Y <= "00000010";
				WHEN "111" => Y <= "00000001";
			END CASE;
		ELSE
			Y <= "00000000";
		END IF;
	END PROCESS;
END Behavior;

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY regn IS
	GENERIC (n : INTEGER := 9);
	PORT (R : IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
			Rin, PClock : IN STD_LOGIC;
			Q : BUFFER STD_LOGIC_VECTOR(n-1 DOWNTO 0));
END regn;

ARCHITECTURE Behavior OF regn IS
BEGIN
	PROCESS (PClock)
	BEGIN
		IF (rising_edge(PClock)) THEN
			IF (Rin = '1') THEN
				Q <= R;
			END IF;
		END IF;
	END PROCESS;
END Behavior;


LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity ROM_mif is
    generic(
        addr_width : integer := 32;
        addr_bits  : integer := 8;
        data_width : integer := 9);
PORT(MClock : IN STD_LOGIC;
    addr : IN STD_LOGIC_VECTOR(addr_bits-1 DOWNTO 0);
    data : OUT STD_LOGIC_VECTOR(data_width-1 DOWNTO 0));
END ROM_mif;

ARCHITECTURE Behavior OF ROM_mif IS

    type rom_type is array (0 to addr_width-1) of std_logic_vector(data_width-1 downto 0);
    signal segment_ROM : rom_type;
    attribute ram_init_file : string; 
    attribute ram_init_file of segment_ROM : signal is "inst_mem.mif";
BEGIN
	PROCESS (MClock, addr)
	BEGIN
		IF (MClock'EVENT AND MClock = '1') THEN
			data <= segment_ROM(to_integer(unsigned(addr)));
		END IF;
	END PROCESS;
END Behavior; 


LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_signed.all;

ENTITY counter IS
PORT (MClock, Resetn: IN STD_LOGIC;
		Q : BUFFER STD_LOGIC_VECTOR(7 DOWNTO 0));
END counter;

ARCHITECTURE Behavior OF counter IS
BEGIN
	PROCESS (MClock, Resetn)
	BEGIN
		IF Resetn = '0' THEN
			Q <= "00000000";
		ELSIF (MClock'EVENT AND MClock = '1') THEN
				Q <= Q + 1;
			IF Q = "00000110" THEN
				Q <= "00000000";
			END IF;
		END IF;
	END PROCESS ;
END Behavior ; 