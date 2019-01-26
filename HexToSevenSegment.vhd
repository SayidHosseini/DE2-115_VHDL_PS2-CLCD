----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    08:11:12 07/31/2016 
-- Design Name: 
-- Module Name:    HexToSevenSegment - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity HexToSevenSegment is
    Port ( hex_value : in  STD_LOGIC_VECTOR (3 downto 0);
           converted_value : out  STD_LOGIC_VECTOR (6 downto 0));
end HexToSevenSegment;

architecture Behavioral of HexToSevenSegment is

begin

process(hex_value)
begin
	case hex_value is
		when x"1" => converted_value <= "1111001";
		when x"2" => converted_value <= "0100100";
		when x"3" => converted_value <= "0110000";
		when x"4" => converted_value <= "0011001";
		when x"5" => converted_value <= "0010010";
		when x"6" => converted_value <= "0000010";
		when x"7" => converted_value <= "1111000";
		when x"8" => converted_value <= "0000000";
		when x"9" => converted_value <= "0011000";
		when x"a" => converted_value <= "0001000";
		when x"b" => converted_value <= "0000011";
		when x"c" => converted_value <= "1000110";
		when x"d" => converted_value <= "0100001";
		when x"e" => converted_value <= "0000110";
		when x"f" => converted_value <= "0001110";
		when others => converted_value <= "1000000"; --//when x"0" is original and not applicable here
	end case;
end process;

end Behavioral;

