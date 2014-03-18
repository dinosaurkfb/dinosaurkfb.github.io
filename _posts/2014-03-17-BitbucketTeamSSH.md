---
layout: post
title: "Bitbucket 团队帐号设置"
description: ""
category: 
tags: [Bitbucket, SSH, Key, 团队, 管理]
---

由于 Github 上不支持免费的私有仓库，所以最近的项目把私有仓库建在了 Bitbucket 上，以前有些个人的项目也在 Bitbucket 上管理过，按照他们的操作指南来操作基本上没啥问题，这次团队帐号的设置还是有些需要注意的地方，这里记录一下：

<!--more-->

## 添加 SSH 公钥

添加公钥时，一定要按照 *[这里](https://confluence.atlassian.com/display/BITBUCKET/Set+up+SSH+for+Git)* 的 Bitbucket 的指南来操作，否则可能会出现类似这样的错误（根据你的非正常操作，下面的错误提示可能不一样）：
	# git clone git@bitbucket.org:xxxx/yy.git
	The authenticity of host 'bitbucket.org (131.103.20.168)' can't be established.
	RSA key fingerprint is 97:8c:6b:f2:6f:14:8b:5c:3b:ec:a9:46:46:71:7c:40.
	Are you sure you want to continue connecting (yes/no)? yes
	Warning: Permanently added 'bitbucket.org, 131.103.20.168' (RSA) to the list of known hosts.
	Permission denied (publickey).
	fatal: Could not read from remote repository.
	
这时候不用 Google 了，谁的答案也比不上官方的指南，回头对一下你是否每一步都按照指南来操作了。


团队成员的密钥添加时需要注意，如果你把密钥添加到了仓库的管理里面了，那么该成员对于此仓库是只有读权限的，如果 git push 会提示如下错误：

	# git push
	conq: repository access denied. access via a deployment key is read-only.
	fatal: The remote end hung up unexpectedly

这个是 Bitbucket 的设定，貌似是改不了的。如果这正符合你的期望，那就这样就可以。但如果你希望该成员也具有写权限，那么需要这样设置：

## 添加团队成员的写权限

这里的关键点就是，添加团队成员的 SSH KEY 时，是添加到团队的管理中，而不是添加到某一特定仓库的管理中。


点击首页右上角的头像下拉菜单中的“管理帐号”，进入“管理帐号”页面后，默认是管理个人帐号：

![man1]({{ site.url }}/images/bitbucket_man1.jpg)

点击“管理”右侧帐号的下拉菜单，选择团队的帐号：

![man2]({{ site.url }}/images/bitbucket_man2.jpg)

然后，选择“SSH 密钥”，并点击右侧的“添加 Key”，将团队成员的 Key 添加进去:

![man3]({{ site.url }}/images/bitbucket_man3.jpg)

OK，这样就没问题了。
