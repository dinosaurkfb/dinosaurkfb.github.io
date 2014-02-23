---
layout: post
title: "ChibiOS 开发环境搭建之三 - Contributor 篇"
description: ""
category: 
tags: [ChibiOS, git, 开发环境]
---


#适用场景
本文适用于以下场景：

1. 基于官方 ChibiOS 的代码做开发（一般情况下是在某一分支下做驱动程序开发或应用程序开发）
2. 需要跟踪官方仓库的最新推送更新（因为官方的推送可能解决了该分支的某一BUG）

为便于描述，我们假设团队只是基于 ChibiOS 代码的某一分支进行开发，比如 stable\_2.6.x 分支，那么在此场景下，主要的工作可以按照项目的代码审核人员（下面简称 maintainer）和项目的开发组成员（下面简称 contributor）分为两大块：

### maintainer 需要做如下工作：

1. Fork 官方 ChibiOS 仓库，形成自己团队的仓库，假设名称为 origin
2. 跟踪官方的 ChibiOS 仓库，发现有更新后合并到 origin 仓库的代码中
3. 基于 Fork 之后的仓库 origin 组织团队成员开发
4. 合并其他团队成员(下面简称 contributor )的开发成果到某一稳定的分支

### contributor 的工作内容如下：

1. 基于 origin 仓库的 stable\_2.6.x 分支进行开发（这一点由 maintainer 来保证）
2. 推送自己的开发成果到开发分支

本文介绍的是 contributor 的工作流程。

# contributor 工作流程

### 1. 克隆 maintainer 创建的 origin 仓库

	E:\work> git clone https://github.com/dinosaurkfb/ChibiOS-RT.git

查看远程仓库 origin 的基本信息：

	E:\work\ChibiOS-RT> git remote -v
	
	origin  https://github.com/dinosaurkfb/ChibiOS-RT.git (fetch)
	origin  https://github.com/dinosaurkfb/ChibiOS-RT.git (push)

查看远程仓库 origin 的详细信息：

	E:\work\ChibiOS-RT> git remote show origin
	
	* remote origin
	Fetch URL: https://github.com/dinosaurkfb/ChibiOS-RT.git
	Push  URL: https://github.com/dinosaurkfb/ChibiOS-RT.git
	HEAD branch: master
	Remote branches:
    chibistudio_trunk   tracked
    kernel_3_alt_vt_dev tracked
    kernel_3_dev        tracked
    lpc17xx_dev         tracked
	master              tracked
    stable_1.0.x        tracked
    stable_1.2.x        tracked
    stable_1.4.x        tracked
    stable_2.0.x        tracked
    stable_2.2.x        tracked
    stable_2.4.x        tracked
    stable_2.6.x        tracked
    utils_dev           tracked
	Local branch configured for 'git pull':
    master merges with remote master
	Local ref configured for 'git push':
    master pushes to master (up to date)

可以看到其中有个分支叫 lpc17xx\_dev ，这个分支就是由 maintainer 基于 stable\_2.6.x 分支创建的， contributor 只需基于 lpc17xx\_dev 分支进行后续的开发工作。

### 2. checkout 远程的开发分支到本地分支

	E:\work\ChibiOS-RT> git checkout -b lpc17xx_dev  origin/lpc17xx_dev

	Branch lpc17xx_dev set up to track remote branch lpc17xx_dev from origin.
	Switched to a new branch 'lpc17xx_dev'

### 2. 基于某种大的特性，建立长期分支
LPC17xx 系列仍然有多个子集，目前有 LPC175x，LPC176x，LPC178x等。所以我们的移植工作也要一步一步来，我们先做 LPC1769 的移植工作，为此我们再建立一个本地分支：

	E:\work\ChibiOS-RT> git checkout -b lpc176x_port

	Switched to a new branch 'lpc176x_port'

下一步工作就是在 lpc176x\_port 分支上进行针对 LPC176x 平台的长期开发，提交代码。

#### 代码的编译
安装好编译环境（参见 *[ChibiOS 开发环境搭建一-编译环境篇]({{ site.url }}/2014/01/13/ChibiOSEnvironment_1_dev)*）后, 切换到此目录

`ChibiOS-RT\testhal\LPC17xx\IRQ_STORM`

然后执行 make 即可（下面示例中的部分输出信息已省略）：

	E:\work\ChibiOS-RT\testhal\LPC17xx\IRQ_STORM> make
	Compiler Options
	arm-none-eabi-gcc -c -mcpu=cortex-m3 -O2 -ggdb -fomit-frame-pointer -ffunction-sections -fdata-sections -fno-common -Wall -Wextra -Wstrict-prototypes
	-Wa,-alms=build/lst/ -DLPC17XX -D__NEWLIB__ -DTHUMB_PRESENT -mno-thumb-interwork -DTHUMB_NO_INTERWORKING -MD -MP -MF .dep/build.d -I. -I../../../os/po
	rts/common/ARMCMx/CMSIS/include -I../../../os/ports/common/ARMCMx -I../../../os/ports/GCC/ARMCMx -I../../../os/ports/GCC/ARMCMx/LPC17xx -I../../../os/
	kernel/include -I../../../test -I../../../os/hal/include -I../../../os/hal/platforms/LPC17xx -I../../../boards/ZLG_1766 -I../../../os/various main.c -
	o main.o

	mkdir -p build/obj
	mkdir -p build/lst
	Compiling crt0.c
	Compiling vectors.c
	Compiling chcore.c
	Compiling chcore_v7m.c
	...
	Compiling main.c
	Linking build/ch.elf
	Creating build/ch.hex
	Creating build/ch.bin
	Creating build/ch.dmp
	Done	

