-- Exhaustive test bench for nxn unsigned multiplier
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

-- In the generic of the test bench: 
--   n is the operand size
--   m is the segment size
-- Please set the name of the component to simulate the relevant version of the multiplier
-- NOTE: exhaustive simulation becomes very slow for n > 12

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use STD.textio.all;
use ieee.math_real.all;

entity tb_u is
  generic (n : natural := 12; m: natural := 6);
end entity tb_u;

architecture exhaustive of tb_u is

component ssm_u3 is
generic(n : natural; -- operand size
        m : natural -- segment size
		);
port ( WA,WB : in unsigned (n-1 downto 0);
       MULT : out unsigned (2*n-1 downto 0) );
end component;

signal ma, mb: unsigned(n-1 downto 0);
signal my: unsigned(2*n-1 downto 0);

begin

dut: ssm_u3 generic map(n=> n, m=> m) 
	port map (ma, mb, my) ;

process

variable m_approx, m_exact: integer;
variable ED, maxED: integer;
variable RED, MRED, MED, NMED, MM, NM, ER: real;
variable E2, sum_E2, Ems, NoEB: real;

variable n_pred: integer;
variable PRED1 : real;
constant pred_th : real := 0.02;
constant MAV : real := (2.0**n -1.0) * (2.0**n -1.0);

variable sum_ED, sum_E, sum_err: real;
variable sum_RED, NmaxED: real;

variable k, k_red, err : integer;

variable n_err, n_exact : integer;

variable MsgLine: line;

begin
n_err := 0;
maxED := 0;
sum_ED := 0.0; sum_err := 0.0; sum_RED := 0.0;
sum_E2 := 0.0;
n_pred := 0;
k := 0; k_red := 0;

for i in 0 to 2**n-1
	loop
	ma <= to_unsigned(i,n);
	for j in 0 to 2**n-1
	loop
		k:=k+1;
		mb <= to_unsigned(j,n);
		wait for 1 ns;
		m_approx := to_integer (my);
		m_exact := i * j;
		
		err := m_exact - m_approx;
		sum_err := sum_err + real(err);
		
		E2 := real(err)*real(err);
		sum_E2 := sum_E2 + E2;
		
		ED := abs(err);
		sum_ED := sum_ED + real(ED);

		if ED > 0 then
			n_err := n_err+1;
		end if;

		if ED > maxED then
			maxED := ED;
		end if;

        if m_exact /= 0 then
            RED := real(ED) / real(abs(m_exact));
			k_red := k_red + 1;
			sum_RED := sum_RED + RED;
			if (RED > pred_th) then
				n_pred := n_pred +1;
			end if;
        end if;
				
	end loop;
end loop;


n_exact := k - n_err;
ER := real(n_err)/real(k);  -- error rate

MM := real(sum_err) / real(k); -- mean error
NM := MM / MAV; -- normalized mean error

NmaxED := real(maxED) / MAV; -- normalized Maximum Error Distance

MED := real(sum_ED) / real(k);  -- mean error distance
NMED := MED / MAV; -- normalized mean error distance

MRED := sum_RED / real(k_red); -- mean relative error distance

Ems := sum_E2 / real(k); -- mean square error
NoEB := 2.0 * real(n) - log2(1.0 + sqrt(Ems) ); -- number of effective bits

PRED1 := real(n_pred) / real(k_red);

write (MsgLine, string'("simulated values: ")); write (MsgLine, k); writeline (output, MsgLine);
write (MsgLine, string'("Error Rate (ER): ")); write (MsgLine, ER); writeline (output, MsgLine);
write (MsgLine, string'("Corrected outputs: ")); write (MsgLine, n_exact); writeline (output, MsgLine);
write (MsgLine, string'("Normalized Mean (NM): ")); write (MsgLine, NM); writeline (output, MsgLine);
write (MsgLine, string'("Normalized Maximum Error Distance (NmaxED): ")); write (MsgLine, NmaxED); writeline (output, MsgLine);
write (MsgLine, string'("Normalized Error Distance (NMED): ")); write (MsgLine, NMED); writeline (output, MsgLine);
write (MsgLine, string'("Number of effective Bits (NoEB): ")); write (MsgLine, NoEB); writeline (output, MsgLine);
write (MsgLine, string'("Mean Relative Error Distance (MRED): ")); write (MsgLine, MRED); writeline (output, MsgLine);
write (MsgLine, string'("Probability RED > 0.02  (PRED): ")); write (MsgLine, PRED1); writeline (output, MsgLine);

wait;

end process;

end architecture exhaustive;
