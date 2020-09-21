LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY part1 IS
PORT ( SW : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		 LEDG : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)); -- NOTE: use LEDG on the DE0
END part1;

ARCHITECTURE Behavior OF part1 IS
BEGIN
	LEDG <= SW; -- NOTE: use LEDG <= SW when using the DE0 board
END Behavior;