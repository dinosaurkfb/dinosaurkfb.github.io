---
layout: post
title: "ChibiOS 开发指导之一 - 源码结构浅析"
description: ""
category: 
tags: [ChibiOS, RTOS, 源代码]
---


#适用场景
本文适用于以下场景：

1. 基于 ChibiOS 做嵌入式应用开发
2. 学习 ChibiOS 内核或驱动源代码

做嵌入式开发需要一个好的平台，一个好的实时操作系统（RTOS）恐怕是这个平台中最关键的部分了，我在做 RTOS 选择的时候主要基于如下一些考虑：

1. 开源
2. 稳定性经过长期的验证
3. 性能足够
3. 有不错的社区支持
4. 支持广泛的硬件平台
5. 代码简洁，代码结构清晰

经过一系列的调研后，我选择了 [*ChibiOS/RT*](http://www.chibios.org/dokuwiki/doku.php) 这个操作系统，虽然这个系统在国内用的不多，但是从它的 [*社区*](http://forum.chibios.org/phpbb/index.php) 来看，国外还是有不少用户的，其他指标也都满足我的需求，尤其是代码结构很清晰，嵌入式开发所需要的一切都在掌握之中，便于学习和使用，下面我们先快速的浏览一下它的整体结构：


## 整体结构

一套长期使用的代码其实就像是你的恋人，至少要赏心悦目吧。而整套代码的要素中，代码结构的重要性好比人的穿着。如果一个人把袜子套在脑袋上，裤子穿在胳膊上，别说把她当恋人了，恐怕在路上见过一面你就不想再见她第二面了。而一套穿的比较好看的代码，的确能让人工作起来更加身心愉悦。 我看 ChibiOS 的代码的时候就深有这种体会，我们先来看一下源码树的整体结构：

	E:\temp\ChibiOS-RT>ls -1

	boards
	demos
	docs
	documentation.html
	exception.txt
	ext
	license.txt
	os
	private
	readme.txt
	test
	testhal

简要说明一下：

	* boards   板级相关的配置和初始化
	* demos    针对某一种板子某一功能的演示示例
	* docs     源码生成的文档
	* ext      可以与ChibiOS配合使用的一些附加模块
	* os       操作系统内核、硬件抽象层等相关代码
	* private  私有模块的一些代码（这是我后来加入的）
	* test     操作系统相关的测试用例
	* testhal  硬件抽象层相关的测试示例

下面我们挨个目录详细来讲：

## boards 目录

boards 目录示例（由于篇幅所限，部分子目录已省略）：

	E:\temp\ChibiOS-RT\boards>ls -1

	ARDUINO_MEGA
	EA_LPCXPRESSO_BB_1114
	EA_LPCXPRESSO_BB_11U14
	EA_LPCXPRESSO_BB_1343
	EA_LPCXPRESSO_LPC812
	HY-LPC1788
	HY-LandTiger_1768
	MAPLEMINI_STM32_F103
	NGX_BB_LPC11U14
	NONSTANDARD_STM32F4_BARTHESS1
	OLIMEX_AVR_CAN
	OLIMEX_AVR_MT_128
	OLIMEX_LPC-P1227
	OLIMEX_LPC_P1343
	OLIMEX_LPC_P2148
	...

嵌入式开发面对的就是一个个的板子，与板子相关的配置和初始化都在 boards 目录中，注意，仅仅是与板子相关的，与片上外设相关的不在这里面。 boards 下面的子目录一般有这样三个文件：

	board.h
	board.c
	board.mk

适合放在 board 中的配置包括：

* GPIO 管脚输入、输出定义
* LED 灯、按键的定义以及操作接口
* 片外芯片的选择，如 EEPROM 的选择及其 I2C 地址
* 打印串口的选择，配置及其初始化

另外，板载 SOC 的时钟初始化也是通过 `__early_init` 接口在此调用的，该接口是除了 SOC 启动代码外最开始就会调用的。

## demos 目录

demos 目录示例（由于篇幅所限，部分子目录已省略）：

	E:\temp\ChibiOS-RT\demos>ls -1
	
	ARM7-AT91SAM7X-FATFS-GCC
	ARM7-AT91SAM7X-GCC
	ARM7-AT91SAM7X-LWIP-GCC
	ARM7-AT91SAM7X-UIP-GCC
	ARM7-LPC214x-FATFS-GCC
	ARM7-LPC214x-G++
	ARM7-LPC214x-GCC
	ARMCM0-LPC1114-LPCXPRESSO
	ARMCM0-LPC11U14-LPCXPRESSO
	ARMCM0-STM32F051-DISCOVERY
	ARMCM0P-LPC812-LPCXPRESSO
	ARMCM3-GENERIC-KERNEL
	ARMCM3-LPC1343-LPCXPRESSO

demos 下面的子目录都是针对某一种板子某一功能的演示示例，主要用于展示某一型号板子的功能或者基于某一型号板子做一些功能特性的演示。

### docs 目录

	E:\temp\ChibiOS-RT\docs>ls -1

	Doxyfile_chm
	Doxyfile_html
	html
	index.html
	readme.txt
	reports
	rsc
	src

docs 目录里面是源代码生成的文档，具体的如何生成这里暂不讲述。

### ext 目录

	E:\temp\ChibiOS-RT\ext>ls -1
	
	ext.dox
	fatfs-0.9-patched.zip
	lwip-1.4.1_patched.zip
	readme.txt
	uip-1.0.patches.zip
	uip-1.0.tar.gz

ext 目录里是项目中可能会用到的一些外围模块（ChibiOS/RT 之外的其他项目），例如 fatfs, lwip, uip 等。默认情况下这里面都是压缩包，需要用的时候把他们解压出来就行。使用示例可以看看 `ChibiOS-RT/os/various/` 下面的 fatfs\_bindings 和 lwip\_bindings 。

### os 目录

	E:\temp\ChibiOS-RT\os>ls -1

	hal
	kernel
	ports
	various

os 目录是 ChibiOS/RT 最核心的代码，其子目录含义如下：

	hal         硬件抽象层及其底层的各个平台的驱动
	kernel      操作系统内核
	ports       操作系统中跟硬件平台、编译器相关的代码
	various     操作系统的其他辅助模块

os 目录的详细介绍见这篇文章：*[ChibiOS 内核代码简介]({{ site.url }}/2014/02/24/ChibiOSCoreDesc/)*

### private 目录

private 是我后来添加的，里面可以放我们自己的项目以及不便公开的私有代码等等，大家可以按照自己的意愿去使用。我的用法是在这里面建立了一个子目录用于管理自己公司开发的中间件，这部分代码通过 bitbucket 上的私有仓库来管理，然后跟整个 ChibiOS/RT 代码通过 git submodule 来组合到一起。

### test 目录

	E:\temp\ChibiOS-RT\test>ls -1
	
	coverage
	test.c
	test.dox
	test.h
	test.mk
	testbmk.c
	testbmk.h
	testdyn.c
	testdyn.h
	testevt.c
	testevt.h
	testheap.c
	testheap.h
	testmbox.c
	testmbox.h
	testmsg.c
	testmsg.h
	testmtx.c
	testmtx.h
	testpools.c
	testpools.h
	testqueues.c
	testqueues.h
	testsem.c
	testsem.h
	testthd.c
	testthd.h

test 目录中是操作系统的测试用例，如果你把 ChibiOS 移植到了一个新的平台，最好跑一遍这里面的测试用例。

### testhal 目录

	E:\temp\ChibiOS-RT\testhal>ls -1

	LPC11xx
	LPC122x
	LPC13xx
	LPC17xx
	SPC560Pxx
	SPC563Mxx
	SPC56ELxx
	STM32F0xx
	STM32F1xx
	STM32F30x
	STM32F37x
	STM32F4xx
	STM32L1xx
	common

testhal 下的子目录和 demos 下的子目录的结构差不多，只不过 testhal 下的子目录侧重于测试某一平台的 hal 层。例如，我在 LPC17xx 目录下面又建立了 1768, 1788 等子目录，它们每个下面又有 I2C, GPT, EXT, Serial 等目录，而这些目录里面就是分别对应各自模块的测试代码。我觉得这样开发起来会比较清晰。

下一篇文章，我们就开始从这个目录讲述如何开始动手开发，编译。*[去看看？]({{ site.url }}/2014/02/22/ChibiOSSrcCompile/)*

-------------------------------------------------------------------------------

*上一篇*：*[ChibiOS 开发环境搭建之三 - contributor 篇]({{ site.url }}/2014/01/14/ChibiOSEnvironment_3_contributor/)* <br/> *下一篇*：*[ChibiOS 开发指导之二 - 开始编译]({{ site.url }}/2014/02/22/ChibiOSSrcCompile/)*
