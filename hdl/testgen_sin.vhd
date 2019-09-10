-- ===================================================================
-- TITLE : Sinwave generator
--
--     DESIGN : S.OSAFUNE (J-7SYSTEM Works)
--     DATE   : 2013/08/01 -> 2013/08/02
--            : 2014/09/19 (FIXED)
--     MODIFY : 2015/11/07
--
-- ===================================================================

-- The MIT License (MIT)
-- Copyright (c) 2013-2015 J-7SYSTEM WORKS LIMITED.
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy of
-- this software and associated documentation files (the "Software"), to deal in
-- the Software without restriction, including without limitation the rights to
-- use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
-- of the Software, and to permit persons to whom the Software is furnished to do
-- so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

entity testgen_sin is
	port(
		reset			: in  std_logic;
		clk				: in  std_logic;
		fs_timing		: in  std_logic;	-- fs=48kHz

		wavesin_out		: out std_logic_vector(15 downto 0);	-- 正弦波 
		wavesqr_out		: out std_logic_vector(15 downto 0)		-- 矩形波 
	);
end testgen_sin;

architecture RTL of testgen_sin is
	constant WAVEDATANUM	: integer := 110;

	type DEF_ROM is array(0 to WAVEDATANUM-1) of std_logic_vector(15 downto 0);
	constant WAVEROM : DEF_ROM := (
		X"0000",X"06B0",X"0D5B",X"13FB",X"1A8A",X"2103",X"2761",X"2D9E",X"33B4",X"399F",
		X"3F5B",X"44E1",X"4A2E",X"4F3D",X"5409",X"5890",X"5CCD",X"60BC",X"645A",X"67A4",
		X"6A98",X"6D33",X"6F73",X"7156",X"72DA",X"73FE",X"74C1",X"7523",X"7523",X"74C1",
		X"73FE",X"72DA",X"7156",X"6F73",X"6D33",X"6A98",X"67A4",X"645A",X"60BC",X"5CCD",
		X"5890",X"5409",X"4F3D",X"4A2E",X"44E1",X"3F5B",X"399F",X"33B4",X"2D9E",X"2761",
		X"2103",X"1A8A",X"13FB",X"0D5B",X"06B0",X"0000",X"F94F",X"F2A4",X"EC04",X"E575",
		X"DEFC",X"D89E",X"D261",X"CC4B",X"C660",X"C0A4",X"BB1E",X"B5D1",X"B0C2",X"ABF6",
		X"A76F",X"A332",X"9F43",X"9BA5",X"985B",X"9567",X"92CC",X"908C",X"8EA9",X"8D25",
		X"8C01",X"8B3E",X"8ADC",X"8ADC",X"8B3E",X"8C01",X"8D25",X"8EA9",X"908C",X"92CC",
		X"9567",X"985B",X"9BA5",X"9F43",X"A332",X"A76F",X"ABF6",X"B0C2",X"B5D1",X"BB1E",
		X"C0A4",X"C660",X"CC4B",X"D261",X"D89E",X"DEFC",X"E575",X"EC04",X"F2A4",X"F94F"
	);

	signal fs_sig			: std_logic;
	signal fs_old_reg		: std_logic;
	signal wavecount		: integer range 0 to WAVEDATANUM-1;
	signal wavesin_reg		: std_logic_vector(15 downto 0);
	signal wavesqr_reg		: std_logic_vector(15 downto 0);

begin

	process (clk, reset) begin
		if (reset = '1') then
			fs_old_reg <= '0';
			wavecount <= 0;
			wavesin_reg <= X"0000";
			wavesqr_reg <= X"0000";

		elsif rising_edge(clk) then
			fs_old_reg <= fs_timing;

			if (fs_timing = '1' and fs_old_reg = '0') then
				if (wavecount = WAVEDATANUM-1) then
					wavecount <= 0;
				else
					wavecount <= wavecount + 1;
				end if;

				wavesin_reg <= WAVEROM(wavecount);

				if (wavecount = 0) then
					wavesqr_reg <= X"7fff";
				elsif (wavecount = WAVEDATANUM/2) then
					wavesqr_reg <= X"8001";
				end if;

			end if;

		end if;
	end process;

	wavesin_out <= wavesin_reg;
	wavesqr_out <= wavesqr_reg(15) & wavesqr_reg(15 downto 1);


end RTL;
