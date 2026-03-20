#+feature dynamic-literals

package src

import "core:fmt"
import "core:os"

Opecodes :: enum u8 {
    Nil,
    Boolean,
    Number,
    String,
    Array,
    Object,
    End,
}
Instructions := map[u8]Opecodes{
    0 = .Nil,
    1 = .Boolean,
    2 = .Number,
    3 = .String,
    4 = .Array,
    5 = .Object,
    6 = .End,
}

Array:: struct{
    elements : [dynamic]Data
}
new_array :: proc() -> Array {
    return {make_dynamic_array([dynamic]Data)}
}
array_append :: proc(self : ^Array, data : Data) {
    append(&self.elements, data)
}
array_remove :: proc(self : ^Array, index : uint) {
    ordered_remove(&self.elements, index)
}

Object :: struct{
    elements : map[string]Data
}
new_object :: proc() -> Object {
    return {make_map(map[string]Data)}
}
//create a new key or set new value
object_set :: proc(self : ^Object, key : string, value : Data) {
    self.elements[key] = value
}
//get key data, if not exist key return nil
object_get :: proc(self : ^Object, key : string) -> Data {
    if data, ok := self.elements[key]; ok do return data
    return nil
}
//remove key
object_remove :: proc(self : ^Object, key : string) {
    delete_key(&self.elements, key)
}

Data :: union {
    bool,
    f64,
    string,
    Array,
    Object,
}

serializer :: proc(writer : ^Writer, data : Data) {
    switch value in data {
        case nil:
            writer_u8(writer, u8(Opecodes.Nil))
        case bool:
            writer_u8(writer, u8(Opecodes.Boolean))

            writer_u8(writer, u8(value))
        case f64:
            writer_u8(writer, u8(Opecodes.Number))

            writer_f64(writer, value)
        case string:
            writer_u8(writer, u8(Opecodes.String))

            writer_string(writer, value)
        case Array:
            writer_u8(writer, u8(Opecodes.Array))

            for element in value.elements do serializer(writer, element)
            
            writer_u8(writer, u8(Opecodes.End))
        case Object:
            writer_u8(writer, u8(Opecodes.Object))

            for key, value in value.elements {
                serializer(writer, key)
                serializer(writer, value)
            }

            writer_u8(writer, u8(Opecodes.End))
    }
}
serializer_file :: proc(path : string, data : Data) {
    writer := new_writer()
    serializer(&writer, data)

    os.write_entire_file(path, writer.buffer[:])
}

deserializer :: proc(reader : ^Reader) -> Data {
    opecode := Instructions[reader_u8(reader)]
    #partial switch opecode {
        case .Nil:
        case .Boolean:
            return Data(reader_u8(reader) != 0)
        case .Number:
            return Data(reader_f64(reader))
        case .String:
            return Data(reader_string(reader))
        case .Array:
            buffer := new_array()
            for reader_can_consume(reader) && reader_peek(reader) != u8(Opecodes.End) do array_append(&buffer, deserializer(reader))

            reader_u8(reader)

            return buffer
        case .Object:
            buffer := new_object()
            for reader_can_consume(reader) && reader_peek(reader) != u8(Opecodes.End) do object_set(&buffer, deserializer(reader).(string), deserializer(reader))

            reader_u8(reader)

            return buffer
    }
    return nil
}
deserializer_file :: proc(path : string) -> Data {
    data, ok := os.read_entire_file(path)
    assert(ok, fmt.aprintfln("error in open file '%s'", path))

    reader := new_reader(data)
    return deserializer(&reader)
}
