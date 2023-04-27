ifneq (true,$(call TOBOOL,$(WITH_RUST)))
$(error NOT SUPPORT RUST, PLEASE SET `WITH_RUST`)
endif

CARGO := cargo
RUSTC := rustc

CARGO_FIX := build --manifest-path
CARGO_FAKEFILE := .OUT
CARGO_FILE := Cargo.toml

CARGO_FLAGS := -Z build-std=core,alloc,compiler_builtins

ifeq ($(ARCH), arm)
CARGO_TARGET := armv7a-none-eabi
endif
ifneq ($(findstring cortex-m,$(ARCH_CPU)),)
CARGO_TARGET := thumbv7em-none-eabihf
endif
ifneq ($(findstring cortex-a,$(ARCH_CPU)),)
CARGO_TARGET := armv7a-none-eabi
endif

ifeq ($(LK_DEBUGLEVEL),0)
CARGO_DBG := --release
CARGO_OUTSUB := $(CARGO_TARGET)/release
else
CARGO_OUTSUB := $(CARGO_TARGET)/debug
endif

CARGO_TARGET := --target $(CARGO_TARGET)

CARGO_OUTDIR := --target-dir=
CARGO_END := --

RUSTC_CORE_PATH := lib/rustlib/src/rust/library/core
RUSTC_ALLOC_PATH := lib/rustlib/src/rust/library/alloc

RUSTC_PATH ?= $(shell $(RUSTC) --print sysroot)
RUSTC_REMAP := $(RUSTC_PATH)/$(RUSTC_CORE_PATH)=core
RUSTC_REMAP += $(RUSTC_PATH)/$(RUSTC_ALLOC_PATH)=alloc
RUSTC_REMAP := $(addprefix --remap-path-prefix=,$(RUSTC_REMAP)))

RUSTC_OPT := -C opt-level=z
RUSTC_RELT := -C relocation-model=static

MODULE_RUSTNAME ?= $(basename $(MODULE_RUSTLIB))
MODULE_RUSTLIB := $(call TOBUILDDIR,$(MODULE_RUSTLIB))
MODULE_RUSTLIBDIR := $(MODULE_RUSTLIB)
MODULE_RUSTLIB := $(MODULE_RUSTLIB)/$(CARGO_FAKEFILE)
ifneq ($(MODULE_RUSTFEATURE),)
$(MODULE_RUSTLIB): CARGO_FEATURE := --features $(MODULE_RUSTFEATURE)
endif
$(MODULE_RUSTLIB): RUSTC_REMAPCUR := --remap-path-prefix=$(abspath $(LOCAL_DIR))=$(MODULE)
MODULE_RUSTLKLIB := $(addprefix $(MODULE_RUSTLIBDIR), /$(CARGO_OUTSUB)/lib$(MODULE_RUSTNAME).a)

ALLMODULE_OBJS := $(ALLMODULE_OBJS) $(MODULE_RUSTLKLIB)
GENERATED += $(MODULE_RUSTLIBDIR)

$(MODULE_RUSTLKLIB): %: $(MODULE_RUSTLIB)

$(MODULE_RUSTLIB): $(BUILDDIR)/%/$(CARGO_FAKEFILE): %/$(CARGO_FILE)
	@$(MKDIR)
	$(info compiling rust-crate $(dir $<))
	$(NOECHO)export RUSTFLAGS="$(RUSTC_REMAP) $(RUSTC_REMAPCUR) $(RUSTC_OPT) $(RUSTC_RELT)";\
	$(CARGO) $(CARGO_FIX) $< $(CARGO_FLAGS) $(CARGO_FEATURE) $(CARGO_TARGET) $(CARGO_DBG) $(CARGO_OUTDIR)$(dir $@) $(CARGO_END)

MODULE_RUSTLIB :=
MODULE_RUSTNAME :=
MODULE_RUSTFEATURE :=

