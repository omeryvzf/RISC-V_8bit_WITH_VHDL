library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity ALU is 
	port(
			A : in std_logic_vector(7 downto 0);
			B : in std_logic_vector(7 downto 0);
			ALU_Sel : in std_logic_vector(2 downto 0); -- i�lem t�r� se�imi
			-- out
			NZVC : out std_logic_vector(3 downto 0);
			ALU_result : out std_logic_vector(7 downto 0)
		);
end ALU;

architecture arch of ALU is

signal sum_unsigned : std_logic_vector(8 downto 0) ; -- carry varm� yok mu
signal alu_signal : std_logic_vector(7 downto 0); -- toplam� tutacag�m�z sinyal
signal toplama_overflow : std_logic; -- overflow var m� for toplama
signal cikarma_overflow : std_logic; -- c�karmada

begin

process(ALU_Sel, A,B)
begin
	sum_unsigned <= (others => '0'); -- reset 
	
	case ALU_Sel is
		when "000" =>  -- toplama
			alu_signal <= A+B;
			sum_unsigned <= ('0' & A) + ('0' + B);
		when "001" => -- c�karmada
			alu_signal <= A-B;
			sum_unsigned <= ('0' & A) - ('0' + B);
		when "010" => -- and
			alu_signal <= A and B;
		when "011" => -- or
			alu_signal <= A or B;
		when "100" => -- +1 artt�r
			alu_signal <= A + x"01";
		when "101" => -- -1 azalt
			alu_signal <= A - x"01";
		when others =>
			alu_signal <= (others => '0');
			sum_unsigned <= (others =>'0');
		end case;

end process;
ALU_result <= alu_signal;
-- NZVC (Negatif Sifir Overflow, Carry)

-- N 
NZVC(3) <= alu_signal(7);

-- Z 
NZVC(2) <= '1' when alu_signal = x"00" else '0';

-- V overflow 
toplama_overflow <= (not(A(7)) and not(B(7)) and alu_signal(7)) or (A(7) and B(7) and not(alu_signal(7)));
cikarma_overflow <= (not(A(7)) and B(7) and alu_signal(7)) or (A(7) and not(B(7)) and not(alu_signal(7)));

--Vivadoda d�zeltilecek

NZVC(1) <= toplama_overflow when (ALU_Sel = "000") else
			cikarma_overflow when (ALU_Sel = "001") else '0' ;

-- carry
NZVC(0) <= sum_unsigned(8) when (ALU_Sel = "000") else
			sum_unsigned(8) when (ALU_Sel = "001") else '0';
end architecture;