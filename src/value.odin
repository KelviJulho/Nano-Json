package src

Types :: enum u8 {
    Nil,
    Boolean,
    Integer,
    Float,
    String,
    Array,
    Object,
}

Value :: union {
    bool,
    i64,
    f64,
    string,
    Array,
    Object,
}

Array:: struct{
    elements : [dynamic]Value
}
new_array :: proc() -> Array {
    return {make_dynamic_array([dynamic]Value)}
}
array_append :: proc(self : ^Array, data : Value) {
    append(&self.elements, data)
}
array_remove :: proc(self : ^Array, index : uint) {
    ordered_remove(&self.elements, index)
}

Object :: struct{
    elements : map[string]Value
}
new_object :: proc() -> Object {
    return {make_map(map[string]Value)}
}
//create a new key or set new value
object_set :: proc(self : ^Object, key : string, value : Value) {
    self.elements[key] = value
}
//get key data, if not exist key return nil
object_get :: proc(self : ^Object, key : string) -> (Value, bool) {
    if data, ok := self.elements[key]; ok do return data, true
    return nil, false
}
//remove key
object_remove :: proc(self : ^Object, key : string) {
    delete_key(&self.elements, key)
}