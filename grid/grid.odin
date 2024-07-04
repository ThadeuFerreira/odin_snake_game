package grid

import rl "vendor:raylib"
import "../snake"
import "../food"

Grid :: struct {
    offset :rl.Vector2,
    width : int,
    height : int,
    cellsize : f32,
    color : rl.Color,
    score : i32,

    snake : snake.Snake,
    food : food.Food,
}

GridBuilder :: proc(offset : rl.Vector2, width : int, height : int, cellsize : f32, color : rl.Color, score : i32) -> Grid {
    snake : snake.Snake = snake.SnakeBuilder(offset, cellsize, snake.SnakeState.MOVING, snake.DIRECTION.right)
    food : food.Food = food.FoodBuilder(offset, rl.Vector2{10, 10}, rl.RED, cellsize)
    result := Grid{
        offset = offset,
        width = width,
        height = height,
        cellsize = cellsize,
        color = color,
        score = score,
        snake = snake,
        food = food,
    }

    for t in result.snake.tail {
        rl.TraceLog(rl.TraceLogLevel.INFO, "Snake tail x: %f y: %f", t.x, t.y)
    }

    return result
}


// Draw the grid
Draw :: proc(g : ^Grid) {
    for i in 0..<g.width {
        for j in 0..<g.height {
            rl.DrawRectangle(i32(g.offset.x + f32(i) * g.cellsize), 
            i32(g.offset.y + f32(j) * g.cellsize), 
            i32(g.cellsize -1), 
            i32(g.cellsize -1), 
            g.color)
        }
    }
    snake.Draw(g.snake)
    food.Draw(&g.food)
}

// Update the grid
Update :: proc(g : ^Grid) {
    snake.Update(&g.snake, &g.food, g.width, g.height)
    
}