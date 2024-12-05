shader_type particles;

uniform vec3 velocity_direction = vec3(1.0, 0.0, 0.0); // Default direction

void init() {
    VELOCITY = velocity_direction;
}
