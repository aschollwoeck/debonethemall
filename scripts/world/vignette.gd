extends Node2D
class_name Vignette
## Heavy edge vignette (M2 slice 2, docs/art-direction.md §5) — crushes the screen edges into
## oppressive dark so the eerie light is the only mercy. Drawn over the world but under the HUD
## (a separate CanvasLayer). A soft dark radial, generated once as a small texture and stretched.

var _tex: Texture2D


func _ready() -> void:
	z_index = 8   # above the lighting pass, under the HUD
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_tex = _make(120, 68)
	queue_redraw()


func _draw() -> void:
	draw_texture_rect(_tex, Rect2(0, 0, 480, 270), false)


func _make(w: int, h: int) -> Texture2D:
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	var cx := w * 0.5
	var cy := h * 0.46   # focus slightly above centre, where the action is
	var maxd := Vector2(maxf(cx, w - cx), maxf(cy, h - cy)).length()
	for y in h:
		for x in w:
			var d := Vector2(x - cx, y - cy).length() / maxd
			var t := clampf((d - 0.42) / 0.58, 0.0, 1.0)
			img.set_pixel(x, y, Color(0.02, 0.01, 0.03, t * t * 0.88))
	return ImageTexture.create_from_image(img)
