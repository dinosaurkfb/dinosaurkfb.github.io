---
layout: post
title: "ChibiOS 开发指导之三 - 内核代码简介"
description: ""
category: 
tags: [ChibiOS, RTOS, core]
---


本文适用于以下场景：

1. 基于 ChibiOS 做嵌入式应用开发
2. 学习 ChibiOS 内核或驱动源代码

前面两篇讲了整个 ChibiOS 源码的整体结构和如何编译开发，下面这篇呢，围绕着操作系统的核心展开一些论述，看看一个典型的操作系统的内核构成：

	E:\temp\ChibiOS-RT\os>ls -1
	hal
	kernel
	ports
	various

## HAL

HAL 就是硬件抽象层(Hardware Abstraction Layer)，它将特定硬件平台的细节封装在内部，对外提供一套统一的接口，使得操作系统和上层应用尽可能不依赖于这些特定的硬件。

	E:\temp\ChibiOS-RT\os\hal>ls -1
	dox
	hal.dox
	hal.mk
	include
	platforms
	src
	templates

hal.mk, include, src 是 HAL 层的与特定硬件无关的部分，它们的作用就是要衔接上层应用和底层硬件驱动程序，它要求每一套不同的底层硬件驱动程序都提供一套一致的供其调用的接口，这些不同平台的驱动程序就放在 platforms 目录中：

	E:\temp\ChibiOS-RT\os\hal\platforms>ls -1
	AT91SAM7
	AVR
	LPC11Uxx
	LPC11xx
	LPC122x
	LPC13xx
	LPC17xx
	LPC214x
	LPC8xx
	MSP430
	...

所有的 SOC 级的驱动都应放在 platforms 目录下它们对应的平台子目录中。驱动的接口要符合 ChibiOS 的 HAL 层的接口要求。 HAL 层的详细文档在 *[这里](http://chibios.sourceforge.net/docs/kernel_hal_rm/group___i_o.html)*

## kernel

	E:\temp\ChibiOS-RT\os\kernel>ls -1
	include
	kernel.dox
	kernel.mk
	src
	templates

	E:\temp\ChibiOS-RT\os\kernel\src>ls -1
	chcond.c
	chdebug.c
	chdynamic.c
	chevents.c
	chheap.c
	chlists.c
	chmboxes.c
	chmemcore.c
	chmempools.c
	chmsg.c
	chmtx.c
	chqueues.c
	chregistry.c
	chschd.c
	chsem.c
	chsys.c
	chthreads.c
	chvt.c

kernel 目录涵盖了四大功能：

1. 基本的内核服务，包括系统管理、调度器、线程、虚拟定时器等、条件变量、事件、内存管理等。
2. 同步原语，包括信号量、二进制信号量、互斥、条件变量、事件标志、同步消息、邮件箱、I/O 队列。
3. 内存管理，包括核心内存管理模块、堆、内存池，动态线程。
4. 流和文件，包括抽象串行流和抽象文件流。

## ports

任何操作系统都有一部分最接近处理器的代码，这部分代码往往由汇编语言写成，不同的处理器以及不同的编译器支持的汇编语言语法各有差异，这些差异就是操作系统移植过程中最困难的部分。 ChibiOS 操作系统把这部分代码放在了 ports 目录，首先按照编译器的不同划分：

	E:\temp\ChibiOS-RT\os\ports>ls -1
	GCC
	IAR
	RVCT
	common
	ports.dox


进到每一个编译器下又按照体系结构、处理器系列来划分：

	E:\temp\ChibiOS-RT\os\ports>ls -1 GCC
	ARM
	ARMCMx
	AVR
	MSP430
	PPC
	SIMIA32

	E:\temp\ChibiOS-RT\os\ports>ls -1 GCC\ARMCMx
	LPC11xx
	LPC122x
	LPC13xx
	LPC17xx
	LPC8xx
	SAM4L
	STM32F0xx
	STM32F1xx
	STM32F2xx
	STM32F3xx
	STM32F4xx
	STM32L1xx
	chcore.c
	chcore.h
	chcore_v6m.c
	chcore_v6m.h
	chcore_v7m.c
	chcore_v7m.h
	chtypes.h
	crt0.c
	port.dox
	rules.mk

整个项目的编译规则定义在上面目录里的 rules.mk 文件中。关于这个目录里的核心代码，如果想进一步了解的话，就直接看代码吧，细节部分不是一两句能讲清楚的。需要说明一下的是，整套代码的链接脚本就在 ports 目录的每一个最底层的子目录里：

	E:\temp\ChibiOS-RT\os\ports>ls -1 GCC\ARMCMx\LPC17xx\ld
	LPC1766.ld
	LPC1768.ld
	LPC1788.ld


	E:\temp\ChibiOS-RT\os\ports>ls -1 common
	ARMCMx


	E:\temp\ChibiOS-RT\os\ports>ls -1 common\ARMCMx
	CMSIS
	nvic.c
	nvic.h
	port.dox

## various

	E:\temp\ChibiOS-RT\os>ls -1 various
	chprintf.c
	chprintf.h
	chrtclib.c
	chrtclib.h
	cpp_wrappers
	devices_lib
	evtimer.c
	evtimer.h
	fatfs_bindings
	lwip_bindings
	memstreams.c
	memstreams.h
	shell.c
	shell.h
	syscalls.c
	update.c
	update.h
	various.dox

various 目录中放的东西比较杂，一些与操作系统相关、具有一定的通用性、但又不是必需的一些模块都可以放在这里，比如 打印接口 printf 、命令行接口 shell 、升级模块 update、与文件系统的接口 fatfs\_bindings、与 TCP/IP 协议栈的接口 lwip\_bindings、操作系统服务的 C++ 封装 cpp\_wrappers，以及非片内外设的驱动库 devices\_lib。这些模块需要的时候手动加入到项目的 makefile 中即可。另外，如果你开发的模块具有一定的通用性，同时也想贡献给 ChibiOS-RT 项目，那么可以考虑放在 various 目录，作为一个可选的模块提供给使用者。比如， update 模块就是我后来添加的。

-------------------------------------------------------------------------------

*上一篇*：*[ChibiOS 开发指导之二 - 开始编译]({{ site.url }}/2014/02/22/ChibiOSSrcCompile/)*
