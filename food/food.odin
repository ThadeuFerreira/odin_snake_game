package food

import rl "vendor:raylib"

Food :: struct {
    offset : rl.Vector2,
    position : rl.Vector2,
    color : rl.Color,
    cellSize : f32,
}

// Draw the food
Draw :: proc(f : ^Food) {
    rl.DrawRectangle(i32(f.offset.x + f.position.x*f.cellSize), i32(f.offset.y + f.position.y*f.cellSize), i32(f.cellSize) -1, i32(f.cellSize) -1, f.color)
}

// Generate a new food
FoodBuilder :: proc(offset : rl.Vector2, position : rl.Vector2, color : rl.Color, cellSize : f32) -> Food {
    result := Food{
        offset = offset,
        position = position,
        color = color,
        cellSize = cellSize,
    }
    return result
}