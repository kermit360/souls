shader_type canvas_item;

uniform float repeat_threshold : hint_range(0.0, 1.0) = 8000; // Y position to stop repeating (normalized 0-1)

void fragment() {
    vec2 uv = UV;

    if (uv.y > repeat_threshold) {
        // Replace the current pixel with the bottom-most line of the texture
        uv.y = 1.0; // Clamp UV to the bottom of the texture
    }

    COLOR = texture(TEXTURE, uv);
}
