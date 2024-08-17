include $(TOPDIR)/rules.mk

PKG_NAME:=shadowsocks-rust
PKG_VERSION:=1.20.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/shadowsocks/shadowsocks-rust/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=95bef16ced3d937e085fdce0bc8de33e156c00bdc9c10100778d3e3ff4df95f0

PKG_MAINTAINER:=Anya Lin <hukk1996@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=rust/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/rust/rust-package.mk

define Package/shadowsocks-rust/Default
  define Package/shadowsocks-rust-$(1)
    SECTION:=net
    CATEGORY:=Network
    SUBMENU:=Web Servers/Proxies
    TITLE:=shadowsocks-rust $(1)
    URL:=https://github.com/shadowsocks/shadowsocks-rust
    DEPENDS:=$$(RUST_ARCH_DEPENDS)
  endef

  define Package/shadowsocks-rust-$(1)/install
	$$(INSTALL_DIR) $$(1)/usr/bin/
	$$(INSTALL_BIN) $$(PKG_INSTALL_DIR)/bin/$(1) $$(1)/usr/bin/
  endef
endef

define Package/shadowsocks-rust/config
	menu "Features configuration"
		depends on PACKAGE_shadowsocks-rust

		config SS_RUST_LOCAL_HTTP
			bool "Allow using HTTP protocol for sslocal"
			default y

		config SS_RUST_LOCAL_TUNNEL
			bool "Allow using tunnel protocol for sslocal"
			default y

		config SS_RUST_LOCAL_SOCKS4
			bool "Allow using SOCKS4/4a protocol for sslocal"

		config SS_RUST_LOCAL_REDIR
			bool "Allow using redir (transparent proxy) protocol for sslocal"
			default y

		config SS_RUST_LOCAL_DNS
			bool "Allow using dns protocol for sslocal"
			default y
			help
			  serves as a DNS server proxying queries to local or
			  remote DNS servers by ACL rules.

		config SS_RUST_LOCAL_TUN
			bool "TUN interface support for sslocal"
			default y

		config SS_RUST_LOCAL_ONLINE_CONFIG
			bool "SIP008 Online Configuration Delivery"

		config SS_RUST_AEAD_CIPHER_EXTRA
			bool "Enable non-standard AEAD ciphers"

		config SS_RUST_AEAD_CIPHER_2022
			bool "Enable AEAD-2022 ciphers (SIP022)"
			default y

		config SS_RUST_AEAD_CIPHER_2022_EXTRA
			bool "Enable AEAD-2022 extra ciphers (non-standard ciphers)"
	endmenu
endef

PKG_CONFIG_DEPENDS:= \
	SS_RUST_LOCAL_HTTP \
	SS_RUST_LOCAL_TUNNEL \
	SS_RUST_LOCAL_SOCKS4 \
	SS_RUST_LOCAL_REDIR \
	SS_RUST_LOCAL_DNS \
	SS_RUST_LOCAL_TUN \
	SS_RUST_LOCAL_ONLINE_CONFIG \
	SS_RUST_AEAD_CIPHER_EXTRA \
	SS_RUST_AEAD_CIPHER_2022 \
	SS_RUST_AEAD_CIPHER_2022_EXTRA \

RUST_PKG_FEATURES:=$(subst $(space),$(comma),$(strip \
	$(if $(SS_RUST_LOCAL_HTTP),local-http) \
	$(if $(SS_RUST_LOCAL_TUNNEL),local-tunnel) \
	$(if $(SS_RUST_LOCAL_SOCKS4),local-socks4) \
	$(if $(SS_RUST_LOCAL_REDIR),local-redir) \
	$(if $(SS_RUST_LOCAL_DNS),local-dns) \
	$(if $(SS_RUST_LOCAL_TUN),local-tun) \
	$(if $(SS_RUST_LOCAL_ONLINE_CONFIG),local-online-config) \
	$(if $(SS_RUST_AEAD_CIPHER_EXTRA),aead-cipher-extra) \
	$(if $(SS_RUST_AEAD_CIPHER_2022),aead-cipher-2022) \
	$(if $(SS_RUST_AEAD_CIPHER_2022_EXTRA),aead-cipher-2022-extra) \
))

SHADOWSOCKS_COMPONENTS:=sslocal ssserver ssurl ssmanager ssservice
define shadowsocks-rust/templates
  $(foreach component,$(SHADOWSOCKS_COMPONENTS),
    $(call Package/shadowsocks-rust/Default,$(component))
  )
endef
$(eval $(call shadowsocks-rust/templates))

$(foreach component,$(SHADOWSOCKS_COMPONENTS), \
  $(eval $(call BuildPackage,shadowsocks-rust-$(component))) \
)
