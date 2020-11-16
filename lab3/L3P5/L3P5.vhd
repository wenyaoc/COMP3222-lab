LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY L3P5 IS 
	PORT(	SW	:IN STD_LOGIC_VECTOR(9 DOWNTO 0);
			KEY :IN STD_LOGIC_VECTOR(2 DOWNTO 0);
			LEDG	:OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
			HEX0	:OUT STD_LOGIC_VECTOR(0 TO 6);
			HEX1	:OUT STD_LOGIC_VECTOR(0 TO 6);
			HEX2	:OUT STD_LOGIC_VECTOR(0 TO 6);
			HEX3	:OUT STD_LOGIC_VECTOR(0 TO 6));
END L3P5;

ARCHITECTURE structure OF L3P5 IS
	COMPONENT bcd_to_7seg IS
		PORT ( B	:IN STD_LOGIC_VECTOR(3 DOWNTO 0);
				 H	:OUT STD_LOGIC_VECTOR(0 TO 6));
	END COMPONENT;
	COMPONENT register_8_bit IS
		PORT ( D : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
				 Reset, Clock : IN STD_LOGIC ;
				 Q : OUT STD_LOGIC_VECTOR( 7 DOWNTO 0));
	END COMPONENT;
	SIGNAL Q : STD_LOGIC_VECTOR(7 DOWNTO 0);
BEGIN
	LEDG(0) <= KEY(0);
	LEDG(1) <= NOT KEY(1);
	stored: register_8_bit PORT MAP (SW(7 DOWNTO 0), KEY(0), KEY(1), Q);
	h0: bcd_to_7seg PORT MAP(SW(3 DOWNTO 0), HEX0);
	h1: bcd_to_7seg PORT MAP(SW(7 DOWNTO 4), HEX1);
	h2: bcd_to_7seg PORT MAP(Q(3 DOWNTO 0), HEX2);
	h3: bcd_to_7seg PORT MAP(Q(7 DOWNTO 4), HEX3);
	
END structure;	



LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY register_8_bit IS
	PORT ( D : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			 Reset, Clock : IN STD_LOGIC ;
			 Q : OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
END register_8_bit;

ARCHITECTURE Behavior OF register_8_bit IS
BEGIN
	PROCESS (Reset, Clock)
	BEGIN
		IF Reset = '0' THEN
			Q <= "00000000";
		ELSIF Clock'EVENT AND Clock = '0' THEN
			Q <= D;
		END IF;
	END PROCESS;
END Behavior; 




LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY bcd_to_7seg IS
	PORT ( B	:IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			 H	:OUT STD_LOGIC_VECTOR(0 TO 6));
END bcd_to_7seg;

ARCHITECTURE Behavior OF bcd_to_7seg IS
BEGIN
	PROCESS (B)
	BEGIN	
		CASE B IS             
			WHEN "0000" => H <= "0000001";
			WHEN "0001" => H <= "1001111";
			WHEN "0010" => H <= "0010010";
			WHEN "0011" => H <= "0000110";
			WHEN "0100" => H <= "1001100";
			WHEN "0101" => H <= "0100100";
			WHEN "0110" => H <= "0100000";
			WHEN "0111" => H <= "0001111";
			WHEN "1000" => H <= "0000000";
			WHEN "1001" => H <= "0001100";
			WHEN "1010" => H <= "0001000";
			WHEN "1011" => H <= "1100000";
			WHEN "1100" => H <= "0110001";
			WHEN "1101" => H <= "1000010";
			WHEN "1110" => H <= "0110000";
			WHEN "1111" => H <= "0111000";
			WHEN OTHERS => H <= "-------";
		END CASE;
	END PROCESS;
END Behavior;

				
			 
	