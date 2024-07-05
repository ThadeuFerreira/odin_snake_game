package grid

import rl "vendor:raylib"
import "core:math/rand"
import "core:mem"
import "../snake"
import "../food"

Grid :: struct {
    offset :rl.Vector2,
    width : int,
    height : int,
    cellsize : f32,
    color : rl.Color,
    score : i32,

    snake : ^snake.Snake,
    food : ^food.Food,
}

GridBuilder :: proc(offset : rl.Vector2, width : int, height : int, cellsize : f32, color : rl.Color, score : i32) -> Grid {
    snake := snake.SnakeBuilder(offset, cellsize, snake.SnakeState.MOVING, snake.DIRECTION.right)
    food := food.FoodBuilder(offset, rl.Vector2{10, 10}, rl.RED, cellsize, 10)
    grid := Grid{
        offset = offset,
        width = width,
        height = height,
        cellsize = cellsize,
        color = color,
        score = score,
        snake = snake,
        food = food,
    }

    for i in 0..< grid.snake.tail.len {
        rl.TraceLog(rl.TraceLogLevel.INFO, "Snake tail x: %f y: %f", grid.snake.tail.data[i].x, grid.snake.tail.data[i].y)
    }

    return grid
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
    food.Draw(g.food)
}

previousSnakeState : snake.SnakeState = snake.SnakeState.MOVING
// Update the grid
Update :: proc(g : ^Grid) {
    snakeState := snake.Update(g.snake, g.food, g.width, g.height)
    if snakeState == snake.SnakeState.DEAD {
        // Reset the snake
        mem.free(g.snake)
        mem.free(g.food)
        g.score = 0
        g.snake = snake.SnakeBuilder(g.offset, g.cellsize, snake.SnakeState.MOVING, snake.DIRECTION.right)
        g.food = food.FoodBuilder(g.offset, rl.Vector2{10, 10}, rl.RED, g.cellsize, 10)
    }
    if previousSnakeState == snake.SnakeState.MOVING && snakeState == snake.SnakeState.EATING {
        spawn_food(g, g.snake)
    }
    previousSnakeState = snakeState
    
}

spawn_food :: proc(g : ^Grid, s : ^snake.Snake) {
    mem.free(g.food)
    for {
        x_cell := rand.int_max(g.width)
        y_cell := rand.int_max(g.height)

        newFoodPosition := rl.Vector2{f32(x_cell), f32(y_cell)}
        valid := true
        if newFoodPosition.x == s.head.x && newFoodPosition.y == s.head.y {
            valid = false
        }
        for t, _ in s.tail.data {
            if t.x == newFoodPosition.x && t.y == newFoodPosition.y {
                valid = false
                break
            }
        }
        if valid {
            f := food.FoodBuilder(g.offset, rl.Vector2{f32(x_cell), f32(y_cell)}, rl.RED, g.cellsize, 10)
            g.food = f
            break
        }
    }
}