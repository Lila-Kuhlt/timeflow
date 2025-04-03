class_name Shared

const SKIP_TITLE_SCREEN := true

enum Tile {
	STRAIGHT,
	CROSS,
	CURVE,
	T
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

func rotate_right(rotation: Rotation) -> Rotation:
	return (rotation - 1) % 4 as Rotation

func rotate_left(rotation: Rotation) -> Rotation:
	return (rotation + 1) % 4 as Rotation
