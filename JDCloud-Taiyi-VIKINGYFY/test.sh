# Modify default IP
#sed -i 's/192.168.1.1/192.168.50.5/g' package/base-files/files/bin/config_generate
##-----------------Add dev core for kenzo OpenClash------------------
# curl -sL -m 30 --retry 2 https://raw.githubusercontent.com/vernesong/OpenClash/core/master/dev/clash-linux-arm64.tar.gz -o /tmp/clash.tar.gz
# tar zxvf /tmp/clash.tar.gz -C /tmp >/dev/null 2>&1
# chmod +x /tmp/clash >/dev/null 2>&1
# mkdir -p package/kenzo/luci-app-openclash/root/etc/openclash/core
# mv /tmp/clash package/kenzo/luci-app-openclash/root/etc/openclash/core/clash >/dev/null 2>&1
# rm -rf /tmp/clash.tar.gz >/dev/null 2>&1
PKG_PATH="$GITHUB_WORKSPACE/openwrt/package/"

# Modify default IP
if [[ $SET_IP =~ ^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$ ]]; then
	#修改immortalwrt.lan关联IP
	# sed -i "s/192\.168\.[0-9]*\.[0-9]*/$SET_IP/g" $(find feeds/luci/modules/luci-mod-system -type f -name "flash.js")
	#修改默认IP地址
	# sed -i "s/192\.168\.[0-9]*\.[0-9]*/$SET_IP/g" package/base-files/files/bin/config_generate
	echo "Set LAN IP Address: $SET_IP"
else
	echo "Invalid IP address, use default."
fi

#测试
if [ -d *"test1"* ]; then
    echo "有"
else
    echo "无"
fi

# #修改argon主题字体和颜色
# if [ -d *"luci-theme-argon"* ]; then
# 	cd ./luci-theme-argon/

# 	sed -i "/font-weight:/ { /important/! { /\/\*/! s/:.*/: var(--font-weight);/ } }" $(find ./luci-theme-argon -type f -iname "*.css")
# 	sed -i "s/primary '.*'/primary '#31a1a1'/; s/'0.2'/'0.5'/; s/'none'/'bing'/; s/'600'/'normal'/" ./luci-app-argon-config/root/etc/config/argon

# 	cd $PKG_PATH && echo "theme-argon has been fixed!"
# else
# 	echo "theme is not fixed!"
# fi

# #修改qca-nss-drv启动顺序
# NSS_DRV="../feeds/nss_packages/qca-nss-drv/files/qca-nss-drv.init"
# if [ -f "$NSS_DRV" ]; then
# 	sed -i 's/START=.*/START=85/g' $NSS_DRV

# 	cd $PKG_PATH && echo "qca-nss-drv has been fixed!"
# else
# 	echo "err"
# fi

# #修改qca-nss-pbuf启动顺序
# NSS_PBUF="./kernel/mac80211/files/qca-nss-pbuf.init"
# if [ -f "$NSS_PBUF" ]; then
# 	sed -i 's/START=.*/START=86/g' $NSS_PBUF

# 	cd $PKG_PATH && echo "qca-nss-pbuf has been fixed!"
# else
# 	echo "err"
# fi

# # #修复Coremark编译失败
# # CM_FILE=$(find ../feeds/packages/ -maxdepth 3 -type f -wholename "*/coremark/Makefile")
# # if [ -f "$CM_FILE" ]; then
# # 	sed -i 's/mkdir/mkdir -p/g' $CM_FILE

# # 	cd $PKG_PATH && echo "coremark has been fixed!"
# # fi