package main

import "core:fmt"
import "src"

main :: proc() {
    body := src.new_object()
    src.object_set(&body, "name", "kelvi")
    src.object_set(&body, "age", 24)
    
    src.serializer_file("main.njson", body)


    data := src.deserializer_file("main.njson")
    fmt.println(src.object_get(&data.(src.Object), "age"))

    src.object_set(&body, "favorite_color", "all")
    src.serializer_file("main.njson", body)

    data2 := src.deserializer_file("main.njson")
    fmt.println(src.object_get(&data2.(src.Object), "favorite_color"))
}