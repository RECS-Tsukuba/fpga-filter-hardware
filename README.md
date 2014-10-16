## 応用実験向けのフィルタハードウェア

### 概要
筑波大学工学システム学類の授業、知的工学システム応用実験及び機能工学システム応
用実験で行われる、ハードウェア実装実験で使用されるハードウェアです。

このハードウェアはSRAM上に格納された画像に空間フィルタをかけ、結果をSRAMに格納
します。具体的には以下のような流れになります。
- (PCから送られるrefresh信号を待ちます)
- SRAM0から画素を読み込みます。
- filter.v以下のモジュールが空間フィルタをかけます。
- SRAM1に画素を書き込みます。
- 全ての画素にフィルタをかけたら、is\_end信号を立てます。

このハードウェアはAlpha Data ADMXRC2 SDK memoryサンプルを元に作成されており、
Alpha Data ADM-XRC-2またはADM-XRC-4SX向けに作成されています。

### ライセンス
user\_app.vhdを除くコードはGPL v3。README.mdはCC BY-SA 4.0。

### 作者
筑波大学リコンフィギュラブルコンピューティングシステム研究室
