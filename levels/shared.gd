class_name Shared

const SKIP_TITLE_SCREEN := false

enum Tile {
	STRAIGHT,
	CROSS,
	CURVE,
	T,
	DELAY
}

enum Rotation {
	UP,
	LEFT,
	DOWN,
	RIGHT
}

enum State {
	EMPTY,
	FULL
}

static func rotate_right(rotation: Rotation) -> Rotation:
	return (rotation + 3) % 4 as Rotation

static func rotate_left(rotation: Rotation) -> Rotation:
	return (rotation + 1) % 4 as Rotation

static func reflect(rotation: Rotation) -> Rotation:
	return (rotation + 2) % 4 as Rotation
