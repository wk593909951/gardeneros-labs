#![no_std]
#![no_main]

mod console;
mod syscall;

use core::panic::PanicInfo;

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    loop {}
}

#[unsafe(no_mangle)]
pub extern "C" fn _start() -> ! {
    println!("Hello, world!");
    println!("Student ID: {}", 24301043);
    syscall::sys_exit(0)
}
