FM/PCM test signal generator
============================

FM音源IC/PCM音源ICの出力データを模擬するテスト信号ジェネレータです。  
音源ICの出力をFPGAで受けたい場合やDACの動作確認時など、音源ICのDACデータ出力信号が必要な際に使用します。  

模擬できるICまたはフォーマット
----------------------------
- YM2151 (3.58MHz駆動,fs=55.9kHz)
- YM2608 (7.98MHz駆動,fs=55.5kHz)
- YMF262 (14.32MHz駆動,fs=49.7kHz)
- YMF288 (15.98MHz駆動,fs=55.5kHz)
- C140 (fs=24.0kHz)
- C352 (fs=42.6kHz)
- I2S (fs=44.1kHz)
- MSM6258 (4.096MHz駆動,fs=8.0kHz)

動作について
-----------
各信号ともに、Lチャネルに正弦波、Rチャネルに矩形波の最大値の信号を出力します。MSM6258はモノラルのため、Lチャネル（正弦波）のみ再生します。    
再生信号の周波数はfs/110Hzになります。例えばYM2151模擬の場合、55.9kHz/110=508Hzの正弦波および矩形波が再生されます。同様に、C140模擬では24kHz/110=218Hzの音声信号となります。

FM音源ICのDAC出力フォーマットについては下記の資料も参考ください。  
[DAC出力フォーマット(pdf)](https://drive.google.com/file/d/0Bw0BfOQoAOEEZGhCTVQ1Wk13SzQ/view)


ライセンス
=========
[The MIT License (MIT)](https://opensource.org/licenses/MIT)  
Copyright (c) 2015-2019 J-7SYSTEM WORKS LIMITED.