编译完成后，输出文件位于所在编译目录下的 build 目录。

### 4. 合并 lpc176x_port 分支的提交信息到 lpc17xx_dev 分支
lpc176x\_port 分支上的代码经测试基本稳定，并兼容 LPC17xx 系列的其他平台时就可以合并到 lpc17xx\_dev 分支。

首先，需要切换至 lpc17xx_dev 分支：

	E:\work\ChibiOS-RT>git checkout lpc17xx_dev
	Switched to branch 'lpc17xx_dev'
	Your branch is ahead of 'origin/lpc17xx_dev' by 4 commits.
	(use "git push" to publish your local commits)
	
然后，开始合并（下面示例中的部分输出信息已省略）：

	E:\work\ChibiOS-RT> git merge lpc176x_port
	
	Updating 43cbac1..b8a291a
	Fast-forward
	os/ports/GCC/ARMCMx/LPC17xx/cmparams.h    |   62 ++
	os/ports/GCC/ARMCMx/LPC17xx/ld/LPC1766.ld |  153 +++++
	os/ports/GCC/ARMCMx/LPC17xx/port.mk       |   15 +
	os/ports/GCC/ARMCMx/LPC17xx/vectors.c     |  205 ++++++
	...
	33 files changed, 7177 insertions(+), 4 deletions(-)
	create mode 100644 os/ports/GCC/ARMCMx/LPC17xx/cmparams.h
	create mode 100644 os/ports/GCC/ARMCMx/LPC17xx/ld/LPC1766.ld
	create mode 100644 os/ports/GCC/ARMCMx/LPC17xx/port.mk
	create mode 100644 os/ports/GCC/ARMCMx/LPC17xx/vectors.c
	...

### 5. 推送至远程仓库
由于是与团队其他成员共同开发 lpc17xx\_dev 分支，所以需要将合并后的代码推送至远程仓库，分享给其他团队成员。

当然，这之前，应该先看看别人是否也有推送提交，如果有那么应该先将别人的代码合并后再推送自己的代码。

抓取远程仓库的数据：

	E:\work\ChibiOS-RT> git fetch
	remote: Counting objects: 68, done.
	remote: Compressing objects: 100% (52/52), done.
	remote: Total 68 (delta 16), reused 55 (delta 13)
	Unpacking objects: 100% (68/68), done.
	From https://github.com/dinosaurkfb/ChibiOS-RT
	43cbac1..b8a291a  lpc17xx_dev -> origin/lpc17xx_dev

发现 lpc17xx\_dev 分支有更新，于是进行合并（下面示例中的部分输出信息已省略）：

	E:\work\ChibiOS-RT> git merge origin/lpc17xx_dev
	Updating 43cbac1..b8a291a
	Fast-forward
	boards/ZLG_1766/board.c                   |  148 +++++
	boards/ZLG_1766/board.h                   |  108 +++
	boards/ZLG_1766/board.mk                  |    5 +
	...
	9 files changed, 70 insertions(+), 11 deletions(-)
	create mode 100644 boards/ZLG_1766/board.c
	create mode 100644 boards/ZLG_1766/board.h
	create mode 100644 boards/ZLG_1766/board.mk
	...

当然，合并之前也可以先看看远程分支有哪些更新:

	git diff lpc17xx_dev origin/lpc17xx_dev

这次合并很顺利，没有冲突，如果有冲突，那么需要解决冲突后再推送。下面是推送过程：

	E:\work\ChibiOS-RT> git push origin lpc17xx_dev:lpc17xx_dev
	Username for 'https://github.com': dinosaurkfb
	Password for 'https://dinosaurkfb@github.com':
	Counting objects: 79, done.
	Delta compression using up to 4 threads.
	Compressing objects: 100% (65/65), done.
	Writing objects: 100% (68/68), 49.91 KiB, done.
	Total 68 (delta 26), reused 0 (delta 0)
	To https://github.com/dinosaurkfb/ChibiOS-RT.git
	43cbac1..b8a291a  lpc17xx_dev -> lpc17xx_dev

然后，就可以再切换回 lpc176x_port 分支继续开发了，不再赘述。

最后，这里的方法只是建议，如果你清楚的知道你在做什么，那么你当然可以按照你自己习惯的方式来开发。


-------------------------------------------------------------------------------

*上一篇*：*[ChibiOS 开发环境搭建之二 - maintainer 篇]({{ site.url }}/2014/01/13/ChibiOSEnvironment_2_maintainer/)*
