struct VertexInput {
    @location(0) position: vec2<f32>,
};

struct VertexOutput {
    @builtin(position) clip_position: vec4<f32>,
};

@vertex
fn vs_main(
    model: VertexInput,
) -> VertexOutput {
    var out: VertexOutput;
    out.clip_position = vec4<f32>(model.position, 0.0, 1.0);
    return out;
}

struct ScreenUniform {
    width: u32,
    height: u32
}

@group(0) @binding(0)
var<uniform> screen_uniform: ScreenUniform;

@fragment
fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {
    let center = vec2<f32>(f32(screen_uniform.width) / 2.0, f32(screen_uniform.height) / 2.0);
    let half_size = vec2<f32>(50.0, 50.0);

    let distance_to_center = abs(in.clip_position.xy - center);
    let is_inside_square = distance_to_center.x < half_size.x && distance_to_center.y < half_size.y;

    if is_inside_square {
        return vec4<f32>(0.0, 1.0, 0.0, 1.0);
    } else {
        return vec4<f32>(1.0, 0.0, 0.0, 1.0);
    }
}