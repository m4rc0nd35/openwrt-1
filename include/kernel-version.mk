# Use the default kernel version if the Makefile doesn't override it

LINUX_RELEASE?=1

LINUX_VERSION-3.10 = .49
LINUX_VERSION-3.18 = .140
LINUX_VERSION-4.9 = .184
LINUX_VERSION-4.14 = .131

LINUX_KERNEL_HASH-3.10.49 = 13503623883ee5f8b339d4e58c7045386d1d32d41abce22edad1134136da437d
LINUX_KERNEL_HASH-3.18.140 = 18c38901c51373853435d364422c1931ed0520b16cc4ae9440d7b2095bdce2e0
LINUX_KERNEL_HASH-4.9.184 = 033114d5350525dede995d31b596c31b0e26db8d77a0a1c53d36cdc36ead9faf
LINUX_KERNEL_HASH-4.14.131 = 19f6404c30f4a9a1fe3315b902676b6d63a470be5d55cf2a0e47983c643c8ff5

remove_uri_prefix=$(subst git://,,$(subst http://,,$(subst https://,,$(1))))
sanitize_uri=$(call qstrip,$(subst @,_,$(subst :,_,$(subst .,_,$(subst -,_,$(subst /,_,$(1)))))))

ifneq ($(call qstrip,$(CONFIG_KERNEL_GIT_CLONE_URI)),)
  LINUX_VERSION:=$(call sanitize_uri,$(call remove_uri_prefix,$(CONFIG_KERNEL_GIT_CLONE_URI)))
  ifeq ($(call qstrip,$(CONFIG_KERNEL_GIT_REF)),)
    CONFIG_KERNEL_GIT_REF:=HEAD
  endif
  LINUX_VERSION:=$(LINUX_VERSION)-$(call sanitize_uri,$(CONFIG_KERNEL_GIT_REF))
else
ifdef KERNEL_PATCHVER
  LINUX_VERSION:=$(KERNEL_PATCHVER)$(strip $(LINUX_VERSION-$(KERNEL_PATCHVER)))
endif
endif

split_version=$(subst ., ,$(1))
merge_version=$(subst $(space),.,$(1))
KERNEL_BASE=$(firstword $(subst -, ,$(LINUX_VERSION)))
KERNEL=$(call merge_version,$(wordlist 1,2,$(call split_version,$(KERNEL_BASE))))
KERNEL_PATCHVER ?= $(KERNEL)

# disable the md5sum check for unknown kernel versions
LINUX_KERNEL_HASH:=$(LINUX_KERNEL_HASH-$(strip $(LINUX_VERSION)))
LINUX_KERNEL_HASH?=x
