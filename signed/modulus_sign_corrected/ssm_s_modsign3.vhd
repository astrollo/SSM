-- Signed Static Segmented Multiplier
-- Transforms the operands and the result in sign-modulus representation
-- Uses an inner unsigned multiplier
-- The segment size is the one used in the inner multiplier

-- A. G. M. Strollo, E. Napoli, D. De Caro, N. Petra, G. Saggese and G. D. Meo, 
-- "Approximate Multipliers Using Static Segmentation: Error Analysis and Improvements" 
-- IEEE Transactions on Circuits and Systems I: Regular Papers

-- Uses ssm_u3 (three correction terms)
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

entity ssm_s_modsign3 is
generic(n : natural := 8; -- operand size
        m : natural := 5  -- segment size
		);
port ( WA,WB : in signed (n-1 downto 0);
       MULT : out signed (2*n-1 downto 0) );
end entity ssm_s_modsign3;

architecture sign_modulus of ssm_s_modsign3 is
signal a, b : signed (n-1 downto 0);
signal y : signed (2*n-1 downto 0);

signal sign_a, sign_b, sign_result : std_logic;
signal operand_a, operand_b : unsigned  (n-2 downto 0);
signal inner_result : unsigned (2*n-3 downto 0);

component ssm_u3 is
generic(n : natural := 8; -- operand size
        m : natural := 5  -- segment size
		);
port ( WA,WB : in unsigned (n-1 downto 0);
       MULT : out unsigned (2*n-1 downto 0) );
end component;

begin
a <= WA; b <= WB; MULT <= y;

sign_a <= a(n-1);
sign_b <= b(n-1);
sign_result <= sign_a xor sign_b;

operand_a <= unsigned(a(n-2 downto 0)) when sign_a='0' else not unsigned(a(n-2 downto 0));
operand_b <= unsigned(b(n-2 downto 0)) when sign_b='0' else not unsigned(b(n-2 downto 0));

inner_mult: ssm_u3 generic map(n=> n-1, m=> m) 
	port map (operand_a, operand_b, inner_result) ;

y (2*n-3 downto 0) <= signed(inner_result) when sign_result='0' else not signed(inner_result);

y(2*n-1) <= sign_result;
y(2*n-2) <= sign_result;


end architecture sign_modulus;