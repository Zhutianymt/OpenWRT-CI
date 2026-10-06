#!/bin/bash
# SPDX-License-Identifier: MIT
# Copyright (C) 2026 VIKINGYFY

FEEDS_PATH="./feeds"
PACKAGE_PATH="./package"

#修改argon主题字体和颜色
if [ -d "$PACKAGE_PATH/luci-theme-argon" ]; then
	echo " "
	if sed -i "s/primary '.*'/primary '#31a1a1'/g; s/'0.2'/'0.5'/g; s/'none'/'bing'/g; s/'600'/'normal'/g" \
		"$PACKAGE_PATH/luci-theme-argon/luci-app-argon-config/root/etc/config/argon"; then
		echo "theme-argon has been fixed!"
	else
		echo "theme-argon fix failed; continuing!"
	fi
fi

#修改aurora菜单式样
if [ -d "$PACKAGE_PATH/luci-app-aurora-config" ]; then
	echo " "
	if find "$PACKAGE_PATH/luci-app-aurora-config/root/usr/share/aurora/" -type f -name '*.template' -exec \
		sed -i "s/nav_type '.*'/nav_type 'dropdown'/g; s/struct_radius_base '.*'/struct_radius_base '0.125rem'/g" {} +; then
		echo "theme-aurora has been fixed!"
	else
		echo "theme-aurora fix failed; continuing!"
	fi
fi

#修改mini-diskmanager菜单位置
if [ -d "$PACKAGE_PATH/luci-app-mini-diskmanager" ]; then
	echo " "
	if sed -i "s/services/system/g" \
		"$PACKAGE_PATH/luci-app-mini-diskmanager/luci-app-mini-diskmanager/root/usr/share/luci/menu.d/luci-app-mini-diskmanager.json"; then
		echo "mini-diskmanager has been fixed!"
	else
		echo "mini-diskmanager fix failed; continuing!"
	fi
fi

#修改natmapt菜单位置
if [ -d "$PACKAGE_PATH/luci-app-natmapt" ]; then
	echo " "
	if sed -i "s/network/services/g" \
		"$PACKAGE_PATH/luci-app-natmapt/root/usr/share/luci/menu.d/luci-app-natmap.json"; then
		echo "natmapt has been fixed!"
	else
		echo "natmapt fix failed; continuing!"
	fi
fi

#修复Rust编译失败
if [ -d "$FEEDS_PATH/packages/lang/rust" ]; then
	echo " "
	if sed -i 's/ci-llvm=true/ci-llvm=false/g' \
		"$FEEDS_PATH/packages/lang/rust/Makefile"; then
		echo "rust has been fixed!"
	else
		echo "rust fix failed; continuing!"
	fi
fi

# 修改 UPnP IGD 菜单位置到"网络"
UPNP_MENU=$(find ./ ../feeds/ -path "*/luci-app-upnp/root/usr/share/luci/menu.d/luci-app-upnp.json" 2>/dev/null | head -n 1)
if [ -n "$UPNP_MENU" ]; then
    sed -i 's/"admin\/services\/upnp"/"admin\/network\/upnp"/g' "$UPNP_MENU"
    echo "upnp menu moved to network"
fi

# 删除系统菜单下的"插件"项
SYS_MENU=$(find ./ ../feeds/ -path "*/luci-mod-system/root/usr/share/luci/menu.d/luci-mod-system.json" 2>/dev/null | head -n 1)
if [ -n "$SYS_MENU" ]; then
    sed -i '/"admin\/system\/plugins": {/,/^\t},$/d' "$SYS_MENU"
    echo "system plugins menu removed"
fi

