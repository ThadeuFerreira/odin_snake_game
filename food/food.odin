package food

import rl "vendor:raylib"

FoodType :: enum {
    NORMAL,
    ULTRA_SPEED,
    BONUS_POINTS,
}
Food :: struct {
    offset : rl.Vector2,
    position : rl.Vector2,
    color : rl.Color,
    cellSize : f32,
    foodType : FoodType,
    points : i32,
}

// Draw the food
Draw :: proc(f : ^Food) {
    rl.DrawRectangle(i32(f.offset.x + f.position.x*f.cellSize), i32(f.offset.y + f.position.y*f.cellSize), i32(f.cellSize) -1, i32(f.cellSize) -1, f.color)
}

// Generate a new food
FoodBuilder :: proc(offset : rl.Vector2, position : rl.Vector2, color : rl.Color, cellSize : f32, points : i32, foodType: FoodType) -> ^Food {
    food := new(Food)
    food.offset = offset
    food.position = position
    food.color = color
    food.cellSize = cellSize
    food.points = points
    food.foodType = foodType
    return food
}