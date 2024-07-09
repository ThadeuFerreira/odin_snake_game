package grid

import rl "vendor:raylib"
import "core:math/rand"
import "core:mem"
import "core:container/queue"
import "../snake"
import "../food"

Grid :: struct {
    offset :rl.Vector2,
    width : int,
    height : int,
    cellsize : f32,
    color : rl.Color,
    score : i32,
    hiscore : i32,

    snake : ^snake.Snake,
    food : [dynamic]^food.Food,

    bonusPoints : bool,
    ultraSpeed : bool,
}

previousSnakeState : snake.SnakeState = snake.SnakeState.MOVING
previousSnakeSpeed : f32 = 0.0
food_ultra_speed_timer : f32 = 0.0
food_bonus_points_timer : f32 = 0.0


GridBuilder :: proc(offset : rl.Vector2, width : int, height : int, cellsize : f32, color : rl.Color, score : i32) -> Grid {
    snake := snake.SnakeBuilder(offset, cellsize, snake.SnakeState.MOVING, snake.DIRECTION.right)
    previousSnakeSpeed = snake.speed
    f := food.FoodBuilder(offset, rl.Vector2{10, 10}, rl.RED, cellsize, 10, food.FoodType.NORMAL)
    grid := Grid{
        offset = offset,
        width = width,
        height = height,
        cellsize = cellsize,
        color = color,
        score = score,
        snake = snake,
    }
    elapsedTime = 1.0

    grid.food = make([dynamic]^food.Food,0,20)
    append(&grid.food, f)

    for i in 0..< grid.snake.tail.len {
        rl.TraceLog(rl.TraceLogLevel.INFO, "Snake tail x: %f y: %f", grid.snake.tail.data[i].x, grid.snake.tail.data[i].y)
    }

    for f in grid.food {
        rl.TraceLog(rl.TraceLogLevel.INFO, "Food x: %f y: %f", f.position.x, f.position.y)
    }

    return grid
}

elapsedTime : f32 = 0.0
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
    for f in g.food {
        food.Draw(f)
    }
    // food.Draw(g.food)
    rl.DrawText(rl.TextFormat("Score: %08i", g.score), rl.GetScreenWidth()/2 - i32(g.offset.x), rl.GetScreenHeight() - 100, 20, rl.RED);
    rl.DrawText(rl.TextFormat("HiScore: %08i", g.hiscore), rl.GetScreenWidth()/2 - i32(g.offset.x), rl.GetScreenHeight() - 80, 20, rl.GREEN);
    elapsedTime += rl.GetFrameTime()
    rl.DrawText(rl.TextFormat("Elapsed Time: %02.02f ms", elapsedTime*1000), rl.GetScreenWidth()/2 - i32(g.offset.x), rl.GetScreenHeight() - 60, 20, rl.BLACK);
    if g.ultraSpeed {
        rl.DrawText(rl.TextFormat("Ultra Speed Active"),rl.GetScreenWidth()/2 - i32(g.offset.x), rl.GetScreenHeight() - 40, 20, rl.BLUE);
    }
    if g.bonusPoints {
        rl.DrawText(rl.TextFormat("Bonus Points Active"),rl.GetScreenWidth()/2 - i32(g.offset.x), rl.GetScreenHeight() - 20, 20, rl.GREEN);
    }
    //Draw at the center bottom of the screen
    rl.DrawRectangle(0,0 , i32(g.cellsize -1), i32(g.cellsize -1), rl.RED)
    rl.DrawText(rl.TextFormat("Food"), 0 + i32(g.cellsize), 0, 20, rl.RED)
    rl.DrawRectangle(0, 60, i32(g.cellsize -1),i32(g.cellsize -1), rl.BLUE)
    rl.DrawText(rl.TextFormat("Ultra Speed"), 0 + i32(g.cellsize), 60, 20, rl.BLUE)
    rl.DrawRectangle(0, 120, i32(g.cellsize -1),i32(g.cellsize -1), rl.GREEN)
    rl.DrawText(rl.TextFormat("Bonus Points"), 0 + i32(g.cellsize), 120, 20, rl.GREEN)

}


