#![no_std]

pub extern "C" fn add(left: usize, right: usize) -> usize {
    left + right
}

#[panic_handler]
#[inline(never)]
fn panic(_info: &core::panic::PanicInfo) -> ! {
    loop {}
}
