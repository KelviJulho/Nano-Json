package main

import "core:os"
import "core:fmt"
import "src"

main :: proc() {
    writer := src.new_writer()
    arr := src.new_array()
    src.array_append(&arr, "kelvi")

    obj := src.new_object()

    col := src.new_array()
    src.array_append(&col, "RED")
    src.array_append(&col, "YELLOW")
    src.array_append(&col, "PURPLE")
    src.object_set(&obj, "colors", col)

    foo := src.new_array()
    src.array_append(&foo, "BREAD")
    src.array_append(&foo, "APPLE")
    src.array_append(&foo, "COOKIE")
    src.object_set(&obj, "foods", foo)

    src.array_append(&arr, obj)
    src.serialize_array(&writer, arr)
    src.save(&writer, "main.njson")

    fmt.printf("%v", src.open("main.njson"))
}