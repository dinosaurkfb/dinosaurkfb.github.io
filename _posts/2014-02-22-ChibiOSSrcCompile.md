---
layout: post
title: "ChibiOS 开发指导之二 - 开始编译"
description: ""
category: 
tags: [ChibiOS, RTOS, 源代码, ISP, IAP, 编译]
---


#适用场景
本文适用于以下场景：

1. 基于 ChibiOS 做嵌入式应用开发
2. 学习 ChibiOS 内核或驱动源代码

## 准备

下面我们拿其中一个目录来讲解一下，如何开始编译、开发这套代码，如果你要开始一个新项目，那么只需要找一个最接近你硬件平台的这样一个目录为模板，拷贝后修改一下不一致的地方就可以了。以 demos、testhal 下的子目录为模板都可以，这里我们以 testhal\LPC17xx\1768\I2C 为例进行讲解：

	E:\temp\ChibiOS-RT\testhal\LPC17xx\1768\I2C>ls -1
	
	Makefile
	chconf.h
	halconf.h
	main.c
	mcuconf.h
	ver.h

## Makefile

先来看看 Makefile，最上面的部分定义了一些编译器选项、链接器选项等，这里基于篇幅所限，没有列出，不展开讲，后面用到的时候再单独讲。我们只看这些一般项目中会用到的部分：

	# Define project name here
	PROJECT = ch

	# Imported source files and paths
	CHIBIOS = ../../../..
	include $(CHIBIOS)/boards/HY-LandTiger_1768/board.mk
	include $(CHIBIOS)/os/hal/platforms/LPC17xx/platform.mk
	include $(CHIBIOS)/os/hal/hal.mk
	include $(CHIBIOS)/os/ports/GCC/ARMCMx/LPC17xx/port.mk
	include $(CHIBIOS)/os/kernel/kernel.mk
	include $(CHIBIOS)/os/various/devices_lib/devices_lib.mk
	include $(CHIBIOS)/test/test.mk

	# Define linker script file here
	LDSCRIPT= $(PORTLD)/LPC1768_isp.ld

	# C sources that can be compiled in ARM or THUMB mode depending on the global
	# setting.
	CSRC = $(PORTSRC) \
		   $(KERNSRC) \
		   $(TESTSRC) \
		   $(HALSRC) \
		   $(PLATFORMSRC) \
		   $(BOARDSRC) \
		   $(DEVICESLIBSRC) \
		   $(CHIBIOS)/os/various/evtimer.c \
		   $(CHIBIOS)/os/various/syscalls.c \
		   $(CHIBIOS)/os/various/chprintf.c \
		   main.c

这里，可以修改项目名称 PROJECT、ChibiOS 源码的根目录 CHIBIOS。

	include $(CHIBIOS)/boards/HY-LandTiger_1768/board.mk

把这里的 HY-LandTiger_1768 替换为你所用的开发板，并确保 boards 目录中该开发板的子目录下已设置好相应的 mk 文件和板级文件 board.c 和 board.h 。

	include $(CHIBIOS)/os/hal/platforms/LPC17xx/platform.mk
	include $(CHIBIOS)/os/ports/GCC/ARMCMx/LPC17xx/port.mk

这两个地方的 LPC17xx 修改为你对应的平台。

	LDSCRIPT= $(PORTLD)/LPC1768_isp.ld

这里的 LPC1768 修改为你所用处理器的链接脚本。

在实际项目中，针对每一种处理器，链接脚本又分为带 IAP 的版本、带 ISP 的版本和原生版本，这里所说的 IAP 和 ISP 都是指通过软件手段自动升级，而不需要通过硬件操作来打开系统的 ISP 使能管脚。这种机制在原来的 ChibiOS/RT 源代码中没有，是我后来加的，这里简要介绍一下：
### 自动 ISP 机制
以 NXP 的处理器为例，我们知道它是通过使能 ISPEN 信号来使系统运行 ISP 固件的，这种方法在开发阶段没什么问题，但是在产品实施阶段，或者交付后，这样做就有很大的问题，因为这种方法意味着产品外观上要留有打开 ISPEN 信号的开关，它所引起的问题有这样几方面：

1. 影响美观。现在的产品都追求简洁之美，软件能解决的就不要增加额外的硬件。
2. 增加产品结构上的复杂度，结构上复杂度的增加则意味着生产成本、组装成本的增加，结构的复杂及其带来的零部件增多还会增加采购、元器件供应方面的不可控环节。
3. 容易误操作，不安全。对于用户来说，暴露出来的开关一定会有可能导致一些误操作。这对于企业的售后服务来说，无疑会增加工作量，严重的还会影响企业形象。
4. 更有甚者，产品的安装环境很苛刻，根本就无法直接接触到设备，这在工业场合很常见。

