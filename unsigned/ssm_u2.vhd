-- Implementation of corrected unsigned static segmented multiplier, investigated in:
--
-- A. G. M. Strollo, E. Napoli, D. De Caro, N. Petra, G. Saggese and G. D. Meo, 
-- "Approximate Multipliers Using Static Segmentation: Error Analysis and Improvements" 
-- IEEE Transactions on Circuits and Systems I: Regular Papers.

-- Copyright (C) 2021, Antonio G. M. Strollo
-- Dept. of Electrical Engineering and Information Technology
-- University of Napoli, Italy
-- E-mail: antonio.strollo@unina.it
 
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.

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