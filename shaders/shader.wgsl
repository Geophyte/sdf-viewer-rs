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

struct CameraUniform {
    position: vec4<f32>,
    rotation: mat4x4<f32>
}

@group(1) @binding(0)
var<uniform> camera_uniform: CameraUniform;

@fragment
fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {
    var uv: vec2<f32> = getUV(in) * 2.0 - 1.0;

    let ro: vec3<f32> = vec3<f32>(0.0, 0.0, 0.0);
    var rd: vec3<f32> = normalize((camera_uniform.rotation * vec4<f32>(vec2<f32>(uv), -1.0, 0.0)).xyz);

    let shadedColor: vec3<f32> = rayMarch(ro, rd);

    return vec4<f32>(shadedColor, 1.0);
}

fn getUV(in: VertexOutput) -> vec2<f32> {
    let x: f32 = in.clip_position.x;
    let y: f32 = in.clip_position.y;

    let aspectRatio: f32 = f32(screen_uniform.width) / f32(screen_uniform.height);
    var normalizedX: f32 = x / (f32(screen_uniform.width) - 1.0); // -1
    var normalizedY: f32 = y / (f32(screen_uniform.height) - 1.0); // -1

    if (aspectRatio > 1.0) {
        normalizedY = (normalizedY - 0.5) / aspectRatio + 0.5;
    } else {
        normalizedX = (normalizedX - 0.5) * aspectRatio + 0.5;
    }

    return vec2<f32>(normalizedX, normalizedY);
}

fn rayMarch(ro: vec3<f32>, rd: vec3<f32>) -> vec3<f32> {
    var totalDistanceTraveled: f32 = 0.0;
    let NUMBER_OF_STEPS: i32 = 32;
    let MINIMUM_HIT_DISTANCE: f32 = 0.001;
    let MAXIMUM_TRACE_DISTANCE: f32 = 1000.0;

    for (var i: i32 = 0; i < NUMBER_OF_STEPS; i = i + 1) {
        let currentPosition: vec3<f32> = ro + totalDistanceTraveled * rd;

        let distanceToClosest: f32 = mapTheWorld(currentPosition);

        if (distanceToClosest < MINIMUM_HIT_DISTANCE) {
            let normal: vec3<f32> = calculateNormal(currentPosition);

            let lightPosition: vec3<f32> = vec3<f32>(2.0, -5.0, -3.0);
            let lightDirection: vec3<f32> = normalize(currentPosition - lightPosition);
            let diffuseInstensity: f32 = max(0.0, dot(normal, lightDirection));

            return vec3<f32>(1.0, 0.0, 0.0) * diffuseInstensity;
        }
        if (totalDistanceTraveled > MAXIMUM_TRACE_DISTANCE) {
            break;
        }

        totalDistanceTraveled = totalDistanceTraveled + distanceToClosest;
    }

    return vec3<f32>(0.0);
}

fn calculateNormal(p: vec3<f32>) -> vec3<f32> {
    let smallStep: vec3<f32> = vec3<f32>(0.001, 0.0, 0.0);

    let gradientX: f32 = mapTheWorld(p + smallStep.xyy) - mapTheWorld(p - smallStep.xyy);
    let gradientY: f32 = mapTheWorld(p + smallStep.yxy) - mapTheWorld(p - smallStep.yxy);
    let gradientZ: f32 = mapTheWorld(p + smallStep.yyx) - mapTheWorld(p - smallStep.yyx);

    let normal: vec3<f32> = vec3<f32>(gradientX, gradientY, gradientZ);

    return normalize(normal);
}

fn mapTheWorld(p: vec3<f32>) -> f32 {
    var new_p: vec3<f32> = p + camera_uniform.position.xyz;
    // new_p = opRep(new_p, vec3<f32>(3.0, 3.0, 3.0));

    let sphere_0: f32 = sdSphere(new_p, vec3<f32>(2.0, 0.0, 0.0), 1.0);

    return sphere_0;
}

fn sdSphere(p: vec3<f32>, c: vec3<f32>, radius: f32) -> f32 {
    return length(p - c) - radius;
}

fn sdTorus(p: vec3<f32>, inner_radius: f32, outer_radius: f32) -> f32 {
    let q: vec2<f32> = vec2<f32>(length(p.xz) - outer_radius, p.y);
    return length(q) - inner_radius;
}

fn opRep(p: vec3<f32>, c: vec3<f32>) -> vec3<f32> {
    let q: vec3<f32> = p - c * floor(p / c);
    return q - c * vec3<f32>(0.5, 0.5, 0.5);
}