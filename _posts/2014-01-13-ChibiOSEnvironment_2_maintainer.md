---
layout: post
title: "ChibiOS 开发环境搭建之二 - maintainer 篇"
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

本文介绍的是 maintainer 的工作流程。

# maintainer 工作流程

### 1. 首先，在 Github 上 Fork 官方的源码库
官方源码库（*[链接](https://github.com/ChibiOS/ChibiOS-RT)*）。这里以我的实际工作为例进行讲述，我 Fork 之后的仓库为 [https://github.com/dinosaurkfb/ChibiOS-RT.git](https://github.com/dinosaurkfb/ChibiOS-RT.git)

### 2. 克隆我的 Github 远程仓库到本地

	E:\work> git clone https://github.com/dinosaurkfb/ChibiOS-RT.git

查看远程仓库 origin 的基本信息

	E:\work\ChibiOS-RT> git remote -v
	
	origin  https://github.com/dinosaurkfb/ChibiOS-RT.git (fetch)
	origin  https://github.com/dinosaurkfb/ChibiOS-RT.git (push)

查看远程仓库 origin 的详细信息

	E:\work\ChibiOS-RT> git remote show origin
	
	* remote origin
	Fetch URL: https://github.com/dinosaurkfb/ChibiOS-RT.git
	Push  URL: https://github.com/dinosaurkfb/ChibiOS-RT.git
	HEAD branch: master
	Remote branches:
    chibistudio_trunk   tracked
    kernel_3_alt_vt_dev tracked
    kernel_3_dev        tracked
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

可以看到其中有个分支叫 stable\_2.6.x ，后面我们将基于此分支进行开发。

### 3. 添加 ChibiOS 官方的 Github 远程仓库
maintainer 需要跟踪官方仓库的更新，所以需要把官方的远程仓库加入进来一起管理。

	E:\work\ChibiOS-RT> git remote add ChibiOS https://github.com/ChibiOS/ChibiOS-RT.git

注意：我在上述命令中把 ChibiOS 官方远程库命名为 ChibiOS ，与我自己的远程仓库 origin 区分开来，便于之后的管理和引用。

再次查看当前的远程库详细信息

	E:\work\ChibiOS-RT> git remote -v
	
	ChibiOS https://github.com/ChibiOS/ChibiOS-RT.git (fetch)
	ChibiOS https://github.com/ChibiOS/ChibiOS-RT.git (push)
	origin  https://github.com/dinosaurkfb/ChibiOS-RT.git (fetch)
	origin  https://github.com/dinosaurkfb/ChibiOS-RT.git (push)

抓取远程版本库 ChibiOS 的数据。

	E:\work\ChibiOS-RT> git fetch ChibiOS
	
	remote: Counting objects: 249, done.
	remote: Compressing objects: 100% (132/132), done.
	Receiving objects: 100% (249/249), 193.27 KiB | 66 KiB/s, done.
	emote: Total 249 (delta 119), reused 183 (delta 103)R
	Resolving deltas: 100% (119/119), done.
	From https://github.com/ChibiOS/ChibiOS-RT
	* [new branch]      chibistudio_trunk -> ChibiOS/chibistudio_trunk
	* [new branch]      kernel_3_alt_vt_dev -> ChibiOS/kernel_3_alt_vt_dev
	* [new branch]      kernel_3_dev -> ChibiOS/kernel_3_dev
	* [new branch]      master     -> ChibiOS/master
	* [new branch]      stable_1.0.x -> ChibiOS/stable_1.0.x
	* [new branch]      stable_1.2.x -> ChibiOS/stable_1.2.x
	* [new branch]      stable_1.4.x -> ChibiOS/stable_1.4.x
	* [new branch]      stable_2.0.x -> ChibiOS/stable_2.0.x
	* [new branch]      stable_2.2.x -> ChibiOS/stable_2.2.x
	* [new branch]      stable_2.4.x -> ChibiOS/stable_2.4.x
	* [new branch]      stable_2.6.x -> ChibiOS/stable_2.6.x
	* [new branch]      utils_dev  -> ChibiOS/utils_dev


查看目前的分支情况，有 ChibiOS 仓库的多个分支， origin 仓库的多个分支以及一个本地 master 分支。

	E:\work\ChibiOS-RT> git branch -a

	* master
	remotes/ChibiOS/chibistudio_trunk
	remotes/ChibiOS/kernel_3_alt_vt_dev
	remotes/ChibiOS/kernel_3_dev
	remotes/ChibiOS/master
	remotes/ChibiOS/stable_1.0.x
	remotes/ChibiOS/stable_1.2.x
	remotes/ChibiOS/stable_1.4.x
	remotes/ChibiOS/stable_2.0.x
	remotes/ChibiOS/stable_2.2.x
	remotes/ChibiOS/stable_2.4.x
	remotes/ChibiOS/stable_2.6.x
	remotes/ChibiOS/utils_dev
	remotes/origin/HEAD -> origin/master
	remotes/origin/chibistudio_trunk
	remotes/origin/kernel_3_alt_vt_dev
	remotes/origin/kernel_3_dev
	remotes/origin/master
	remotes/origin/stable_1.0.x
	remotes/origin/stable_1.2.x
	remotes/origin/stable_1.4.x
	remotes/origin/stable_2.0.x
	remotes/origin/stable_2.2.x
	remotes/origin/stable_2.4.x
	remotes/origin/stable_2.6.x
	remotes/origin/utils_dev

## 二. 合并官方 ChibiOS 仓库的数据到我的 origin 仓库
在 origin 仓库进行一段时间开发后，官方仓库可能已经有了一些新的 PUSH ，这个时候我这个 maintainer 要做的事情就是把官方的 ChibiOS/stable\_2.6.x 分支最新的提交合并到我的 origin/stable\_2.6.x 分支。合并时有可能会犯错误，下面看看我是怎样**犯错误**的：

	E:\work\ChibiOS-RT> git merge ChibiOS/stable_2.6.x
	
	Performing inexact rename detection: 100% (1967/1967), done.
	CONFLICT (rename/add): Rename tools/gencfg/processors/hal/stm32f4xx/templates/hal_cfg.c.ftl->os/ports/GCC/PPC/SPC560Dxx/vectors.h in ChibiOS/stable_2.
	6.x. os/ports/GCC/PPC/SPC560Dxx/vectors.h added in HEAD
	Adding as os/ports/GCC/PPC/SPC560Dxx/vectors.h~HEAD instead
	CONFLICT (rename/add): Rename tools/gencfg/processors/hal/stm32f4xx/templates/hal_cfg.h.ftl->os/ports/GCC/PPC/SPC560Bxx/vectors.h in ChibiOS/stable_2.
	6.x. os/ports/GCC/PPC/SPC560Bxx/vectors.h added in HEAD
	Adding as os/ports/GCC/PPC/SPC560Bxx/vectors.h~HEAD instead
	Auto-merging docs/src/concepts.dox
	Removing docs/reports/STM8S208-16-Raisonance.txt
	Removing docs/reports/STM8S105-16-Raisonance.txt
	Removing docs/reports/STM8S105-16-Cosmic.txt
	Removing docs/reports/STM8L152-16-Raisonance.txt
	Removing docs/reports/STM8L152-16-Cosmic.txt
	Auto-merging docs/Doxyfile_html
	CONFLICT (content): Merge conflict in docs/Doxyfile_html
	Auto-merging docs/Doxyfile_chm
	CONFLICT (content): Merge conflict in docs/Doxyfile_chm
	Removing boards/ST_STM8L_DISCOVERY/board.c
	Removing boards/RAISONANCE_REVA_STM8S/board.h
	Removing boards/RAISONANCE_REVA_STM8S/board.c
	Automatic merge failed; fix conflicts and then commit the result.

敲了上述命令后，我发现了大量的冲突，上面只是节选了一小部分。原因在于，按照 Github 默认的情况，我目前所在的分支是 master 分支，该分支跟踪的是 origin/master 分支，这个分支是 ChibiOS 的主要开发分支（目前是在开发3.0阶段）。而我合并过来的是 ChibiOS/stable\_2.6.x 分支，二者的差别可想而知了。于是下面要纠正刚刚的错误操作，方法如下：

	git merge --abort
	
这条命令撤销了刚刚的合并。那么正确的做法应该是怎样的呢？我是这样做的，创建一个 stable\_2.6.x\_merge 分支来用于合并代码。
	E:\work\ChibiOS-RT> git checkout -b stable_2.6.x_merge origin/stable_2.6.x
	
	Branch stable_2.6.x_merge set up to track remote branch stable_2.6.x from origin.
	Switched to a new branch 'stable_2.6.x_merge'

上面的命令之后，本地已经自动切换为 stable\_2.6.x_merge 分支，这次可以开始合并了：

	E:\work\ChibiOS-RT> git merge ChibiOS/stable_2.6.x 
	Updating a9d5d10..43cbac1
	Fast-forward
	boards/ST_STM32F0_DISCOVERY/board.c         |   1 -
	boards/ST_STM32F0_DISCOVERY/board.h         |   4 +-
	boards/ST_STM32F0_DISCOVERY/cfg/board.chcfg |   1 +
	demos/ARMCM4-STM32F407-DISCOVERY/mcuconf.h  |  45 ++---
	docs/rsc/header_chm.html                    |   2 +-
	docs/rsc/header_html.html                   |   2 +-
	os/hal/platforms/STM32/GPIOv2/pal_lld.c     |  19 +-
	os/hal/platforms/STM32/GPIOv2/pal_lld.h     |  18 +-
	os/hal/platforms/STM32/USARTv1/serial_lld.c |   6 +-
	os/hal/platforms/STM32/stm32.h              |   3 +-
	os/hal/platforms/STM32F0xx/hal_lld.h        |  22 ++-
	os/hal/platforms/STM32F0xx/stm32_registry.h | 275 +++++++++++++++++++++++++---
	os/hal/platforms/STM32F0xx/stm32f0xx.h      | 112 +++++++++--
	os/hal/platforms/STM32F37x/hal_lld.h        |   2 +-
	os/hal/platforms/STM32F4xx/hal_lld.h        |  13 +-
	os/hal/platforms/STM32L1xx/hal_lld.h        |   8 +-
	os/various/chprintf.c                       |   2 +-
	readme.txt                                  |   6 +
	18 files changed, 440 insertions(+), 101 deletions(-)

合并好了之后，该把合并好的本地分支推送到远程分支 origin 了，但是此时我又犯了个**错误**，我是这样推送的：

	E:\work\ChibiOS-RT> git push origin stable_2.6.x_merge

	Username for 'https://github.com': dinosaurkfb
	Password for 'https://dinosaurkfb@github.com':
	Counting objects: 113, done.
	Delta compression using up to 4 threads.
	Compressing objects: 100% (47/47), done.
	Writing objects: 100% (76/76), 12.04 KiB, done.
	Total 76 (delta 63), reused 40 (delta 28)
	To https://github.com/dinosaurkfb/ChibiOS-RT.git
	* [new branch]      stable_2.6.x_merge -> stable_2.6.x_merge

看出问题在哪儿了吧？这条命令创建了一个新的远程分支 origin/stable\_2.6.x\_merge，这可不是我希望的。下面的命令，纠正刚刚的错误操作：

	E:\work\ChibiOS-RT> git push origin *:*stable_2.6.x_merge

	To https://github.com/dinosaurkfb/ChibiOS-RT.git
	- [deleted]         stable_2.6.x_merge

要将本地的stable\_2.6.x\_merge 分支推送到远程的 origin/stable\_2.6.x分支, 正确的推送方法是这样的：

	E:\work\ChibiOS-RT> git push origin stable_2.6.x_merge:stable_2.6.x
	Username for 'https://github.com': dinosaurkfb
	Password for 'https://dinosaurkfb@github.com':
	Counting objects: 113, done.
	Delta compression using up to 4 threads.
	Compressing objects: 100% (47/47), done.
	Writing objects: 100% (76/76), 12.04 KiB, done.
	Total 76 (delta 63), reused 40 (delta 28)
	To https://github.com/dinosaurkfb/ChibiOS-RT.git
	a9d5d10..43cbac1  stable_2.6.x_merge -> stable_2.6.x

## 三. 组织团队成员开发
我们团队目前的情况是要将 ChibiOS 移植到 LPC1769 和 LPC1788 平台，并开发各种驱动程序，流程如下：
### 1. 创建一个远程的开发分支
建立远程开发分支的目的是合并团队的开发成果，首先，基于 origin/stable\_2.6.x 分支来建立本地分支（我们把 origin/stable\_2.6.x 分支定义为与 ChibiOS 官方仓库保持同步的稳定分支）：

	E:\work\ChibiOS-RT> git checkout -b lpc17xx_dev  origin/stable_2.6.x

	Branch lpc17xx_dev set up to track remote branch stable_2.6.x from origin.
	Switched to a new branch 'lpc17xx_dev'

推送本地分支 lpc17xx\_dev 到 origin 仓库，远程分支名也叫 lpc17xx\_dev。

	E:\work\ChibiOS-RT> git push origin lpc17xx_dev:lpc17xx_dev
	Username for 'https://github.com': dinosaurkfb
	Password for 'https://dinosaurkfb@github.com':
	Total 0 (delta 0), reused 0 (delta 0)
	To https://github.com/dinosaurkfb/ChibiOS-RT.git
	* [new branch]      lpc17xx_dev -> lpc17xx_dev

### 2. contributor 在远程的开发分支的基础上进行开发
见*[第二部分]({{ site.url }}/2014/01/14/ChibiOSEnvironment_3_contributor/)*

## 四. 合并 contributor 的代码到某一稳定分支
目前尚未进行到这一步，等进行到这一步时再补上


