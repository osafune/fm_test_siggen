-- ===================================================================
-- TITLE : Test Transmitter (MSM6258 DAC output)
--
--     DESIGN : S.OSAFUNE (J-7SYSTEM WORKS LIMITED)
--     DATE   : 2016/10/07 -> 2016/10/07
--            : 2016/10/07 (FIXED)
--
-- ===================================================================

-- The MIT License (MIT)
-- Copyright (c) 2016 J-7SYSTEM WORKS LIMITED.
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

entity test_tx_msm6258 is
	port(
		reset		: in  std_logic;
		clk			: in  std_logic;
		clk_ena		: in  std_logic;	-- typ 4.096MHz
		sam			: in  std_logic_vector(1 downto 0);		-- 00:4.0k / 01:5.3kHz / 10:8.0kHz
		sync		: out std_logic;

		sigsel		: in  std_logic;						-- '1':external pcm / '0':internal signal
		pcm_ch		: in  std_logic_vector(15 downto 0);

		sock		: out std_logic;
		vck			: out std_logic;
		daso		: out std_logic
	);
end test_tx_msm6258;

architecture RTL of test_tx_msm6258 is
	signal clkcount			: integer range 0 to 15;
	signal pulsecount_reg	: std_logic_vector(5 downto 0);

	signal sock_out_reg		: std_logic;
	signal shift_tx_reg		: std_logic_vector(12 downto 0);
	signal ch_input_sig		: std_logic_vector(15 downto 0);


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
	signal pcm_ch_sig		: std_logic_vector(15 downto 0);

begin

	----------------------------------------------
	-- テスト信号生成 
	----------------------------------------------

	fs_timing_sig <= '1' when(clk_ena = '1' and clkcount = 0 and pulsecount_reg = 0) else '0';

	U_SIG : testgen_sin
	port map(
		reset		=> reset,
		clk			=> clk,
		fs_timing	=> fs_timing_sig,
		wavesin_out	=> wavesin_sig,
		wavesqr_out	=> wavesqr_sig
	);

	pcm_ch_sig <= pcm_ch when(sigsel = '1') else wavesin_sig;



	----------------------------------------------
	-- 送信部 
	----------------------------------------------

	ch_input_sig <= pcm_ch_sig;

	process (clk, reset) begin
		if (reset = '1') then
			clkcount <= 0;
			pulsecount_reg <= (others=>'0');
--			pulsecount_reg <= conv_std_logic_vector(61, 6);		-- test
			sock_out_reg <= '1';

		elsif rising_edge(clk) then
			if (clk_ena = '1') then

				if (clkcount = 0) then
					if (sam = "10") then
						clkcount <= 7;
					elsif (sam = "01") then
						clkcount <= 11;
					else
						clkcount <= 15;
					end if;
				else
					clkcount <= clkcount - 1;
				end if;

				if (clkcount = 0) then
					pulsecount_reg <= pulsecount_reg + '1';

					if (pulsecount_reg = 0) then
						shift_tx_reg <= 'X' & ch_input_sig(15 downto 4);

					elsif (pulsecount_reg >= 3 and pulsecount_reg < 27) then
						sock_out_reg <= not pulsecount_reg(0);

						if (pulsecount_reg(0) = '1') then
							shift_tx_reg <= shift_tx_reg(11 downto 0) & '0';
						end if;
					end if;
				end if;

			end if;
		end if;
	end process;

	sync <= not pulsecount_reg(5);

	sock <= sock_out_reg;
	vck  <= not pulsecount_reg(5);
	daso <= shift_tx_reg(12);


end RTL;
