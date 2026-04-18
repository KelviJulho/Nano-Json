package src

Types :: enum u8 {
    Nil,
    Boolean,
    Number,
    String,
    Array,
    Object,
}

Data :: union {
    bool,
    f64,
    string,
    Array,
    Object,
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