-- ===================================================================
-- TITLE : Test Signal Transmitter
--
--     DESIGN : S.OSAFUNE (J-7SYSTEM Works)
--     DATE   : 2015/11/05 -> 2015/11/11
--            : 2015/11/11 (FIXED)
--
--     UPDATE : 2019/09/29
--
-- ===================================================================

-- The MIT License (MIT)
-- Copyright (c) 2015,2019 J-7SYSTEM WORKS LIMITED.
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

entity test_tx_top is
	port(
		reset		: in  std_logic;
		clk			: in  std_logic;	-- 50.0MHz input
		devsel		: in  std_logic_vector(3 downto 0);
		pll_locked	: out std_logic_vector(1 downto 0);

		dclk		: out std_logic;
		sd			: out std_logic;
		sh1			: out std_logic;
		sh2			: out std_logic;

		bclk		: out std_logic;
		sdat		: out std_logic;
		lrck		: out std_logic
	);
end test_tx_top;

architecture RTL of test_tx_top is
	signal clk_14m32_sig	: std_logic;
	signal clk_15m98_sig	: std_logic;
	signal clk_3m58_sig		: std_logic;
	signal clk_7m98_sig		: std_logic;
	signal clk_6m14_sig		: std_logic;
	signal clk_5m64_sig		: std_logic;
	signal clk_4m61_sig		: std_logic;
	signal clk_8m19_sig		: std_logic;
	signal pll0_locked_sig	: std_logic;
	signal pll1_locked_sig	: std_logic;
	signal fmreset_sig		: std_logic;
	signal pcmreset_sig		: std_logic;
	signal ckena_4m09_reg	: std_logic;

	signal devsel_reg		: std_logic_vector(3 downto 0);

	component test_pll_fmtx is
	port
	(
		areset		: IN STD_LOGIC  := '0';
		inclk0		: IN STD_LOGIC  := '0';
		c0			: OUT STD_LOGIC ;
		c1			: OUT STD_LOGIC ;
		c2			: OUT STD_LOGIC ;
		c3			: OUT STD_LOGIC ;
		locked		: OUT STD_LOGIC 
	);
	end component;

	component test_pll_pcmtx is
	port
	(
		areset		: IN STD_LOGIC  := '0';
		inclk0		: IN STD_LOGIC  := '0';
		c0			: OUT STD_LOGIC ;
		c1			: OUT STD_LOGIC ;
		c2			: OUT STD_LOGIC ;
		c3			: OUT STD_LOGIC ;
		locked		: OUT STD_LOGIC 
	);
	end component;


	component test_tx_ym2151 is
	port(
		reset		: in  std_logic;
		clk			: in  std_logic;
		clk_ena		: in  std_logic;	-- typ 3.58MHz
		sync		: out std_logic;

		sigsel		: in  std_logic;						-- '1':external pcm / '0':internal signal
		pcm_ch1		: in  std_logic_vector(15 downto 0);	-- L-ch
		pcm_ch2		: in  std_logic_vector(15 downto 0);	-- R-ch

		sclk		: out std_logic;
		sh1			: out std_logic;
		sh2			: out std_logic;
		sdat		: out std_logic
	);
	end component;
	signal ym2151_sclk_sig	: std_logic;
	signal ym2151_sh1_sig	: std_logic;
	signal ym2151_sh2_sig	: std_logic;
	signal ym2151_sd_sig	: std_logic;

	component test_tx_ym2608 is
	port(
		reset		: in  std_logic;
		clk			: in  std_logic;
		clk_ena		: in  std_logic;	-- typ 7.98MHz
		sync		: out std_logic;

		sigsel		: in  std_logic;						-- '1':external pcm / '0':internal signal
		pcm_ch1		: in  std_logic_vector(15 downto 0);	-- L-ch
		pcm_ch2		: in  std_logic_vector(15 downto 0);	-- R-ch

		sclk		: out std_logic;
		sh1			: out std_logic;
		sh2			: out std_logic;
		sdat		: out std_logic
	);
	end component;
	signal ym2608_sclk_sig	: std_logic;
	signal ym2608_sh1_sig	: std_logic;
	signal ym2608_sh2_sig	: std_logic;
	signal ym2608_sd_sig	: std_logic;

	component test_tx_ymf262 is
	port(
		reset		: in  std_logic;
		clk			: in  std_logic;
		clk_ena		: in  std_logic;	-- typ 14.318MHz
		sync		: out std_logic;

		sigsel		: in  std_logic;						-- '1':external pcm / '0':internal signal
		pcm_ch1		: in  std_logic_vector(15 downto 0);	-- L-ch
		pcm_ch2		: in  std_logic_vector(15 downto 0);	-- R-ch

		sclk		: out std_logic;
		sh1			: out std_logic;
		sh2			: out std_logic;
		sdat		: out std_logic
	);
	end component;
	signal ymf262_sclk_sig	: std_logic;
	signal ymf262_sh1_sig	: std_logic;
	signal ymf262_sh2_sig	: std_logic;
	signal ymf262_sd_sig	: std_logic;

	component test_tx_ymf288 is
	port(
		reset		: in  std_logic;
		clk			: in  std_logic;
		clk_ena		: in  std_logic;	-- typ 15.974MHz
		sync		: out std_logic;

		sigsel		: in  std_logic;						-- '1':external pcm / '0':internal signal
		pcm_ch1		: in  std_logic_vector(15 downto 0);	-- L-ch
		pcm_ch2		: in  std_logic_vector(15 downto 0);	-- R-ch

		bclk		: out std_logic;
		lrck		: out std_logic;
		sdat		: out std_logic
	);
	end component;
	signal ymf288_bclk_sig	: std_logic;
	signal ymf288_lrck_sig	: std_logic;
	signal ymf288_sdat_sig	: std_logic;


	component test_tx_c140 is
	port(
		reset		: in  std_logic;
		clk			: in  std_logic;
		clk_ena		: in  std_logic;	-- typ 4.608MHz(C140)
		sync		: out std_logic;

		sigsel		: in  std_logic;						-- '1':external pcm / '0':internal signal
		pcm_ch1		: in  std_logic_vector(15 downto 0);	-- L-ch
		pcm_ch2		: in  std_logic_vector(15 downto 0);	-- R-ch

		bclk		: out std_logic;
		lrck		: out std_logic;
		sdat		: out std_logic
	);
	end component;
	signal c140_bclk_sig	: std_logic;
	signal c140_lrck_sig	: std_logic;
	signal c140_sdat_sig	: std_logic;


	component test_tx_c352 is
	port(
		reset		: in  std_logic;
		clk			: in  std_logic;
		clk_ena		: in  std_logic;	-- typ 8.192MHz(C352)
		sync		: out std_logic;

		sigsel		: in  std_logic;						-- '1':external pcm / '0':internal signal
		pcm_ch1		: in  std_logic_vector(15 downto 0);	-- L-ch
		pcm_ch2		: in  std_logic_vector(15 downto 0);	-- R-ch

		bclk		: out std_logic;
		lrck		: out std_logic;
		sdat		: out std_logic
	);
	end component;
	signal c352_bclk_sig	: std_logic;
	signal c352_lrck_sig	: std_logic;
	signal c352_sdat_sig	: std_logic;


	component test_tx_i2s is
	port(
		reset		: in  std_logic;
		clk			: in  std_logic;
		clk_ena		: in  std_logic;	-- typ 6.144MHz(48kHz) / 5.6448MHz(44.1kHz)
		sync		: out std_logic;

		sigsel		: in  std_logic;						-- '1':external pcm / '0':internal signal
		pcm_ch1		: in  std_logic_vector(15 downto 0);	-- L-ch
		pcm_ch2		: in  std_logic_vector(15 downto 0);	-- R-ch

		sck			: out std_logic;
		ws			: out std_logic;
		sdo			: out std_logic
	);
	end component;
	signal i2s_sck_sig		: std_logic;
	signal i2s_ws_sig		: std_logic;
	signal i2s_sdo_sig		: std_logic;


	component test_tx_msm6258 is
	port(
		reset		: in  std_logic;
		clk			: in  std_logic;
		clk_ena		: in  std_logic;	-- typ 8.0MHz(X68k)
		sam			: in  std_logic_vector(1 downto 0);		-- 00:7.8kHz / 01:10.4kHz / 10:15.6kHz
		sync		: out std_logic;

		sigsel		: in  std_logic;						-- '1':external pcm / '0':internal signal
		pcm_ch		: in  std_logic_vector(15 downto 0);

		sock		: out std_logic;
		vck			: out std_logic;
		daso		: out std_logic
	);
	end component;
	signal msm6258_sock_sig	: std_logic;
	signal msm6258_vck_sig	: std_logic;
	signal msm6258_daso_sig	: std_logic;


