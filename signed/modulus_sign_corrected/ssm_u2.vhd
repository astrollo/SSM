-- Implementation of corrected unsigned static segmented multiplier, investigated in:
--
-- A. G. M. Strollo, E. Napoli, D. De Caro, N. Petra, G. Saggese and G. D. Meo, 
-- "Approximate Multipliers Using Static Segmentation: Error Analysis and Improvements" 
-- IEEE Transactions on Circuits and Systems I: Regular Papers

-- Copyright (C) 2022, Antonio G. M. Strollo
-- Dept. of Electrical Engineering and Information Technology
-- University of Napoli, Italy
-- E-mail: antonio.strollo@unina.it
 
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

-- Unsigned Static Segmented Multiplier
-- Error correction - 2 terms

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ssm_u2 is
generic(n : natural := 8; -- operand size
        m : natural := 5  -- segment size
		);
port ( WA,WB : in unsigned (n-1 downto 0);
       MULT : out unsigned (2*n-1 downto 0) );
end entity ssm_u2;

architecture comp of ssm_u2 is
signal alpha_a, alpha_b : unsigned (n-m-1 downto 0);
signal H_a, H_b, L_a, L_b : unsigned (m-1 downto 0);
signal Operand_a, Operand_b : unsigned (m-1 downto 0);
signal mult_out : unsigned (2*m-1 downto 0);

signal aL, bL : std_logic;
signal sely : std_logic_vector (1 downto 0);
constant pad1 : unsigned (2*n - 2*m -1 downto 0) := (others => '0');
constant pad2 : unsigned (n - m - 1 downto 0) := (others => '0');

signal c: unsigned (3 downto 1); -- for the correction
signal correction : unsigned (2*m-1 downto 0);

begin

alpha_a <= WA(n-1 downto m); alpha_b <= WB(n-1 downto m);
H_a <= WA(n-1 downto n-m);  H_b <= WB(n-1 downto n-m); 
L_a <= WA(m-1 downto 0);    L_b <= WB(m-1 downto 0); 

aL <= '1' when (alpha_a = 0) else '0'; 
bL <= '1' when (alpha_b = 0) else '0'; 
sely <= aL & bL; 

Operand_a <= L_a when aL='1' else H_a;
Operand_b <= L_b when bL='1' else H_b;

c(3) <= (WB(n-1) and WA(n-m-1)) or (WA(n-1) and WB(n-m-1));
c(2) <= (WB(n-2) and WA(n-m-1)) or (WA(n-2) and WB(n-m-1));
c(1) <= '0';

correction (2*m-1 downto m) <= (others => '0');
correction (m-4 downto 0) <= (others => '0');
correction (m-1 downto m-3) <= c when sely="00" else "000";

mult_out <= Operand_a * Operand_b + correction;

with sely select
  MULT <= 	mult_out & pad1 		when "00",
		pad2 & mult_out & pad2 	when "01" | "10",
		pad1 & mult_out  		when others;

end architecture comp;