# 修改 Tailscale 菜单位置到"服务"
# TS_MENU=$(find ./ ../feeds/ -path "*/luci-app-tailscale/root/usr/share/luci/menu.d/luci-app-tailscale.json" 2>/dev/null | head -n 1)
# if [ -n "$TS_MENU" ]; then
#     sed -i 's/"admin\/vpn\/tailscale"/"admin\/services\/tailscale"/g' "$TS_MENU"
#     sed -i 's/admin\/vpn\/tailscale/admin\/services\/tailscale/g' $(find ./ -path "*/luci-app-tailscale/luasrc/controller/*.lua" 2>/dev/null)
#     echo "tailscale menu moved to services"
# fi

# 修复 tailscale 文件冲突：删除 luci-app-tailscale 自带的 root 文件，改由 tailscale 主包提供
TS_PKG=$(find ./ ../feeds/ -maxdepth 4 -type d -iname "luci-app-tailscale" 2>/dev/null | head -n 1)
if [ -n "$TS_PKG" ]; then
	echo " "
	rm -f "$TS_PKG/root/etc/init.d/tailscale" "$TS_PKG/root/etc/config/tailscale"
	# 清理构建目录残留，避免旧文件被打包
	find ./build_dir -maxdepth 4 -type d -iname "luci-app-tailscale*" -exec rm -rf {} + 2>/dev/null
	echo "tailscale conflict files has been removed!"
fi

# 修复 luci-light 缺少 luci-theme-alpha 依赖
LIGHT_MAKE=$(find ../feeds/ -path "*/luci-light/Makefile" 2>/dev/null | head -n 1)
if [ -n "$LIGHT_MAKE" ]; then
    sed -i 's/+luci-theme-alpha //g' "$LIGHT_MAKE"
    echo "luci-light fixed: removed luci-theme-alpha dep"
fi

# 修改 ddns-go 菜单位置到"VPN/组网"
DDNS_MENU=$(find ./ ../feeds/ -path "*/luci-app-ddns-go/root/usr/share/luci/menu.d/*.json" 2>/dev/null | head -n 1)
if [ -n "$DDNS_MENU" ]; then
    sed -i 's#"admin/services/ddns-go"#"admin/vpn/ddns-go"#g; s#"admin/nas/ddns-go"#"admin/vpn/ddns-go"#g; s#"admin/services"#"admin/vpn"#g; s#"admin/nas"#"admin/vpn"#g' "$DDNS_MENU"
    echo "ddns-go menu moved to vpn"
fi

# 修改 easytier 菜单位置到"VPN/组网"（若默认不在 vpn）
ET_MENU=$(find ./ ../feeds/ -path "*/luci-app-easytier/root/usr/share/luci/menu.d/*.json" 2>/dev/null | head -n 1)
if [ -n "$ET_MENU" ]; then
    sed -i 's#"admin/services/easytier"#"admin/vpn/easytier"#g; s#"admin/nas/easytier"#"admin/vpn/easytier"#g; s#"admin/services"#"admin/vpn"#g; s#"admin/nas"#"admin/vpn"#g' "$ET_MENU"
    echo "easytier menu moved to vpn"
fi

# 修改 VPN 菜单显示名为"组网"（内含 ddns-go / easytier / tailscale）
VP_BASE=$(find ./ ../feeds/ -path "*/luci-base/root/usr/share/luci/menu.d/luci-base.json" 2>/dev/null | head -n 1)
if [ -n "$VP_BASE" ]; then
    sed -i '/"admin\/vpn": {/,/^[[:space:]]*},$/ s/"title": "VPN"/"title": "组网"/' "$VP_BASE"
    echo "vpn menu renamed to 组网"
fi

# 修改 wolultra 菜单位置到"服务"
WOL_MENU=$(find ./ ../feeds/ -path "*/luci-app-wolultra/root/usr/share/luci/menu.d/*.json" 2>/dev/null | head -n 1)
if [ -n "$WOL_MENU" ]; then
    sed -i 's#"admin/control/wolultra"#"admin/services/wolultra"#g; s#"admin/control"#"admin/services"#g' "$WOL_MENU"
    echo "wolultra menu moved to services"
fi