begin

	----------------------------------------------
	-- クロックおよびリセット 
	----------------------------------------------

	U_PLL0 : test_pll_fmtx
	port map (
		areset	=> reset,
		inclk0	=> clk,
		c0		=> clk_14m32_sig,
		c1		=> clk_15m98_sig,
		c2		=> clk_3m58_sig,
		c3		=> clk_7m98_sig,
		locked	=> pll0_locked_sig
	);

	pll_locked(0) <= pll0_locked_sig;
	fmreset_sig <= not pll0_locked_sig;


	U_PLL1 : test_pll_pcmtx
	port map (
		areset	=> reset,
		inclk0	=> clk,
		c0		=> clk_6m14_sig,
		c1		=> clk_5m64_sig,
		c2		=> clk_4m61_sig,
		c3		=> clk_8m19_sig,
		locked	=> pll1_locked_sig
	);

	pll_locked(1) <= pll1_locked_sig;
	pcmreset_sig <= not pll1_locked_sig;

--	process (clk_8m19_sig, pcmreset_sig) begin
--		if (pcmreset_sig = '1') then
--			ckena_4m09_reg <= '0';
--		elsif rising_edge(clk_8m19_sig) then
--			ckena_4m09_reg <= not ckena_4m09_reg;
--		end if;
--	end process;



	----------------------------------------------
	-- 送信部のインスタンス 
	----------------------------------------------

	U_TX0 : test_tx_ym2151
	port map(
		reset		=> fmreset_sig,
		clk			=> clk_3m58_sig,
		clk_ena		=> '1',
		sigsel		=> '0',
		pcm_ch1		=> (others=>'0'),
		pcm_ch2		=> (others=>'0'),
		sclk		=> ym2151_sclk_sig,
		sh1			=> ym2151_sh1_sig,
		sh2			=> ym2151_sh2_sig,
		sdat		=> ym2151_sd_sig
	);

	U_TX1 : test_tx_ym2608
	port map(
		reset		=> fmreset_sig,
		clk			=> clk_7m98_sig,
		clk_ena		=> '1',
		sigsel		=> '0',
		pcm_ch1		=> (others=>'0'),
		pcm_ch2		=> (others=>'0'),
		sclk		=> ym2608_sclk_sig,
		sh1			=> ym2608_sh1_sig,
		sh2			=> ym2608_sh2_sig,
		sdat		=> ym2608_sd_sig
	);

	U_TX2 : test_tx_ymf262
	port map(
		reset		=> fmreset_sig,
		clk			=> clk_14m32_sig,
		clk_ena		=> '1',
		sigsel		=> '0',
		pcm_ch1		=> (others=>'0'),
		pcm_ch2		=> (others=>'0'),
		sclk		=> ymf262_sclk_sig,
		sh1			=> ymf262_sh1_sig,
		sh2			=> ymf262_sh2_sig,
		sdat		=> ymf262_sd_sig
	);

	U_TX3 : test_tx_ymf288
	port map(
		reset		=> fmreset_sig,
		clk			=> clk_15m98_sig,
		clk_ena		=> '1',
		sigsel		=> '0',
		pcm_ch1		=> (others=>'0'),
		pcm_ch2		=> (others=>'0'),
		bclk		=> ymf288_bclk_sig,
		lrck		=> ymf288_lrck_sig,
		sdat		=> ymf288_sdat_sig
	);


	U_TX4 : test_tx_c140
	port map(
		reset		=> pcmreset_sig,
		clk			=> clk_4m61_sig,
		clk_ena		=> '1',
		sigsel		=> '0',
		pcm_ch1		=> (others=>'0'),	-- SYSTEM-IIではL/Rが入れ替わっている 
		pcm_ch2		=> (others=>'0'),
		bclk		=> c140_bclk_sig,
		lrck		=> c140_lrck_sig,
		sdat		=> c140_sdat_sig
	);

	U_TX5 : test_tx_c352
	port map(
		reset		=> pcmreset_sig,
		clk			=> clk_8m19_sig,
		clk_ena		=> '1',
		sigsel		=> '0',
		pcm_ch1		=> (others=>'0'),
		pcm_ch2		=> (others=>'0'),
		bclk		=> c352_bclk_sig,
		lrck		=> c352_lrck_sig,
		sdat		=> c352_sdat_sig
	);

	U_TX6 : test_tx_i2s
	port map(
		reset		=> pcmreset_sig,
--		clk			=> clk_6m14_sig,	-- fs = 48kHz
		clk			=> clk_5m64_sig,	-- fs = 44.1kHz
		clk_ena		=> '1',
		sigsel		=> '0',
		pcm_ch1		=> (others=>'0'),
		pcm_ch2		=> (others=>'0'),
		sck			=> i2s_sck_sig,
		ws			=> i2s_ws_sig,
		sdo			=> i2s_sdo_sig
	);

	U_TX7 : test_tx_msm6258
	port map(
		reset		=> pcmreset_sig,
		clk			=> clk_7m98_sig,	-- ≒8.0MHz
		clk_ena		=> '1',
		sam			=> "10",			-- 00:7.8k / 01:10.4kHz / 10:15.6kHz
		sync		=> open,
		sigsel		=> '0',
		pcm_ch		=> (others=>'0'),
		sock		=> msm6258_sock_sig,
		vck			=> msm6258_vck_sig,
		daso		=> msm6258_daso_sig
	);



	----------------------------------------------
	-- 出力信号選択 
	----------------------------------------------

	process (clk) begin
		if rising_edge(clk) then
			devsel_reg <= devsel;		-- cut path用
		end if;
	end process;


	with devsel_reg(1 downto 0) select dclk <=
		ym2151_sclk_sig		when "00",
		ym2608_sclk_sig		when "01",
		ymf262_sclk_sig		when "10",
		ymf288_bclk_sig		when "11",
		'X'					when others;

	with devsel_reg(1 downto 0) select sd <=
		ym2151_sd_sig		when "00",
		ym2608_sd_sig		when "01",
		ymf262_sd_sig		when "10",
		ymf288_sdat_sig		when "11",
		'X'					when others;

	with devsel_reg(1 downto 0) select sh1 <=
		ym2151_sh1_sig		when "00",
		ym2608_sh1_sig		when "01",
		ymf262_sh1_sig		when "10",
		ymf288_lrck_sig		when "11",
		'X'					when others;

	with devsel_reg(1 downto 0) select sh2 <=
		ym2151_sh2_sig		when "00",
		ym2608_sh2_sig		when "01",
		ymf262_sh2_sig		when "10",
		ymf288_lrck_sig		when "11",
		'X'					when others;


	with devsel_reg(3 downto 2) select bclk <=
		c140_bclk_sig		when "00",
		c352_bclk_sig		when "01",
		i2s_sck_sig			when "10",
		msm6258_sock_sig	when "11",
		'X'					when others;

	with devsel_reg(3 downto 2) select sdat <=
		c140_sdat_sig		when "00",
		c352_sdat_sig		when "01",
		i2s_sdo_sig			when "10",
		msm6258_daso_sig	when "11",
		'X'					when others;

	with devsel_reg(3 downto 2) select lrck <=
		c140_lrck_sig		when "00",
		c352_lrck_sig		when "01",
		i2s_ws_sig			when "10",
		msm6258_vck_sig		when "11",
		'X'					when others;


end RTL;
