shader_type canvas_item;

uniform float blue_intensity = 0.0;

void fragment(){
	if(
		texture(TEXTURE, UV).a != 1.0 
//		(texture(TEXTURE, vec2(UV.x + 0.00001, UV.y)).a == 1.0 ||
//		texture(TEXTURE, vec2(UV.x, UV.y + 0.00001)).a == 1.0 ||
//		texture(TEXTURE, vec2(UV.x - 0.00001, UV.y)).a == 1.0 ||
//		texture(TEXTURE, vec2(UV.x, UV.y - 0.00001)).a == 1.0)
	){
		COLOR = texture(TEXTURE, UV);
		COLOR.r = 0.5;
	}
	
	//COLOR.a = texture(TEXTURE, UV).a;
}