基于上述问题，我们公司设计了一种软件自动 ISP 的机制，它的原理是：

1. 设计一套用于 PC 机和产品中的用户程序（APP）进行通讯的串口协议。
2. 开发一套 PC 机软件，通过该协议与产品中的软件协商是否可以升级。
3. 如果可以升级，则 APP 擦除 FLASH 中的 0 扇区，然后通过看门狗使系统复位。
4. 系统复位后发现 0 扇区的用户程序无效，于是开始运行芯片固件程序，等待 ISP。
5. PC 机调用 FlashMagic 的接口开始 ISP 升级。

为了安全，我们的协议必须要有一定的验证措施，防止误升级无效的用户程序。链接脚本 LPC1768_isp.ld 中的这一部分就是用来指定验证信息的链接地址：

	. = 0xd0;
	KEEP(*(.update_cfg))

具体的配置信息，可以参考 `os/various/update.c` 和 `os/various/update.h`。


有了这样一套机制，就可以在 PC 机上一键完成用户程序的升级，非常方便。那么，既然已经这么方便了，为什么还需要什么自动 IAP 呢？嘿嘿，我可以负责任地说，很有必要！

### IAP机制
我们知道串口 RS232 是点对点的，它是不支持组网的，那也就是意味着交付出去的产品只能一对一的升级。这种方式对于大多数公司问题不大。但是对于有些公司，比如我以前的公司，做列车电子设备的，他们的产品特点是：

1. 设备必须组网，有主控端，有显示端，有被控端或采集端，他们通过工业网络连接成一个分布式控制系统，也有叫集散控制系统（Distributed Control System）的。
2. 设备种类多，每一类设备在一个网络中可能有一个，也可能有十个，几十个。
3. 设备极度分散，基本上分布在每节车厢。
4. 设备安装、调试条件苛刻，有些要拆卸机箱、机架、甚至列车包厢的墙壁。
5. 现场部署、售后服务人手非常有限。

在这种条件下，如果设备只能支持串口的自动 ISP 机制，那不仅仅是效率不够高的问题了，而是只能大呼：臣妾做不到啊！


基于这样的背景，我们开发了一套自动 IAP 系统，这套系统采用的机制是把最终生成的 hex 文件分为两部分，一部分成为 BOOT 程序，另一部分成为用户程序，BOOT 程序保持不变，每次升级时只需要升级用户程序。下面先看一张流程图：
	
![IAP_LOGIC]({{ site.url }}/images/IAP_LOGIC.jpg)

#### BOOT 程序
系统复位时，启动代码（严格的说这部分也是属于 BOOT 程序的一部分）首先会检查一个标志扇区，如果该标志扇区有效，则跳到用户程序的入口，把控制权交给用户程序。如果标志扇区无效，则 BOOT 程序则进入自己的程序逻辑，即扫描 UART0 和 CAN0 端口，等待升级包的出现。BOOT 程序不需要带操作系统，它的主要作用就是通过 CAN0 来升级用户程序，这样做的目的上面已经讲述过了。当然，BOOT 程序仍然支持自动 ISP 方式的升级，以便于升级 BOOT 程序自身。


### 用户程序
我们这里讲述和即将编译的都是用户程序，从前面的讲述可以看出，在 IAP 机制下，BOOT 程序的中断向量表位于 0 地址，所以用户程序的中断向量表必须映射到其他地址，这一设置就是通过 IAP 版本的链接脚本来实现的:

	flash : org = 0x00008000, len = 512k - 32k

这里也顺便提醒一下，通过 FlashMagic 单独烧写用户程序到芯片中是无法运行的，因为中断向量表的链接地址和烧写地址对不上，必须通过我们的工具 HexMerger 把 BOOT 程序和用户程序合为一个 HEX 文件再烧写才可以。


IAP 的话题先讲到这里，我们继续回来讲 Makefile, 如果你的项目所选用的处理器不是 cortex-m3 架构的，那么将此处的 MCU 值修改为其他架构，例如： arm7, cortex-m3 等：

	MCU  = cortex-m3

此 Makefile 中剩下的部分基本不需要再动。

## chconf.h

chconf.h 是定义操作系统的一些重要信息，一般不需要改变，需要改变时看代码里的注释即可。
需要说明一下的是这一部分：


	#define ENABLE_IAP                          TRUE

	#if ENABLE_IAP
	/**
	 * @brief   NVIC VTOR initialization expression.
	 */
	#define CORTEX_VTOR_INIT                0x00008000

	#endif /* #if ENABLE_IAP */

这一部分也是为了配合 IAP 机制而设的，需要打开 IAP 时，将 ENABLE_IAP 开关设为 TRUE，否则设为 FALSE 。

## halconf.h

