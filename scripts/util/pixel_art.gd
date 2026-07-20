extends RefCounted
class_name PixelArt
## The pixel half of the mixed-resolution look (docs/art-direction.md §0, M2b).
##
## Since the game now renders smooth at native resolution (stretch `canvas_items` + Linear
## filter), a plain `_draw()` sprite would render smooth too. To keep UNITS as crisp pixel art,
## author them into a small `Image` with these block/pixel ops, then display via `sprite()` — a
## **NEAREST-filtered** `Sprite2D` upscaled by an integer factor. Only units use this; the world
## and UI stay smooth. Units are drawn ~30–48 px tall for the fine grid (§6).

## A blank transparent RGBA canvas to author a sprite into.
static func canvas(w: int, h: int) -> Image:
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	return img


## Fill a block of pixels.
static func rect(img: Image, x: int, y: int, w: int, h: int, col: Color) -> void:
	img.fill_rect(Rect2i(x, y, w, h), col)


## Set a single pixel (bounds-checked).
static func px(img: Image, x: int, y: int, col: Color) -> void:
	if x >= 0 and y >= 0 and x < img.get_width() and y < img.get_height():
		img.set_pixel(x, y, col)


## A 1px-thick horizontal or vertical line (kept axis-aligned — pixel art favours straight runs).
## A 1px-thick horizontal run.
static func hline(img: Image, x: int, y: int, w: int, col: Color) -> void:
	img.fill_rect(Rect2i(x, y, w, 1), col)


## A 1px-thick vertical run.
static func vline(img: Image, x: int, y: int, h: int, col: Color) -> void:
	img.fill_rect(Rect2i(x, y, 1, h), col)


## A 1px Bresenham line between two points — for diagonals (bows, chains, shroud edges).
## Axis-aligned runs still prefer hline/vline.
static func line(img: Image, x0: int, y0: int, x1: int, y1: int, col: Color) -> void:
	var dx := absi(x1 - x0)
	var dy := -absi(y1 - y0)
	var sx := 1 if x0 < x1 else -1
	var sy := 1 if y0 < y1 else -1
	var err := dx + dy
	while true:
		px(img, x0, y0, col)
		if x0 == x1 and y0 == y1:
			break
		var e2 := 2 * err
		if e2 >= dy:
			err += dy
			x0 += sx
		if e2 <= dx:
			err += dx
			y0 += sy


## A NEAREST-filtered Sprite2D from pixel art, upscaled by `scale`. Origin sits at the art's
## bottom-centre (feet), matching how units are positioned by their base.
## Pass a **whole-number** `scale` (uneven scales shimmer under NEAREST), and prefer **even
## widths** so the bottom-centre origin lands on a texel boundary (odd widths soften the centre).
static func sprite(img: Image, scale: float) -> Sprite2D:
	var spr := Sprite2D.new()
	spr.texture = ImageTexture.create_from_image(img)
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	spr.scale = Vector2(scale, scale)
	spr.centered = false
	spr.offset = Vector2(-img.get_width() / 2.0, -float(img.get_height()))
	return spr
