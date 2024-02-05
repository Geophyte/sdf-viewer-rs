mod window;
mod state;
mod camera;

fn main() {
    pollster::block_on(window::run());
}
