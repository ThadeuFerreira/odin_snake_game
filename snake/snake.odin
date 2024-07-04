package snake

import rl "vendor:raylib"
import "core:mem"
import "../food"
import "../utils"

SNAKE_COLOR : rl.Color = { 43, 51, 24, 255 };

SnakeState :: enum{
    IDLE,
    MOVING,
    DEAD,
    EATING,
}

Direction :: struct {
    up, down, left, right: rl.Vector2,
}

DIRECTION: Direction = {
    up    = { 0, -1 },
    down  = { 0, 1 },
    left  = { -1, 0 },
    right = { 1, 0 },
}

Snake :: struct{
    color : rl.Color,
    head : rl.Vector2,
    tail : []rl.Vector2,

    offset : rl.Vector2,
    cellSize : f32,


    state : SnakeState,
    direction : rl.Vector2,
    speed : f32,

    bodyLength : int,

}

SnakeBuilder :: proc(offset : rl.Vector2, cellSize : f32, state : SnakeState, direction : rl.Vector2) -> Snake{
    tail := []rl.Vector2{{4,5}, {3,5}}
    result := Snake{
        head = {5,5},
        tail = make([]rl.Vector2, len(tail)),
        color = SNAKE_COLOR,
        offset = offset,
        cellSize = cellSize,

        state = state,
        direction = direction,
    }
    copy(result.tail, tail)
    for t in result.tail {
        rl.TraceLog(rl.TraceLogLevel.INFO, "Snake tail x: %f y: %f", t.x, t.y)
    }
    result.speed = 5.0
    result.bodyLength = 3
    return result
}

snake_timer : f32 = 0.0

Update :: proc(s : ^Snake, f : ^food.Food, gridWidth : int, gridHeight : int) -> SnakeState{
    //Check for input
    if rl.IsKeyPressed(rl.KeyboardKey.UP) && s.direction != DIRECTION.down {
        s.direction = DIRECTION.up
    } else if rl.IsKeyPressed(rl.KeyboardKey.DOWN) && s.direction != DIRECTION.up {
        s.direction = DIRECTION.down
    } else if rl.IsKeyPressed(rl.KeyboardKey.LEFT) && s.direction != DIRECTION.right {
        s.direction = DIRECTION.left
    } else if rl.IsKeyPressed(rl.KeyboardKey.RIGHT) && s.direction != DIRECTION.left {
        s.direction = DIRECTION.right
    }

    //Move the snake
    snake_timer += rl.GetFrameTime()
    if snake_timer >= 0.1 {
        snake_timer = 0.0
        s.state = Move(s, f, gridWidth, gridHeight)
    }

    return s.state
}
Move :: proc(s : ^Snake, f: ^food.Food, gridWidth : int, gridHeight : int) -> SnakeState{
    if s.head.x < 0 || s.head.y < 0 || s.head.x >= f32(gridWidth) || s.head.y >= f32(gridHeight) {
        return SnakeState.DEAD
    }

    for t in s.tail {
        rl.TraceLog(rl.TraceLogLevel.INFO, "Snake head x: %f y: %f", s.head.x, s.head.y)
        rl.TraceLog(rl.TraceLogLevel.INFO, "Snake tail x: %f y: %f", t.x, t.y)
        if s.head.x == t.x && s.head.y == t.y {
            return SnakeState.DEAD
        }
    }

    snakeState := SnakeState.MOVING
    if s.head.x == f.position.x && s.head.y == f.position.y {
        s.bodyLength += 1
        new_data := make([]rl.Vector2, len(s.tail) + 1)
        mem.copy(&new_data[1], &s.tail[0], len(s.tail) * size_of(rl.Vector2))
        new_data[0] = s.head
        s.tail = new_data
        snakeState = SnakeState.EATING
    }
    newHead := s.head + s.direction
    new_date := make([]rl.Vector2, len(s.tail) + 1)
    new_date[0] = s.head
    s.head = newHead
    mem.copy(&new_date[1], &s.tail[0], len(s.tail) * size_of(rl.Vector2))

    s.tail = new_date[:s.bodyLength -1] 

    return snakeState
}

Draw :: proc(s : Snake){
    rl.DrawRectangle(i32(s.offset.x + s.head.x*f32(s.cellSize)), i32(s.offset.y + s.head.y*f32(s.cellSize)), i32(s.cellSize) -1, i32(s.cellSize) -1, SNAKE_COLOR)
    for t in s.tail {
        // rl.TraceLog(rl.TraceLogLevel.INFO, "Snake tail x: %f y: %f", t.x, t.y)
        rl.DrawRectangle(i32(s.offset.x + t.x*f32(s.cellSize)), 
        i32(s.offset.y + t.y*f32(s.cellSize)), 
        i32(s.cellSize) -1, i32(s.cellSize) -1, 
        SNAKE_COLOR)
    }
}

