use cgmath::prelude::*;
use cgmath::{Deg, InnerSpace, Matrix4, Vector3, Vector2};
use std::time::Instant;
use winit::event::WindowEvent;

pub struct Camera {
    position: Vector3<f32>,
    forward: Vector3<f32>,
    up: Vector3<f32>,
    right: Vector3<f32>,
    pitch: f32,
    yaw: f32,
    speed: f32,
    sensitivity: f32,
    last_frame: Instant,
}

impl Camera {
    pub fn new() -> Self {
        return Camera {
            position: (0.0, 0.0, 5.0).into(),
            forward: (0.0, 0.0, -1.0).into(),
            up: (0.0, 1.0, 0.0).into(),
            right: (1.0, 0.0, 0.0).into(),
            pitch: 0.0,
            yaw: -90.0,
            speed: 0.05,
            sensitivity: 0.005,
            last_frame: Instant::now(),
        };
    }

    pub fn process_input(&mut self, event: &WindowEvent) {
        let delta_time = self.last_frame.elapsed().as_secs_f32();
        // Accumulate movement vectors
        let mut movement = Vector3::new(0.0, 0.0, 0.0);
        let mut rotation = Vector2::new(0.0, 0.0);

        match event {
            WindowEvent::KeyboardInput { input, .. } => {
                if let Some(key_code) = input.virtual_keycode {
                    match key_code {
                        winit::event::VirtualKeyCode::A => movement -= self.right,
                        winit::event::VirtualKeyCode::D => movement += self.right,
                        winit::event::VirtualKeyCode::W => movement += self.forward,
                        winit::event::VirtualKeyCode::S => movement -= self.forward,
                        winit::event::VirtualKeyCode::Left => rotation.x -= 1.0,
                        winit::event::VirtualKeyCode::Right => rotation.x += 1.0,
                        winit::event::VirtualKeyCode::Up => rotation.y -= 1.0,
                        winit::event::VirtualKeyCode::Down => rotation.y += 1.0,
                        _ => {}
                    }
                }
            }
            _ => {}
        }

        // Update camera orientation
        self.yaw += rotation.x * 90.0 * self.sensitivity * delta_time;
        self.pitch += rotation.y * 90.0 * self.sensitivity * delta_time;

        // Ensure yaw and pitch stay within bounds
        self.pitch = self.pitch.clamp(-89.0, 89.0);

        // Update camera position
        self.position += movement * self.speed * delta_time;

        // Print debug information
        println!("position: {:?}", self.position);
        println!("yaw: {}", self.yaw);
        println!("pitch: {}", self.pitch);

        // Update camera vectors
        self.update_vectors();
    }

    fn update_vectors(&mut self) {
        let yaw_degrees = Deg(self.yaw);
        let pitch_degrees = Deg(self.pitch);

        self.forward = Vector3::new(
            Deg::cos(yaw_degrees) * Deg::cos(pitch_degrees),
            Deg::sin(pitch_degrees),
            Deg::sin(yaw_degrees) * Deg::cos(pitch_degrees),
        )
        .normalize();

        self.right = self.forward.cross(Vector3::unit_y()).normalize();
        self.up = self.right.cross(self.forward).normalize();
    }

    pub fn get_rotation_matrix(&self) -> [[f32; 4]; 4] {
        let rotation_matrix = Matrix4::from_cols(
            self.right.extend(0.0),
            self.up.extend(0.0),
            (-self.forward).extend(0.0),
            Vector3::zero().extend(1.0),
        );
        rotation_matrix.transpose().into()
    }

    pub fn position(&self) -> [f32; 4] {
        self.position.extend(0.0).into()
    }
}
