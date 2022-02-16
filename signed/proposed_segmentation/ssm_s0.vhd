-- Implementation of signed static segmented multiplier,
-- using a simple empirical error reduction technique 
--
-- A. G. M. Strollo, E. Napoli, D. De Caro, N. Petra, G. Saggese and G. D. Meo, 
-- "Approximate Multipliers Using Static Segmentation: Error Analysis and Improvements" 
-- IEEE Transactions on Circuits and Systems I: Regular Papers
--
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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ssm_s0 is
generic(n : natural := 8; -- operand size
        m : natural := 4  -- segment size
		);
port ( a,b : in signed (n-1 downto 0);
       y : out signed (2*n-1 downto 0) );
end entity ssm_s0;

architecture comp of ssm_s0 is
signal alpha_a, alpha_b : signed (n-m downto 0);
signal H_a, H_b, L_a, L_b : signed (m-1 downto 0);
signal Operand_a, Operand_b : signed (m-1 downto 0);
signal mult_out : signed (2*m-1 downto 0);

signal aL, bL : std_logic;
signal sely : std_logic_vector (1 downto 0);
constant pad1 : signed (2*n - 2*m -1 downto 0) := (others => '0');
constant pad2 : signed (n - m - 1 downto 0) := (others => '0');

begin

alpha_a <= a(n-1 downto m-1); alpha_b <= b(n-1 downto m-1);
H_a(m-1 downto 1) <= a(n-1 downto n-m+1); H_a(0) <= a(n-m) OR a(n-m-1);
H_b(m-1 downto 1) <= b(n-1 downto n-m+1); H_b(0) <= b(n-m) OR b(n-m-1);

L_a(m-2 downto 0) <= a(m-2 downto 0); L_a(m-1) <= a(n-1);
L_b(m-2 downto 0) <= b(m-2 downto 0); L_b(m-1) <= b(n-1);

aL <= '1' when (alpha_a = 0) or (alpha_a = -1) else '0'; 
bL <= '1' when (alpha_b = 0) or (alpha_b = -1) else '0'; 
sely <= aL & bL; 

Operand_a <= L_a when aL='1' else H_a;
Operand_b <= L_b when bL='1' else H_b;

mult_out <= Operand_a * Operand_b;

with sely select
  y <= 	mult_out & pad1 				when "00",
		resize (mult_out & pad2, 2*n) 	when "01" | "10",
		resize (mult_out, 2*n)  		when others;

end architecture comp;