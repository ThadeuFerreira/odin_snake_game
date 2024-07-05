package snake

import rl "vendor:raylib"
import "core:mem"
import "../food"
import "../utils"
import "core:container/queue"
import "core:container/intrusive/list"

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
    tail : queue.Queue(rl.Vector2),

    offset : rl.Vector2,
    cellSize : f32,


    state : SnakeState,
    direction : rl.Vector2,
    speed : f32,

    bodyLength : uint,

}

SnakeBuilder :: proc(offset : rl.Vector2, cellSize : f32, state : SnakeState, direction : rl.Vector2) -> ^Snake{
    tail := []rl.Vector2{{4,5}, {3,5}}
    snake := new(Snake)

    snake.head = {5,5}
    snake.color = SNAKE_COLOR
    snake.offset = offset
    snake.cellSize = cellSize
    snake.state = state
    snake.direction = direction
    queue.init(&snake.tail)
    rl.TraceLog(rl.TraceLogLevel.INFO, "Snake tail len: %d, cap: %d", snake.tail.len, &snake.tail.offset)
    for t in tail {
        queue.push_back(&snake.tail, t)
    }
    rl.TraceLog(rl.TraceLogLevel.INFO, "Snake tail len: %d, cap: %d", snake.tail.len, &snake.tail.offset)
    for i in 0..<snake.tail.len {
        rl.TraceLog(rl.TraceLogLevel.INFO, "Snake tail x: %f y: %f", snake.tail.data[i].x, snake.tail.data[i].y)
    }
    snake.speed = 10
    snake.bodyLength = 3
    return snake
}

snake_timer : f32 = 0.0

Update :: proc(s : ^Snake, f : ^food.Food, gridWidth : int, gridHeight : int) -> SnakeState{
    //Check for input
    if rl.IsKeyPressed(rl.KeyboardKey.UP) && s.direction != DIRECTION.down {
        s.direction = DIRECTION.up
    } else if rl.IsKeyPressed(rl.KeyboardKey.DOWN) && s.direction != DIRECTION.up {
        s.direction = DIRECTION.down
    }else if rl.IsKeyPressed(rl.KeyboardKey.RIGHT) && s.direction != DIRECTION.left {
        s.direction = DIRECTION.right
    }else if rl.IsKeyPressed(rl.KeyboardKey.LEFT) && s.direction != DIRECTION.right {
        s.direction = DIRECTION.left
    }

    //Move the snake
    snake_timer += rl.GetFrameTime()
    if snake_timer >= 1/s.speed {
        snake_timer = 0.0
        s.state = Move(s, f, gridWidth, gridHeight)
    }

    return s.state
}
Move :: proc(s : ^Snake, f: ^food.Food, gridWidth : int, gridHeight : int) -> SnakeState{
    
    rl.TraceLog(rl.TraceLogLevel.INFO, "Snake head x: %f y: %f", s.head.x, s.head.y)
    if s.head.x < 0 || s.head.y < 0 || int(s.head.x) >= gridWidth || int(s.head.y) >= gridHeight {
        return SnakeState.DEAD
    }

    for i in 0..< s.tail.len{
        rl.TraceLog(rl.TraceLogLevel.INFO, "Snake tail x: %f y: %f", queue.get(&s.tail,i).x, queue.get(&s.tail,i).y)
        if s.head.x == queue.get(&s.tail,i).x && s.head.y == queue.get(&s.tail,i).y {
            return SnakeState.DEAD
        }
    }
    
    snakeState := SnakeState.MOVING
    if s.head.x == f.position.x && s.head.y == f.position.y {
        s.bodyLength += 1
        queue.push_back(&s.tail, s.head)
        snakeState = SnakeState.EATING
    }

    newHead := s.head + s.direction
    
    queue.push_back(&s.tail, s.head)
    s.head = newHead
    if s.tail.len > s.bodyLength -1{
        queue.pop_front(&s.tail)
    }

    return snakeState
}

Draw :: proc(s : ^Snake){
    rl.DrawRectangle(i32(s.offset.x + s.head.x*f32(s.cellSize)), i32(s.offset.y + s.head.y*f32(s.cellSize)), i32(s.cellSize) -1, i32(s.cellSize) -1, SNAKE_COLOR)
    for i in 0..<s.tail.len {
        // rl.TraceLog(rl.TraceLogLevel.INFO, "Snake tail x: %f y: %f", t.x, t.y)
        rl.DrawRectangle(i32(s.offset.x + queue.get(&s.tail,i).x*f32(s.cellSize)), 
        i32(s.offset.y + queue.get(&s.tail,i).y*f32(s.cellSize)), 
        i32(s.cellSize) -1, i32(s.cellSize) -1, 
        SNAKE_COLOR)
    }
}

