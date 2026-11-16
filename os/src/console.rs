use core::fmt::{self, Write};

use crate::syscall::sys_write;

struct Stdout;

impl Write for Stdout {
    fn write_str(&mut self, s: &str) -> fmt::Result {
        let mut remaining = s.as_bytes();
        while !remaining.is_empty() {
            let written = sys_write(1, remaining);
            if written <= 0 {
                return Err(fmt::Error);
            }
            remaining = &remaining[written as usize..];
        }
        Ok(())
    }
}

pub fn print(args: fmt::Arguments) {
    Stdout.write_fmt(args).unwrap();
}

#[macro_export]
macro_rules! print {
    ($($arg:tt)*) => {
        $crate::console::print(format_args!($($arg)*))
    };
}

#[macro_export]
macro_rules! println {
    () => { $crate::print!("\n") };
    ($fmt:literal $(, $($arg:tt)+)?) => {
        $crate::console::print(format_args!(concat!($fmt, "\n") $(, $($arg)+)?))
    };
}
