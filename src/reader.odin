package src

Reader :: struct{
    source : []u8,
    cursor : uint
}
new_reader :: proc(source : []u8) -> Reader {
    return {source, 0}
}
reader_can_consume :: proc(self : ^Reader) -> bool {
    return self.cursor < len(self.source)
}
reader_reset_cursor :: proc(self : ^Reader) {
    self.cursor = 0
}
reader_set_cursor :: proc(self : ^Reader, cursor : uint) {
    self.cursor = cursor
}
reader_get_cursor :: proc(self : ^Reader) -> uint {
    return self.cursor
}
reader_consume :: proc(self : ^Reader) {
    self.cursor += 1
}
reader_peek :: proc(self : ^Reader) -> u8 {
    if !reader_can_consume(self) do return '\x0b'

    return self.source[self.cursor]
}
reader_u8 :: proc(self : ^Reader) -> u8 {
    defer reader_consume(self)
    return reader_peek(self)
}
reader_u16 :: proc(self : ^Reader) -> u16 {
    return u16(reader_u8(self)) | u16(reader_u8(self)) << 8
}
reader_u32 :: proc(self : ^Reader) -> u32 {
    return u32(reader_u8(self)) | u32(reader_u8(self)) << 8 | u32(reader_u8(self)) << 16 | u32(reader_u8(self)) << 24
}
reader_u64 :: proc(self : ^Reader) -> u64 {
    return u64(reader_u8(self)) |
        u64(reader_u8(self)) << 8  |
        u64(reader_u8(self)) << 16 |
        u64(reader_u8(self)) << 24 |
        u64(reader_u8(self)) << 32 |
        u64(reader_u8(self)) << 40 |
        u64(reader_u8(self)) << 48 |
        u64(reader_u8(self)) << 56
}
reader_i8 :: proc(self : ^Reader) -> i8 {
    return i8(reader_u8(self))
}
reader_i16 :: proc(self : ^Reader) -> i16 {
    return i16(reader_u16(self))
}
reader_i32 :: proc(self : ^Reader) -> i32 {
    return i32(reader_u32(self))
}
reader_i64 :: proc(self : ^Reader) -> i64 {
    return i64(reader_u64(self))
}
reader_f16 :: proc(self : ^Reader) -> f16 {
    bits := reader_u16(self)
    return transmute(f16)bits
}
reader_f32 :: proc(self : ^Reader) -> f32 {
    bits := reader_u32(self)
    return transmute(f32)bits
}
reader_f64 :: proc(self : ^Reader) -> f64 {
    bits := reader_u64(self)
    return transmute(f64)bits
}
reader_slice :: proc(self : ^Reader) -> []u8 {
    bytes := make_dynamic_array([dynamic]u8)

    for reader_can_consume(self) {
        char := reader_u8(self)
        if char == 0x00 do break

        append(&bytes, char)
    }

    return bytes[:]
}
reader_string :: proc(self : ^Reader) -> string {
    return string(reader_slice(self))
}