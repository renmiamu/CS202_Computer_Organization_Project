# CS202_Computer_Organization

**小组成员：沈泓立、郑袭明、刘安钊**

------

### 开发者说明

| 姓名   | 学号     | 负责内容                                   | 贡献比 |
| ------ | -------- | ------------------------------------------ | ------ |
| 沈泓立 | 12311016 | CPU和IO部分的实现与测试，文档写作          | 1/3    |
| 郑袭明 | 12311011 | CPU硬件测试，VGA，uart，文档写作           | 1/3    |
| 刘安钊 | 12311020 | CPU硬件测试，测试场景1+2汇编代码，文档写作 | 1/3    |

### 开发日程

#### 原计划

- 5.1 - 5.5 CPU子模块实现
- 5.6 - 5.11 CPU顶层模块+子模块测试
- 5.12 - 5.18 测试场景1+2测试
- 5.19 - 5.25 bonus部分实现

#### 实际安排

- 5.1 - 5.5 CPU子模块实现
- 5.6 - 5.11 CPU顶层模块+子模块测试
- 5.12 - 5.18 CPU顶层模块仿真测试
- 5.19 - 5.21 测试场景1通过+VGA
- 5.22 - 5.23 测试场景2通过+uart
- 5.24 文档协作

### CPU架构设计说明

#### CPU特性

**ISA**：

| R-type | opcode  | funct3 | funct7   | 使用方法                |
| ------ | ------- | ------ | -------- | ----------------------- |
| add    | 0110011 | 000    | 000_0000 | rd = rs1 + rs2          |
| sub    | 0110011 | 000    | 010_0000 | rd = rs1 - rs2          |
| xor    | 0110011 | 100    | 000_0000 | rd = rs1 ˆ rs2          |
| or     | 0110011 | 110    | 000_0000 | rd = rs1 \| rs2         |
| and    | 0110011 | 111    | 000_0000 | rd = rs1 & rs2          |
| sll    | 0110011 | 001    | 000_0000 | rd = rs1 « rs2          |
| srl    | 0110011 | 101    | 000_0000 | rd = rs1 » rs2          |
| sra    | 0110011 | 101    | 010_0000 | rd = rs1 » rs2 (Arith*) |
| slt    | 0110011 | 010    | 000_0000 | rd = (rs1 < rs2)?1:0    |
| sltu   | 0110011 | 011    | 000_0000 | rd = (rs1 < rs2)?1:0    |

| I-type-1 | opcode  | funct3 | funct7             | 使用方法                     |
| -------- | ------- | ------ | ------------------ | ---------------------------- |
| addi     | 0010011 | 000    | null               | rd = rs1 + imm               |
| xori     | 0010011 | 100    | null               | rd = rs1 ˆ imm               |
| ori      | 0010011 | 110    | null               | rd = rs1 \| imm              |
| andi     | 0010011 | 111    | Null               | rd = rs1 & imm               |
| slli     | 0010011 | 001    | imm[11:5]=000_0000 | rd = rs1 « imm[4:0]          |
| srai     | 0010011 | 101    | imm[11:5]=010_0000 | rd = rs1 » imm[4:0] (Arith*) |
| srli     | 0010011 | 101    | imm[11:5]=000_0000 | rd = rs1 » imm[4:0]          |

| I-type-2 | opcode  | 使用说明                                                     |
| -------- | ------- | ------------------------------------------------------------ |
| lw       | 0000011 | 在IO输入过程中，我们通过switch取值范围来区分lb, lh, lw, lbu, lhu |

| S-type | opcode  | 使用方法                      |
| ------ | ------- | ----------------------------- |
| sw     | 0100011 | M \[rs1+imm][31:0]= rs2[31:0] |

| B-type | opcode  | funct3 | 使用方法                            |
| ------ | ------- | ------ | ----------------------------------- |
| beq    | 1100011 | 000    | if(rs1 == rs2) PC = PC + {imm,1’b0} |
| bne    | 1100011 | 001    | if(rs1 != rs2) PC = PC + {imm,1’b0} |
| blt    | 1100011 | 100    | if(rs1 < rs2) PC = PC + {imm,1’b0}  |
| bge    | 1100011 | 101    | if(rs1 >= rs2) PC = PC + {imm,1’b0} |
| bltu   | 1100011 | 110    | if(rs1 < rs2) PC = PC + {imm,1’b0}  |
| bgeu   | 1100011 | 111    | if(rs1 >= rs2) PC = PC + {imm,1’b0} |

| J-type | opcode  | 使用方法                        |
| ------ | ------- | ------------------------------- |
| jal    | 1101111 | rd = PC+4; PC = PC + {imm,1’b0} |

| I-type-3 | opcode  | func3 | 使用方法                  |
| -------- | ------- | ----- | ------------------------- |
| jalr     | 1100111 | 000   | rd = PC+4; PC = rs1 + imm |

| U-type | opcode  | 使用方法      |
| ------ | ------- | ------------- |
| lui    | 0110111 | rd = imm « 12 |

| bonus |      |      |      |
| ----- | ---- | ---- | ---- |
| auipc |      |      |      |
| ecall |      |      |      |

**参考的ISA**：RISC-V，具体使用方式请详见RISC-V Reference Card

**寄存器说明**：

​	本项目按照RISC-V 标准定义了 32 个通用寄存器，每个寄存器 32 位宽度：

- x0: 始终为零
- x1-x31: 通用寄存器，用于数据和地址操作

该CPU属于**单周期CPU**，不支持pipeline

**CPU时钟周期**：

**寻址空间设计**：

**外设IO设计**：采用`MMIO`设计方案，根据地址来判断switch读取比特数以及采用LED输出或数码管输出，具体如下：

| IO-input                        | 地址          |
| ------------------------------- | ------------- |
| switch读取`confirm`按钮（1bit） | 32'hffff_ff00 |
| switch读取16位按键              | 32'hffff_fff1 |
| switch读取高8位（unsigned）     | 32'hffff_fff3 |
| switch读取低8位（signed）       | 32'hffff_fff5 |
| switch读取低3位（unsigned）     | 32'hffff_fff7 |
| switch读取低8位（unsigned）     | 32'hffff_fff9 |

| IO-output          | 地址          |
| ------------------ | ------------- |
| 数码管显示16进制数 | 32'hffff_fff0 |
| LED灯亮右侧8个     | 32'hffff_ffc2 |
| 数码管显示10进制数 | 32'hffff_ffc4 |
| VGA输出            |               |

#### CPU接口

```verilog
module CPU (
    input clk,                  // 原始时钟 100MHz
    input reset,                // 全局复位
    input [15:0] switchInput,   // 来自拨码开关的输入
    input enter,         // 模拟确认按键
    input start_pg,     //recieve data by UART
    input rx,           //send data by UART

    output tx,
    output [7:0] tubSel,        // 数码管位选
    output [7:0] seg_led1234,       // 左侧段选
    output [7:0] seg_led5678,      // 右侧段选
    output [15:0] dataOut,
    output [3:0] r,
    output [3:0] g,
    output [3:0] b,
    output hs,
    output vs
);
```

**IO输出接口说明**：