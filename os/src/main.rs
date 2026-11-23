#![no_std]
#![no_main]

#[macro_use]
mod console;
mod sbi;

use core::arch::global_asm;

global_asm!(include_str!("entry.asm"));

#[unsafe(no_mangle)]
pub fn rust_main() -> ! {
    clear_bss();
    println!("Hello, world!");
    panic!("Shutdown machine!");
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

mod lang_items;