halconf.h 是用于配置硬件抽象层的一些开关和变量，例如，HAL\_USE\_SPI 用于配置是否打开 SPI，所有这些模块如果你的项目中没有使用，建议全部设为 FALSE, 将其关闭，这样做一是可以减小功耗，二可以减小二进制文件的尺寸。

仔细观察可以看出, halconf.h 是与平台无关的，这也正是 HAL （硬件抽象层）的意义所在。
## mcuconf.h

mcuconf.h 用于配置芯片的一些参数，例如：主时钟选择，主PLL 配置，外围时钟配置等等，这部分定义非常重要，请配合时钟初始化代码自行研究，以 LPC1768 为例，时钟初始化代码位于 ChibiOS-RT\os\hal\platforms\LPC17xx\

mcuconf.h 中还有一些宏定义是用于配置底层模块的，这部分是位于 HAL 层之下的，是与芯片平台相关的，所以放在这里最合适。

## ver.h

ver.h 中定义了设备的 ID 和用户程序的版本号，这在实际项目中都是必须要考虑的，前面讲过的 ISP、IAP 机制也会用到这两个值。

## main.c

main.c 是用户程序的入口，它负责初始化 HAL、操作系统，启动所需的 HAL 模块，启动升级线程，创建工作线程等等：
	
	halInit();
	chSysInit();

	updateThreadStart();
	gptStart(&GPTD1, &gpt1cfg);

UART0 一般用来做为 printf 的打印输出端口，它的初始化我放到了 boardInit 里了，因为只有它工作了，才能更方便的调试。

# 编译
好了，一切准备就绪就可以开始编译了，在当前目录执行 make 就可以了：

	E:\temp\ChibiOS-RT\testhal\LPC17xx\1768\I2C>make
	Compiler Options
	arm-none-eabi-gcc -c -mcpu=cortex-m3 -O2 -ggdb -fomit-frame-pointer -ffunction-sections -fdata-sections -fno-common -Wall -Wextra -Wstrict-prototypes
	-Wa,-alms=build/lst/ -DLPC17XX -D__NEWLIB__ -DTHUMB_PRESENT -mno-thumb-interwork -DTHUMB_NO_INTERWORKING -MD -MP -MF .dep/build.d -I. -I../../../../os
	/ports/common/ARMCMx/CMSIS/include -I../../../../os/ports/common/ARMCMx -I../../../../os/ports/GCC/ARMCMx -I../../../../os/ports/GCC/ARMCMx/LPC17xx -I
	../../../../os/kernel/include -I../../../../test -I../../../../os/hal/include -I../../../../os/hal/platforms/LPC17xx -I../../../../boards/HY-LandTiger
	_1768 -I../../../../os/various/devices_lib/ -I../../../../os/various/devices_lib/accel/ -I../../../../os/various/devices_lib/eeprom/ -I../../../../os/
	various main.c -o main.o

	mkdir -p build/obj
	mkdir -p build/lst
	Compiling crt0.c
	Compiling vectors.c
	Compiling chcore.c
	Compiling chcore_v7m.c
	Compiling nvic.c
	Compiling chsys.c
	Compiling chdebug.c
	Compiling chlists.c
	Compiling chvt.c
	Compiling chschd.c
	...

有时候需要清除一下编译文件：

	E:\temp\ChibiOS-RT\testhal\LPC17xx\1768\I2C>make clean
	Cleaning
	rm -fR .dep build
	Done

注意，该命令会删除 .dep 和 build 两个子目录，不要在这两个目录放重要的文件。此外，如果这两个目录中的文件被占用（常出现的情况是 build 目录中的 HEX 文件被 FlashMagic 或者 ISP、IAP 升级软件占用），那么 make clean 会失败：

	E:\temp\ChibiOS-RT\testhal\LPC17xx\1768\I2C>make clean
	Cleaning
	rm -fR .dep build
	rm: cannot remove directory `build': Permission denied
	make: [clean] Error 1 (ignored)
	Done

而且这会影响到下次 make 也失败：

	E:\temp\ChibiOS-RT\testhal\LPC17xx\1768\I2C>make
	Compiling crt0.c
	Assembler messages:
	Fatal error: can't create build/obj/crt0.o: No such file or directory
	make: *** [build/obj/crt0.o] Error 1

遇到这种情况时，关闭一下占用 build 目录的软件再重新 make clean 就可以了。


本篇结束。

-------------------------------------------------------------------------------

*上一篇*：*[ChibiOS 开发指导之一 - 源码结构浅析]({{ site.url }}/2014/02/18/ChibiOSSrcDesc/)* <br/> *下一篇*：*[ChibiOS  开发指导之三 - 内核代码简介]({{ site.url }}/2014/02/22/ChibiOSCoreDesc/)*
