# Copyright 2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
RESTRICT="mirror"
inherit systemd

DESCRIPTION="Initialize iptables and net-related sysctl variables"
HOMEPAGE="https://github.com/vaeth/firewall-mv/"
SRC_URI="https://github.com/vaeth/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="old-openrc"
RDEPEND="!<sys-apps/openrc-0.13
	!old-openrc? ( !<sys-apps/openrc-0.21.7 )
	old-openrc? ( !>=sys-apps/openrc-0.21.7 )
	>=app-shells/push-2.0-r2"
DEPEND=""

src_prepare() {
	if use prefix
	then	sed -i \
			-e "s!/etc/!${EPREFIX}/etc/!g" \
			-e "s!/usr/!${EPREFIX}/usr/!g" \
			-- sbin/* etc/* systemd/* || die
	else	sed -i \
			-e '1s"^#!/usr/bin/env sh$"#!'"${EPREFIX}/bin/sh"'"' \
			-- sbin/* || die
	fi
	eapply_user
}

src_install() {
	into /
	dosbin sbin/*
	insinto /etc
	doins -r etc/*
	insinto /usr/lib/modules-load.d
	doins modules-load.d/*
	insinto /usr/share/zsh/site-functions
	doins zsh/*
	doconfd openrc/conf.d/fire*
	! use old-openrc || doconfd openrc/conf.d/modules
	doinitd openrc/init.d/*
	dodoc README
	systemd_dounit systemd/*
}
