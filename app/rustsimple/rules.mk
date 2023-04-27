LOCAL_DIR := $(GET_LOCAL_DIR)

MODULE := $(LOCAL_DIR)

MODULE_RUSTLIB := $(LOCAL_DIR)/simple
MODULE_RUSTNAME := simple

include make/rustmod.mk
