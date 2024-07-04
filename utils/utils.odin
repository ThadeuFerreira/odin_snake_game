package utils

import "core:fmt"
import "core:mem"

SliceDeque :: struct {
    data: []int,
}

push_front :: proc(deque: ^SliceDeque, value: int) {
    // Resize the slice to make space for the new element
    new_data := make([]int, len(deque.data) + 1)
    mem.copy(&new_data[1], &deque.data[0], len(deque.data) * size_of(int))
    new_data[0] = value
    deque.data = new_data
}

pop_back :: proc(deque: ^SliceDeque) -> int {
    value := deque.data[len(deque.data) - 1]
    // Resize the slice to shrink it
    deque.data = deque.data[:len(deque.data) - 1]
    return value
}