// Update the grid
Update :: proc(g : ^Grid) {
    snakeSpeedModifier : f32 = 1.0
    pointsModifier : i32 = 1
    if g.ultraSpeed {
        snakeSpeedModifier = 2.0
        pointsModifier = 2
    }else{
        snakeSpeedModifier = 1.0
        pointsModifier = 1
    }

    g.snake.speed = previousSnakeSpeed * snakeSpeedModifier

    snakeState := snake.Update(g.snake, g.food, g.width, g.height)
    if snakeState == snake.SnakeState.DEAD {
        // Reset the snake
        mem.free(g.snake)
        delete(g.food)
        g.food = make([dynamic]^food.Food,0,20)
        g.score = 0
        g.snake = snake.SnakeBuilder(g.offset, g.cellsize, snake.SnakeState.MOVING, snake.DIRECTION.right)
        g.ultraSpeed = false
        g.bonusPoints = false
        previousSnakeSpeed = g.snake.speed
        f := food.FoodBuilder(g.offset, rl.Vector2{10, 10}, rl.RED, g.cellsize, 10, food.FoodType.NORMAL)
        append_elem(&g.food, f)
    }
    if previousSnakeState == snake.SnakeState.MOVING && snakeState == snake.SnakeState.EATING {
        g.score += g.snake.foodRefence.points*pointsModifier
        if g.score > g.hiscore {
            g.hiscore = g.score
        }
        switch g.snake.foodRefence.foodType{
            case food.FoodType.NORMAL : {
                rl.TraceLog(rl.TraceLogLevel.INFO, "Normal food eaten")
            }
            case food.FoodType.ULTRA_SPEED : {
                rl.TraceLog(rl.TraceLogLevel.INFO, "Ultra speed food eaten")
                g.ultraSpeed = true
            }
            case food.FoodType.BONUS_POINTS : {
                rl.TraceLog(rl.TraceLogLevel.INFO, "Bonus points food eaten")
            }
        }
        index := -1
        for i in 0..<len(g.food) {
            if g.food[i] == g.snake.foodRefence {
                index = i
                break
            }
        }
        if g.snake.foodRefence != nil && g.snake.foodRefence.foodType == food.FoodType.NORMAL {
            g.food = make([dynamic]^food.Food,0,20)
            spawn_food(g, g.snake, food.FoodType.NORMAL, 10)
        }
        else {
            unordered_remove(&g.food, index)
        }

        if g.score % 50 == 0 {
            points : i32 = 20
            spawn_food(g, g.snake, food.FoodType.ULTRA_SPEED, points)
        }
        if g.score % 30 == 0 {
            points : i32 = 100
            g.bonusPoints = true
            spawn_food(g, g.snake, food.FoodType.BONUS_POINTS, points)
        }
    }
    if g.ultraSpeed {
        food_ultra_speed_timer += rl.GetFrameTime()
        if food_ultra_speed_timer >= 10.0 {
            g.ultraSpeed = false
            food_ultra_speed_timer = 0.0
            rl.TraceLog(rl.TraceLogLevel.INFO, "Ultra speed food expired")
        }
    }
    if g.bonusPoints {
        food_bonus_points_timer += rl.GetFrameTime()
        if food_bonus_points_timer >= 10.0 {
            g.bonusPoints = false
            food_bonus_points_timer = 0.0
            rl.TraceLog(rl.TraceLogLevel.INFO, "Bonus points food expired")
            index := -1
            for i in 0..<len(g.food) {
                if g.food[i].foodType == food.FoodType.BONUS_POINTS {
                    index = i
                    break
                }
            }
            if index != -1 {
                unordered_remove(&g.food, index)
            }
        }
    }
    previousSnakeState = snakeState
}

spawn_food :: proc(g : ^Grid, s : ^snake.Snake, ft : food.FoodType, points : i32) {
    
    color : rl.Color
    switch ft {
        case food.FoodType.NORMAL : {
            color = rl.RED
        }
        case food.FoodType.ULTRA_SPEED : {
            color = rl.BLUE
        }
        case food.FoodType.BONUS_POINTS : {
            color = rl.GREEN
        }
    }
    for {
        x_cell := rand.int_max(g.width)
        y_cell := rand.int_max(g.height)

        newFoodPosition := rl.Vector2{f32(x_cell), f32(y_cell)}
        valid := true
        if newFoodPosition.x == s.head.x && newFoodPosition.y == s.head.y {
            valid = false
        }
        for i in 0..< g.snake.tail.len{
            if queue.get(&g.snake.tail,i).x == newFoodPosition.x && queue.get(&g.snake.tail,i).y == newFoodPosition.y {
                valid = false
                break
            }
        }
        for f in g.food {
            if newFoodPosition.x == f.position.x && newFoodPosition.y == f.position.y {
                valid = false
                break
            }
        }
        if valid {
            f := food.FoodBuilder(g.offset, rl.Vector2{f32(x_cell), f32(y_cell)}, color, g.cellsize, points, ft)
            append(&g.food, f)
            break
        }
    }
   
}

spawn_normal_food :: proc(g : ^Grid, s : ^snake.Snake) {
    
}