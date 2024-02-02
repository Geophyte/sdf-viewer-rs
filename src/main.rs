mod window;
mod state;

fn main() {
    pollster::block_on(window::run());
}
