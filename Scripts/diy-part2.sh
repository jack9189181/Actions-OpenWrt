#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#

# 修改路由器登录地址
if [[ $SET_IP =~ ^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$ ]]; then
	#修改immortalwrt.lan关联IP
	sed -i "s/192\.168\.[0-9]*\.[0-9]*/$SET_IP/g" $(find feeds/luci/modules/luci-mod-system -type f -name "flash.js")
	#修改默认IP地址
	sed -i "s/192\.168\.[0-9]*\.[0-9]*/$SET_IP/g" package/base-files/files/bin/config_generate
	echo "Set LAN IP Address: $SET_IP"
else
	echo "Invalid IP address, use default."
fi

#修改argon主题字体和颜色
if [ -d "./package/luci-theme-argon" ]; then
	sed -i "/font-weight:/ { /important/! { /\/\*/! s/:.*/: var(--font-weight);/ } }" $(find ./package/luci-theme-argon -type f -iname "*.css")
	sed -i "s/primary '.*'/primary '#31a1a1'/; s/'0.2'/'0.5'/; s/'none'/'bing'/; s/'600'/'normal'/" ./package/luci-app-argon-config/root/etc/config/argon
	echo "theme-argon has been fixed!"
else
	echo "theme is not fixed!"
fi

# #修改luci-app-samba4的菜单
# samba4_path="$OPENWRT_PATH/feeds/luci/applications/luci-app-samba4/root/usr/share/luci/menu.d/luci-app-samba4.json"
# if [ -f "$samba4_path" ]; then
# 	sed -i 's/nas/services/g' "$samba4_path"
# 	echo "luci-app-samba4 has been fixed!"
# fi

# 修改opkg软件源
emortal_def_dir="$OPENWRT_PATH/package/emortal/default-settings"
distfeeds_conf="$emortal_def_dir/files/99-distfeeds.conf"
if [ -d "$emortal_def_dir" ] && [ ! -f "$distfeeds_conf" ]; then
    cat <<'EOF' >"$distfeeds_conf"
src/gz openwrt_base https://downloads.immortalwrt.org/releases/24.10-SNAPSHOT/packages/aarch64_cortex-a53/base/
src/gz openwrt_luci https://downloads.immortalwrt.org/releases/24.10-SNAPSHOT/packages/aarch64_cortex-a53/luci/
src/gz openwrt_packages https://downloads.immortalwrt.org/releases/24.10-SNAPSHOT/packages/aarch64_cortex-a53/packages/
src/gz openwrt_routing https://downloads.immortalwrt.org/releases/24.10-SNAPSHOT/packages/aarch64_cortex-a53/routing/
src/gz openwrt_telephony https://downloads.immortalwrt.org/releases/24.10-SNAPSHOT/packages/aarch64_cortex-a53/telephony/
EOF
    sed -i "/define Package\/default-settings\/install/a\\
\\t\$(INSTALL_DIR) \$(1)/etc\\n\
\t\$(INSTALL_DATA) ./files/99-distfeeds.conf \$(1)/etc/99-distfeeds.conf\n" $emortal_def_dir/Makefile
    sed -i "/exit 0/i\\
[ -f \'/etc/99-distfeeds.conf\' ] && mv \'/etc/99-distfeeds.conf\' \'/etc/opkg/distfeeds.conf\'\n\
sed -ri \'/check_signature/s@^[^#]@#&@\' /etc/opkg.conf\n" $emortal_def_dir/files/99-default-settings
	echo "已修改opkg软件源."
else
	echo "软件源未修改成功"
fi

#高通平台调整
if [[ $WRT_TARGET == *"QUALCOMMAX"* ]]; then
	#取消nss相关feed
	echo "CONFIG_FEED_nss_packages=n" >> ./.config
	echo "CONFIG_FEED_sqm_scripts_nss=n" >> ./.config
	#设置NSS版本
	echo "CONFIG_NSS_FIRMWARE_VERSION_11_4=n" >> ./.config
	echo "CONFIG_NSS_FIRMWARE_VERSION_12_2=y" >> ./.config
	echo "NSS版本设置成功!"
	#无WIFI配置调整Q6大小
	if [[ $NO_WIFI == "true" ]]; then
		DTS_PATH="./target/linux/qualcommax/files/arch/arm64/boot/dts/qcom/"
		find $DTS_PATH -type f ! -iname '*nowifi*' -exec sed -i 's/ipq\(6018\|8074\)\.dtsi/ipq\1-nowifi.dtsi/g' {} +
		echo "无WIFI配置调整Q6成功!"
	fi
	#修改qca-nss-drv启动顺序
	# NSS_DRV="$GITHUB_WORKSPACE/openwrt/feeds/nss_packages/qca-nss-drv/files/qca-nss-drv.init"
	NSS_DRV="$OPENWRT_PATH/package/feeds/nss_packages/qca-nss-drv/files/qca-nss-drv.init"
	if [ -f "$NSS_DRV" ]; then
		sed -i 's/START=.*/START=85/g' $NSS_DRV
		echo "qca-nss-drv has been fixed!"
	else
		echo "err"
	fi
	#修改qca-nss-pbuf启动顺序
	NSS_PBUF="$OPENWRT_PATH/package/kernel/mac80211/files/qca-nss-pbuf.init"
	if [ -f "$NSS_PBUF" ]; then
		sed -i 's/START=.*/START=86/g' $NSS_PBUF
		echo "qca-nss-pbuf has been fixed!"
	else
		echo "err"
	fi
fi

#移除Shadowsocks组件
PW_FILE=$(find ./package/ -maxdepth 3 -type f -wholename "*/luci-app-passwall/Makefile")
if [ -f "$PW_FILE" ]; then
	sed -i '/config PACKAGE_$(PKG_NAME)_INCLUDE_Shadowsocks_Libev/,/x86_64/d' $PW_FILE
	sed -i '/config PACKAGE_$(PKG_NAME)_INCLUDE_ShadowsocksR/,/default n/d' $PW_FILE
	sed -i '/Shadowsocks_NONE/d; /Shadowsocks_Libev/d; /ShadowsocksR/d' $PW_FILE
	echo "passwall has been fixed!"
else
	echo "没找到passwall目录"
fi

SP_FILE=$(find ./package/ -maxdepth 3 -type f -wholename "*/luci-app-ssr-plus/Makefile")
if [ -f "$SP_FILE" ]; then
	sed -i '/default PACKAGE_$(PKG_NAME)_INCLUDE_Shadowsocks_Libev/,/libev/d' $SP_FILE
	sed -i '/config PACKAGE_$(PKG_NAME)_INCLUDE_ShadowsocksR/,/x86_64/d' $SP_FILE
	sed -i '/Shadowsocks_NONE/d; /Shadowsocks_Libev/d; /ShadowsocksR/d' $SP_FILE
	echo "ssr-plus has been fixed!"
else
	echo "没找到ssr目录"
fi