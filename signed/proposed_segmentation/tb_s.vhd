-- Exhaustive test bench for nxn signed multiplier
-- Copyright (C) 2022, Antonio G. M. Strollo
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

-- In the generic of the test bench: 
--   n is the operand size
--   m is the segment size
-- Please set the name of the component to simulate the relevant version of the multiplier

-- NOTE: the simulation becomes very slow for n > 12

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use STD.textio.all;
use ieee.math_real.all;

entity tb_s is
  generic (n : natural := 12; m: natural := 10);
end entity tb_s;

architecture prova of tb_s is

component ssm_s is
generic(n : natural; m : natural);
port ( a,b : in signed (n-1 downto 0);
       y : out signed (2*n-1 downto 0) );
end component;

signal ma, mb: signed(n-1 downto 0);
signal my: signed(2*n-1 downto 0);

begin

dut: ssm_s generic map(n=> n, m=> m) 
	port map (ma, mb, my) ;

process

variable m_approx, m_exact: integer;
variable ED, maxED: integer;
variable RED, MRED, MED, NMED, MM, NM, ER: real;
variable E2, sum_E2, Ems, NoEB: real;

variable n_pred: integer;
variable PRED1 : real;
constant pred_th : real := 0.02;

variable sum_ED, sum_E, sum_err: real;
variable sum_RED, NmaxED: real;

variable k, k_red, err: integer;

variable n_err, n_exact : integer;

variable MsgLine: line;
constant Xmin : integer := -2**(n-1);
constant Xmax : integer := 2**(n-1) - 1;
constant MAV : real := 2.0**(2*n-2);

begin
n_err := 0;
maxED := 0;
sum_ED := 0.0; sum_err := 0.0; sum_RED := 0.0;
sum_E2 := 0.0;
n_pred := 0;
k := 0; k_red := 0;

for i in Xmin to Xmax
	loop
	ma <= to_signed(i,n);
	for j in Xmin to Xmax
	loop
		k:=k+1;
		mb <= to_signed(j,n);
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
ER := real(n_err)/real(k);

MM := real(sum_err) / real(k);
NM := MM / MAV;

NmaxED := real(maxED) / MAV; -- normalized Maximum Error Distance

MED := real(sum_ED) / real(k);
NMED := MED / MAV;

MRED := sum_RED / real(k_red);

Ems := sum_E2 / real(k);
NoEB := 2.0 * real(n) - log2(1.0 + sqrt(Ems) );

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

end architecture prova;
