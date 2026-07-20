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
