//This is a serializer; it serializes data by writing to bytes and uses "opcodes" like a virtual machine. 
//I call it "NanoJson," but it has nothing to do with "JSON"—it just works like "JSON," being able to serialize numbers, arrays, objects, and more!

package src

import "core:fmt"
import "core:os"

serialize :: proc(writer : ^Writer, data : Data) {
    switch value in data {
        case nil:
            serialize_nil(writer)
        case bool:
            serialize_boolean(writer, value)
        case f64:
            serialize_number(writer, value)
        case string:
            serialize_string(writer, value)
        case Array:
            serialize_array(writer, value)
        case Object:
            serialize_object(writer, value)
    }
}
serialize_nil :: proc(writer : ^Writer) {
    writer_u8(writer, u8(Types.Nil))
}
serialize_boolean :: proc(writer : ^Writer, value : bool) {
    writer_u8(writer, u8(Types.Boolean))
    writer_u8(writer, u8(value))
}
serialize_number :: proc(writer : ^Writer, value : f64) {
    writer_u8(writer, u8(Types.Number))
    writer_f64(writer, value)
}
serialize_string :: proc(writer : ^Writer, value : string) {
    writer_u8(writer, u8(Types.String))
    writer_slice(writer, transmute([]u8)value)
}
serialize_array :: proc(writer : ^Writer, value : Array) {
    writer_u8(writer, u8(Types.Array))
    writer_u16(writer, u16(len(value.elements)))
    for element in value.elements do serialize(writer, element)
}
serialize_object :: proc(writer : ^Writer, value : Object) {
    writer_u8(writer, u8(Types.Object))
    writer_u16(writer, u16(len(value.elements)))
    for key, value in value.elements {
        serialize(writer, key)
        serialize(writer, value)
    }
}
save :: proc(writer : ^Writer, path : string) {
    os.write_entire_file(path, writer.buffer[:])
}

deserialize :: proc(reader : ^Reader) -> Data {
    opecode := Opecodes[reader_u8(reader)]
    #partial switch opecode {
        case .Boolean:
            return reader_u8(reader) != 0
        case .Number:
            return reader_f64(reader)
        case .String:
            return transmute(string)reader_slice(reader)
        case .Array:
            array := new_array()
            length := reader_u16(reader)
            for _ in 0..<length {
                if !reader_can_consume(reader) do break
                array_append(&array, deserialize(reader))
            }
            return array
        case .Object:
            object := new_object()
            length := reader_u16(reader)
            for _ in 0..<length {
                if !reader_can_consume(reader) do break
                object_set(&object, deserialize(reader).(string), deserialize(reader))
            }
            return object
    }
    return nil
}
deserialize_nil :: proc(reader : ^Reader) -> bool {
    if reader_peek(reader) != u8(Types.Nil) do return false
    _ = reader_u8(reader)
    return true
}
deserialize_boolean :: proc(reader : ^Reader) -> (Maybe(bool), bool) {
    if reader_peek(reader) != u8(Types.Boolean) do return nil, false
    _ = reader_u8(reader)
    return reader_u8(reader) != 0, true
}
deserialize_number :: proc(reader : ^Reader) -> (Maybe(f64), bool) {
    if reader_peek(reader) != u8(Types.Number) do return nil, false
    _ = reader_u8(reader)
    return reader_f64(reader), true
}
deserialize_string :: proc(reader : ^Reader) -> (Maybe(string), bool) {
    if reader_peek(reader) != u8(Types.String) do return nil, false
    _ = reader_u8(reader)
    return transmute(string)reader_slice(reader), true
}
deserialize_array :: proc(reader : ^Reader) -> (Maybe(Array), bool) {
    if reader_peek(reader) != u8(Types.Array) do return nil, false
    _ = reader_u8(reader)
    
    array := new_array()
    for reader_can_consume(reader) && reader_peek(reader) != u8(Types.End) do array_append(&array, deserialize(reader))

    _ = reader_u8(reader)
    return array, true
}
deserialize_object :: proc(reader : ^Reader) -> (Maybe(Object), bool) {
    if reader_peek(reader) != u8(Types.Object) do return nil, false
    _ = reader_u8(reader)
    
    object := new_object()
    for reader_can_consume(reader) && reader_peek(reader) != u8(Types.End) do object_set(&object, deserialize(reader).(string), deserialize(reader))

    _ = reader_u8(reader)
    return object, true
}
open :: proc(path : string) -> Data {
    content, exist := os.read_entire_file(path)
    if exist {
        reader := new_reader(content)
        return deserialize(&reader)
    }
    panic(fmt.tprintf("file '%s' not found", path))
}