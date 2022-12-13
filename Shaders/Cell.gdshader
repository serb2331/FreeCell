shader_type canvas_item;

void fragment(){
//	if(
//		texture(TEXTURE, UV).a == 1.0 &&
//		(texture(TEXTURE, vec2(UV.x + 0.01, UV.y)).a == 1.0 ||
//		texture(TEXTURE, vec2(UV.x, UV.y + 0.01)).a == 1.0 ||
//		texture(TEXTURE, vec2(UV.x - 0.01, UV.y)).a == 1.0 ||
//		texture(TEXTURE, vec2(UV.x, UV.y - 0.01)).a == 1.0)
//	){
//		COLOR = texture(TEXTURE, UV);
//		COLOR.r = 0.8;
//	}
//	else
	if (texture(TEXTURE, UV - 0.01) == vec4(1.0, 1.0, 1.0, 1.0))
		COLOR = texture(TEXTURE, UV - 0.01);
	else
		COLOR = texture(TEXTURE, UV);
	
	//COLOR.a = texture(TEXTURE, UV).a;
}