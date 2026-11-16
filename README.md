# FPGA-UART-VGA-Display

基于 Altera (Intel) Cyclone V FPGA 的串口图像传输与 VGA 显示系统。

本项目通过 PC 上位机串口（UART，115200 波特率）将彩色图片数据（24-bit RGB888）发送至 FPGA，FPGA 通过 16 倍过采样接收、拼接为 24 位像素并写入双口 RAM（DPRAM）显存中；同时，VGA 控制器按照标准 800×600 @ 60Hz 工业时序读取显存，在显示器正中央实时开窗显示 200×180 像素的彩色图像。

---

## 硬件与软件环境

- **FPGA 芯片**：Altera Cyclone V `5CSEMA5F31C6`（常见于 Terasic DE1-SoC 开发板）
- **板载外设**：
  - 50MHz 有源晶振
  - 板载 ADV7123 高速视频 DAC 及标准 VGA 接口
  - UART 接口（引脚分配对应板载串口或扩展引脚）
- **开发与综合工具**：Quartus II 13.1 (64-bit) / Quartus Prime
- **仿真工具**：ModelSim-Altera 10.1d / QuestaSim

---

## 系统架构与工作原理

```text
  PC 上位机 (串口图像发送)
             │
             │ UART 串口传输 (波特率: 115200, 8-N-1)
             ▼
      +---------------+
      |    uart_rx    |  <-- 16倍过采样 (uart_clk: 1.8432MHz)
      +---------------+      接收连续 3 字节拼装为 24-bit RGB888 像素
             │
             │ rx_data [23:0], rx_data_flag
             ▼
      +---------------+
      | ram2_wr_ctrl  |  <-- 写控制逻辑：生成写使能并递增写地址 (0 ~ 35999)
      +---------------+
             │
             │ wr_addr [15:0], wren, wr_data
             ▼
      +---------------+
      |   my_dpram    |  <-- 双口 RAM 显存 (36000 深度 × 24-bit)
      +---------------+      异步时钟域隔离 (uart_clk 写 / vga_clk 读)
             │
             │ rd_addr [15:0], rd_data [23:0]
             ▼
      +---------------+
      |   vga_ctrl    |  <-- 800x600@60Hz 扫描时序 (vga_clk: 40MHz)
      +---------------+      居中开窗读取 (行: 237~416, 列: 516~715)
             │
             ▼
       VGA 显示器 (屏幕中央呈现 200×180 彩色图像)
```

### 1. 时钟管理 (`my_pll`)
- 输入：50MHz 系统时钟。
- 输出：
  - `uart_clk`（~1.8432MHz）：串口 16 倍过采样时钟（$115200 \times 16 \approx 1.8432\text{ MHz}$）。
  - `vga_clk`（40.0MHz）：标准 800×600@60Hz VGA 像素点时钟。
- 采用 PLL 的 `locked` 信号作为全局异步复位/同步释放信号，保证时钟稳定后才启动状态机。

### 2. 串口接收与数据拼装 (`uart_rx.v`)
- 采用 16 倍过采样中点采样机制，有效滤除抖动与亚稳态。
- 引入 `byte_cnt` 状态，每连续接收 3 个 Byte 组合为一个完整的 24-bit 像素数据：
  - Byte 0: `rx_data[7:0]` (Blue)
  - Byte 1: `rx_data[15:8]` (Green)
  - Byte 2: `rx_data[23:16]` (Red)
- 组合完成后输出单个周期的 `rx_data_flag` 写入脉冲。

### 3. 双口 RAM 写控制 (`ram2_wr_ctrl.v`)
- 将 `rx_data_flag` 作为写使能 `wren`。
- 写地址从 `0` 自动递增至 `35999`（对应 $200 \times 180 = 36000$ 像素点）。
- 接收完一帧后写地址自动归零，支持动态循环刷新显存。

### 4. 显存单元 (`my_dpram`)
- 利用 Altera 内部 Block RAM 生成的 True Dual-Port RAM，深度 65536（实际使用 36000），位宽 24-bit。
- 实现了低速串口写入时钟域与高速 VGA 扫描时钟域的隔离。

### 5. VGA 控制与显示开窗 (`vga_ctrl.v`)
- **标准 SVGA 时序（800×600 @ 60Hz，像素时钟 40MHz）**：
  - 行扫描（H-Sync）：同步 128，后沿 88，有效 800，前沿 40，周期共 1056。
  - 场扫描（V-Sync）：同步 4，后沿 23，有效 600，前沿 1，周期共 628。
- **居中显示坐标**：
  - 列区间：$516 \le \text{cnt1} < 716$（跨度 200 点）。
  - 行区间：$237 \le \text{cnt2} < 417$（跨度 180 行）。
  - 在有效开窗区域内激活读地址递增，并将显存读出的 RGB888 数据送至 ADV7123 DAC 输出；非显示区域送纯黑消隐信号。

---

## 目录结构说明

```text
FPGA-UART-VGA-Display/
│
├── .gitignore                    # Git 忽略文件（过滤编译中间文件和仿真缓存）
├── README.md                     # 项目工程说明文档
│
├── uart_vga/
│   ├── src/                      # Verilog RTL 核心源代码
│   │   ├── uart_vga.v            # 系统顶层模块
│   │   ├── uart_rx.v             # 串口接收与 24-bit 拼装模块
│   │   ├── ram2_wr_ctrl.v        # 双口 RAM 写控制器
│   │   └── vga_ctrl.v            # VGA 控制器与开窗逻辑
│   │
│   ├── sim/                      # 仿真测试目录
│   │   └── uart_vga_tb.v         # ModelSim Testbench 激励文件
│   │
│   └── q_prj/                    # Quartus II 工程目录
│       ├── uart_vga.qpf          # Quartus 工程文件
│       ├── uart_vga.qsf          # 引脚约束与工程配置
│       ├── my_pll.qip / .v       # PLL IP 核
│       ├── my_dpram.qip / .v     # 双口 RAM IP 核
│       └── output_files/
│           └── uart_vga.sof      # 编译生成的 FPGA 烧录配置文件
│
└── Msim/                         # 预配置的 ModelSim 独立仿真工作区
```

---

## 快速使用指南

### 1. 编译与综合
1. 打开 Quartus II 13.1 或更高版本。
2. 点击 **File -> Open Project**，选中 `uart_vga/q_prj/uart_vga.qpf`。
3. 点击 **Processing -> Start Compilation** 开始全编译。
4. 编译成功后，在 `output_files/` 目录下将生成 `uart_vga.sof` 编程文件。

### 2. 引脚下载与测试
1. 使用 USB-Blaster II 连线连接板卡（DE1-SoC）。
2. 打开 Quartus Programmer，加载 `uart_vga.sof` 并点击 **Start** 下载到 FPGA。
3. 将板载 VGA 端口连接至显示器，此时屏幕中央应为黑色矩形区域。
4. 使用串口助手（波特率设置为 **115200, 8 数据位, 1 停止位, 无校验**），按顺序发送 36,000 组 RGB（共 108,000 字节）的图片十六进制数据，屏幕中央即可实时呈现接收到的图像。
