# main project for qemu-arm32
MODULES += \
	app/shell\
	app/rustsimple

WITH_RUST := 1

include project/virtual/test.mk
include project/virtual/fs.mk
include project/virtual/minip.mk
include project/target/qemu-virt-arm32.mk

