#![no_std]
#![no_main]

use core::arch::global_asm;

global_asm!(include_str!("entry.asm"));

#[unsafe(no_mangle)]
pub fn rust_main() -> ! {
    clear_bss();
    loop {}
}

fn clear_bss() {
    unsafe extern "C" {
        fn sbss();
        fn ebss();
    }

    let start = sbss as *const () as usize;
    let end = ebss as *const () as usize;
    (start..end).for_each(|addr| unsafe {
        (addr as *mut u8).write_volatile(0)
    });
}

#[panic_handler]
fn panic(_info: &core::panic::PanicInfo) -> ! {
    loop {}
}
