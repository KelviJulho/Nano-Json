package src

Writer :: struct{
    buffer : [dynamic]u8
}
new_writer :: proc() -> Writer {
    return {{}}
}
writer_u8 :: proc(self : ^Writer, value : u8) {
    append(&self.buffer, value)
}
writer_u16 :: proc(self : ^Writer, value : u16) {
    writer_u8(self, u8(value))
    writer_u8(self, u8(value >> 8))
}
writer_u32 :: proc(self : ^Writer, value : u32) {
    writer_u16(self, u16(value))
    writer_u16(self, u16(value >> 16))
}
writer_u64 :: proc(self : ^Writer, value : u64) {
    writer_u32(self, u32(value))
    writer_u32(self, u32(value >> 32))
}
writer_i8 :: proc(self : ^Writer, value : i8) {
    append(&self.buffer, u8(value))
}
writer_i16 :: proc(self : ^Writer, value : i16) {
    writer_u16(self, u16(value))
}
writer_i32 :: proc(self : ^Writer, value : i32) {
    writer_u32(self, u32(value))
}
writer_i64 :: proc(self : ^Writer, value : i64) {
    writer_u64(self, u64(value))
}
writer_f16 :: proc(self : ^Writer, value : f16) {
    bits := transmute(u16)value
    writer_u16(self, bits)
}
writer_f32 :: proc(self : ^Writer, value : f32) {
    bits := transmute(u32)value
    writer_u32(self, bits)
}
writer_f64 :: proc(self : ^Writer, value : f64) {
    bits := transmute(u64)value
    writer_u64(self, bits)
}
writer_slice :: proc(self : ^Writer, value : []u8) {
    writer_undelimited_slice(self, value)
    writer_u8(self, 0x00)
}
writer_undelimited_slice :: proc(self : ^Writer, value : []u8) {
    for index in 0..<len(value) do writer_u8(self, value[index])
}
