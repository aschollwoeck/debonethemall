extends GutTest
## Tests the pixel-art pipeline helper (PixelArt) that produces NEAREST-filtered unit sprites for
## the mixed-resolution look. The pipeline is what keeps units crisp pixels on the smooth world,
## so its contract (texture size, nearest filter, feet-at-origin offset) is worth pinning.


func test_canvas_is_transparent_rgba() -> void:
	var img := PixelArt.canvas(8, 10)
	assert_eq(img.get_width(), 8)
	assert_eq(img.get_height(), 10)
	assert_eq(img.get_format(), Image.FORMAT_RGBA8)
	assert_almost_eq(img.get_pixel(0, 0).a, 0.0, 0.001, "starts fully transparent")


func test_rect_and_px_write() -> void:
	var img := PixelArt.canvas(8, 8)
	PixelArt.rect(img, 2, 2, 3, 3, Color.RED)
	PixelArt.px(img, 0, 0, Color.GREEN)
	assert_eq(img.get_pixel(3, 3), Color.RED)
	assert_eq(img.get_pixel(0, 0), Color.GREEN)
	assert_almost_eq(img.get_pixel(7, 7).a, 0.0, 0.001, "untouched pixel stays clear")


func test_px_out_of_bounds_is_ignored() -> void:
	var img := PixelArt.canvas(4, 4)
	PixelArt.px(img, -1, 0, Color.RED)   # must not crash
	PixelArt.px(img, 4, 4, Color.RED)
	assert_true(true)


func test_rect_clips_off_canvas_without_crashing() -> void:
	var img := PixelArt.canvas(4, 4)
	PixelArt.rect(img, 2, 2, 10, 10, Color.RED)   # overflows the canvas — must clip, not crash
	assert_eq(img.get_pixel(3, 3), Color.RED, "the in-bounds part is written")


func test_hline_and_vline() -> void:
	var img := PixelArt.canvas(6, 6)
	PixelArt.hline(img, 1, 2, 4, Color.RED)
	PixelArt.vline(img, 3, 0, 5, Color.GREEN)
	assert_eq(img.get_pixel(4, 2), Color.RED, "hline spans the row")
	assert_eq(img.get_pixel(3, 4), Color.GREEN, "vline spans the column")
	assert_almost_eq(img.get_pixel(0, 0).a, 0.0, 0.001, "untouched stays clear")


func test_line_draws_endpoints_and_a_diagonal() -> void:
	var img := PixelArt.canvas(8, 8)
	PixelArt.line(img, 1, 1, 6, 6, Color.RED)
	assert_eq(img.get_pixel(1, 1), Color.RED, "start endpoint set")
	assert_eq(img.get_pixel(6, 6), Color.RED, "end endpoint set")
	assert_eq(img.get_pixel(3, 3), Color.RED, "diagonal midpoint set")
	assert_almost_eq(img.get_pixel(7, 0).a, 0.0, 0.001, "off-line pixel stays clear")


func test_line_off_canvas_is_clipped_not_crashing() -> void:
	var img := PixelArt.canvas(4, 4)
	PixelArt.line(img, -3, -3, 6, 6, Color.RED)   # runs off both ends — must clip via px bounds
	assert_eq(img.get_pixel(1, 1), Color.RED, "the in-bounds part is written")


func test_sprite_is_nearest_upscaled_feet_at_origin() -> void:
	var img := PixelArt.canvas(16, 24)
	var spr := PixelArt.sprite(img, 3.0)
	add_child_autofree(spr)
	assert_eq(spr.texture.get_width(), 16)
	assert_eq(spr.texture.get_height(), 24)
	assert_eq(spr.texture_filter, CanvasItem.TEXTURE_FILTER_NEAREST, "units render nearest (crisp pixels)")
	assert_eq(spr.scale, Vector2(3, 3))
	assert_false(spr.centered)
	assert_eq(spr.offset, Vector2(-8, -24), "origin at bottom-centre (feet)")
