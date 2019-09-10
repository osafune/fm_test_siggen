-- ===================================================================
-- TITLE : Test Transmitter (C140/C352 DAC output)
--
--     DESIGN : S.OSAFUNE (J-7SYSTEM Works)
--     DATE   : 2015/11/11 -> 2015/11/11
--            : 2015/11/11 (FIXED)
--
-- ===================================================================

-- The MIT License (MIT)
-- Copyright (c) 2015 J-7SYSTEM WORKS LIMITED.
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
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity test_tx_c140 is
	port(
		reset		: in  std_logic;
		clk			: in  std_logic;
		clk_ena		: in  std_logic;	-- typ 8.192MHz(C352) / 4.608MHz(C140)
		sync		: out std_logic;

		sigsel		: in  std_logic;						-- '1':external pcm / '0':internal signal
		pcm_ch1		: in  std_logic_vector(15 downto 0);	-- L-ch
		pcm_ch2		: in  std_logic_vector(15 downto 0);	-- R-ch

		bclk		: out std_logic;
		lrck		: out std_logic;
		sdat		: out std_logic
	);
end test_tx_c140;

architecture RTL of test_tx_c140 is
	signal clkcount			: integer range 0 to 5;
	signal bitcount			: integer range 0 to 31;

	signal bclk_out_reg		: std_logic;
	signal lrck_out_reg		: std_logic;
	signal sync_out_reg		: std_logic;
	signal shift_tx_reg		: std_logic_vector(31 downto 0);
	signal ch1_input_sig	: std_logic_vector(15 downto 0);
	signal ch2_input_sig	: std_logic_vector(15 downto 0);


	component testgen_sin is
	port(
		reset			: in  std_logic;
		clk				: in  std_logic;
		fs_timing		: in  std_logic;

		wavesin_out		: out std_logic_vector(15 downto 0);	-- 正弦波 
		wavesqr_out		: out std_logic_vector(15 downto 0)		-- 矩形波 
	);
	end component;
	signal fs_timing_sig	: std_logic;
	signal wavesin_sig		: std_logic_vector(15 downto 0);
	signal wavesqr_sig		: std_logic_vector(15 downto 0);
	signal pcm_ch1_sig		: std_logic_vector(15 downto 0);
	signal pcm_ch2_sig		: std_logic_vector(15 downto 0);

begin

	----------------------------------------------
	-- テスト信号生成 
	----------------------------------------------

	fs_timing_sig <= '1' when(clk_ena = '1' and clkcount = 0 and bitcount = 0) else '0';

	U_SIG : testgen_sin
	port map(
		reset		=> reset,
		clk			=> clk,
		fs_timing	=> fs_timing_sig,
		wavesin_out	=> wavesin_sig,
		wavesqr_out	=> wavesqr_sig
	);

	pcm_ch1_sig <= pcm_ch1 when(sigsel = '1') else wavesin_sig;
	pcm_ch2_sig <= pcm_ch2 when(sigsel = '1') else wavesqr_sig;



	----------------------------------------------
	-- 送信部 
	----------------------------------------------

	ch1_input_sig <= pcm_ch1_sig;
	ch2_input_sig <= pcm_ch2_sig;

	process (clk, reset) begin
		if (reset='1') then
			clkcount <= 0;
			bitcount <= 0;
--			bitcount <= 29;	--test
			bclk_out_reg <= '0';
			lrck_out_reg <= '0';
			sync_out_reg <= '0';

		elsif rising_edge(clk) then
			if (clk_ena = '1') then

				if (clkcount = 5) then
					clkcount <= 0;
					bclk_out_reg <= '0';

					if (bitcount = 31) then
						bitcount <= 0;
						sync_out_reg <= not sync_out_reg;
						shift_tx_reg <= ch1_input_sig & ch2_input_sig;
					else
						bitcount <= bitcount + 1;
						shift_tx_reg <= shift_tx_reg(30 downto 0) & '0';
					end if;

					if (bitcount = 31) then
						lrck_out_reg <= '1';
					elsif (bitcount = 15) then
						lrck_out_reg <= '0';
					end if;

				else
					if (clkcount = 2) then
						bclk_out_reg <= '1';
					end if;

					clkcount <= clkcount + 1;

				end if;

			end if;
		end if;
	end process;

	sync <= sync_out_reg;

	bclk <= bclk_out_reg;
	lrck <= lrck_out_reg;
	sdat <= shift_tx_reg(31);


end RTL;
