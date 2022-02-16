-- Test bench for nxn unsigned multiplier, using random inputs
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

-- In the generic of the test bench: 
--   n is the operand size
--   m is the segment size
--  NSAMPLES is number of samples used to test the mutliplier
-- Please set the name of the component to simulate the relevant version of the multiplier
-- Can be used for n <= 31

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use STD.textio.all;
use ieee.math_real.all;

entity tb_random_u is
   generic (n : natural := 16; m: natural := 12; NSAMPLES : natural := 10000000);
end entity tb_random_u;

architecture prova of tb_random_u is

component ssm_u3 is
generic(n : natural; m : natural);
port ( WA,WB : in unsigned (n-1 downto 0);
       MULT : out unsigned (2*n-1 downto 0) );
end component;

signal ma, mb: unsigned(n-1 downto 0);
signal my: unsigned(2*n-1 downto 0);

begin

dut: ssm_u3 generic map(n=> n, m=> m) 
	port map (ma, mb, my) ;

process

variable m_approx, m_exact: real;
variable m_approx_L, m_approx_H: integer;
variable ED, maxED, NmaxED: real;
variable RED, MRED, MED, NMED, MM, NM, ER: real;
variable E2, sum_E2, Ems, NoEB: real;

variable n_pred: integer;
variable PRED1 : real;
constant pred_th : real := 0.02;

variable err, sum_ED, sum_E, sum_err: real;
variable sum_RED: real;

variable k_red: integer;

variable n_err, n_exact : integer;

variable MsgLine: line;
constant MAV : real := (2.0**n -1.0) * (2.0**n -1.0);
variable seed1, seed2 : positive;
variable x : real;
variable i, j : integer;

begin
n_err := 0;
maxED := 0.0;
sum_ED := 0.0; sum_err := 0.0; sum_RED := 0.0;
sum_E2 := 0.0;
n_pred := 0;
k_red := 0;
seed1 := 3; seed2 := 2;

for k in 1 to NSAMPLES
loop
    uniform(seed1, seed2, x);
    i := integer(floor(x * (2.0**n)) ); -- Random number in 0 ... 2**(n)-1
	ma <= to_unsigned(i,n);
    uniform(seed1, seed2, x);
    j := integer(floor(x * (2.0**n)) ); -- Random number in 0 ... 2**(n)-1
	ma <= to_unsigned(i,n);
	mb <= to_unsigned(j,n);
	wait for 1 ns;
	m_approx_L := to_integer (my(n-1 downto 0) );
	m_approx_H := to_integer (my(2*n-1 downto n) );
	m_approx := real(m_approx_L) + real(m_approx_H) * 2.0**n;
--	m_approx := to_integer (my);
	m_exact := real(i) * real(j);
		
	err := m_exact - m_approx;
	sum_err := sum_err + err;
	
	E2 := err*err;
	sum_E2 := sum_E2 + E2;
	
	ED := abs(err);
	sum_ED := sum_ED + ED;

	if ED > 0.0 then
		n_err := n_err+1;
	end if;
	if ED > maxED then
		maxED := ED;
	end if;

	if m_exact /= 0.0 then
		RED := ED / abs(m_exact);
		k_red := k_red + 1;
		sum_RED := sum_RED + RED;
		if (RED > pred_th) then
			n_pred := n_pred +1;
		end if;
	end if;

end loop;


n_exact := NSAMPLES - n_err;
ER := real(n_err)/real(NSAMPLES);  -- error rate

MM := sum_err / real(NSAMPLES);  -- mean error
NM := MM / MAV;  -- normalized mean error

NmaxED := real(maxED) / MAV; -- normalized Maximum Error Distance

MED := sum_ED / real(NSAMPLES); -- mean error distance
NMED := MED / MAV;  -- normalized mean error distance

MRED := sum_RED / real(k_red);  -- mean relative error distance

Ems := sum_E2 / real(NSAMPLES);  -- mean square error
NoEB := 2.0 * real(n) - log2(1.0 + sqrt(Ems) ); -- number of effective bits

PRED1 := real(n_pred) / real(k_red);

write (MsgLine, string'("simulated values: ")); write (MsgLine, NSAMPLES); writeline (output, MsgLine);
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
