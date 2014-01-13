---
layout: post
title: "ChibiOS 开发环境搭建之一 - 编译环境篇"
description: ""
category: 
tags: [ChibiOS, GNU, GCC, YAGARTO, make, git, 开发环境]
---

#前提
本文适用于以下场景：

1. 基于官方 ChibiOS 的代码做开发（其实，支持 YAGARTO 开发环境的项目都适用，这里不做列举）
2. 使用 GCC 工具链进行开发工作
3. 使用 Git 做版本管理和团队协作

我们的环境搭建分四个部分, 以下安装都是基于 Windows 系统。

## 一. 安装 YAGARTO 开发环境
YAGARTO 是一个基于 Windows 操作系统的，跨平台 ARM 开发环境，包括 GNU C/C++ 开发工具链以及 Eclipse IDE。由于我用 emacs 开发，所以这里暂时不介绍 Eclipse 的部分。 YAGARTO 的下载地址在 *[这里](http://sourceforge.net/projects/yagarto/)*

安装过程比较简单，全部使用默认设置即可。

![ya0]({{ site.url }}/images/ya0.jpg)
![ya1]({{ site.url }}/images/ya1.jpg)
![ya2]({{ site.url }}/images/ya2.jpg)
![ya3]({{ site.url }}/images/ya3.jpg)
![ya4]({{ site.url }}/images/ya4.jpg)
![ya5]({{ site.url }}/images/ya5.jpg)

## 二. 安装 git
Git的下载地址在 *[这里](http://git-scm.com/)*， 安装过程也比较简单，只是有两个地方需要改一下默认设置，请注意修改。

![git0]({{ site.url }}/images/git0.jpg)
![git1]({{ site.url }}/images/git1.jpg)

安装到这里把安装路径改为 C:\Git 目录：

![git2]({{ site.url }}/images/git2.jpg)
![git3]({{ site.url }}/images/git3.jpg)
![git4]({{ site.url }}/images/git4.jpg)

安装到这里请选择第三项：

![git5]({{ site.url }}/images/git5.jpg)
![git6]({{ site.url }}/images/git6.jpg)
![git7]({{ site.url }}/images/git7.jpg)

## 三. 安装 make
Windows 系统默认没有 make，所以现在也需要安装，make 的下载地址在 *[这里](http://gnuwin32.sourceforge.net/downlinks/make.php)*

![make0]({{ site.url }}/images/make0.jpg)
![make1]({{ site.url }}/images/make1.jpg)

安装到这里，请把安装路径改为 C:\GnuWin32 目录：

![make2]({{ site.url }}/images/make2.jpg)
![make3]({{ site.url }}/images/make3.jpg)
![make4]({{ site.url }}/images/make4.jpg)
![make5]({{ site.url }}/images/make5.jpg)
![make6]({{ site.url }}/images/make6.jpg)
![make7]({{ site.url }}/images/make7.jpg)

## 四. 修改环境变量
![env0]({{ site.url }}/images/env0.jpg)
![env1]({{ site.url }}/images/env1.jpg)
![env2]({{ site.url }}/images/env2.jpg)

把刚刚安装的几个软件的可执行程序路径，加到环境变量*最前面*：

	C:\GnuWin32\bin;C:\Git\cmd;C:\Git\bin;C:\yagarto-20121222\bin;C:\MinGW\bin;

如图所示：

![env3]({{ site.url }}/images/env3.jpg)


## 定制安装请慎重
上述安装方法不是唯一的方法，但是此安装过程已经过测试验证，如果您想定制，那我提醒一下需要注意的问题

1. 安装路径避免有空格、中文字符或者括号，最保险的就是英文、数字和下划线。
2. 加环境变量时一定要加到最前面

因为我安装过程中曾遇到这个问题：

	make: Interrupt/Exception caught (code = 0xc00000fd, addr = 0x4217b3)

具体的原因，感兴趣的朋友可以参考 *[这里](http://hdrlab.org.nz/articles/windows-development/make-interrupt-exception-caught-code-0xc00000fd-addr-0x4217b/)*

-------------------------------------------------------------------------------

*下一篇*：*[ChibiOS 开发环境搭建之二 - maintainer 篇]({{ site.url }}/2014/01/13/ChibiOSEnvironment_2_maintainer/)*
