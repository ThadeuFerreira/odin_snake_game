package game

import rl "vendor:raylib"
import "grid"
import "snake"

screenWidth :: 1000
screenHeight :: 1000

BACKGROUND_COLOR : rl.Color = { 173, 204, 96, 255 }

CELL_SIZE :: 30
CELL_COUNT_X :: 20
CELL_COUNT_Y :: 30

main :: proc()
{
    // Initialization
    //--------------------------------------------------------------------------------------
   gridOffset := rl.Vector2{100,0}

   gridInstance := grid.GridBuilder(
    gridOffset,
    CELL_COUNT_X,
    CELL_COUNT_Y,
    CELL_SIZE,
    BACKGROUND_COLOR,
    0,
   )

   for i in 0..< gridInstance.snake.tail.len {
    rl.TraceLog(rl.TraceLogLevel.INFO, "Snake tail x: %f y: %f", gridInstance.snake.tail.data[i].x, gridInstance.snake.tail.data[i].y)
}
    

    rl.InitWindow(screenWidth, screenHeight, "raylib [core] example - basic window");


    rl.SetTargetFPS(60) // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------
    rl.SetTraceLogLevel(rl.TraceLogLevel.ALL) // Show trace log messages (LOG_INFO, LOG_WARNING, LOG_ERROR, LOG_DEBUG)
    // Main game loop
    for !rl.WindowShouldClose()    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        rl.BeginDrawing()
        rl.ClearBackground(rl.WHITE)
        grid.Update(&gridInstance)
        grid.Draw(&gridInstance)
        rl.EndDrawing()
    }

    rl.CloseWindow()
}